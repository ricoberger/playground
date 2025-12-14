#!/usr/bin/env bash

set -o errexit

# Create registry container unless it already exists
registry_name='homelab-registry'
registry_port='5001'

if [ "$(docker inspect -f '{{.State.Running}}' "${registry_name}" 2>/dev/null || true)" != 'true' ]; then
  docker run \
    -d --restart=always -p "0.0.0.0:${registry_port}:5000" --network bridge --name "${registry_name}" \
    registry:2
fi


# Create a three node kind cluster with containerd registry config dir enabled
# and extra port mappings for the ingress controller
#
# See:
# - https://kind.sigs.k8s.io/docs/user/configuration/
# - https://kind.sigs.k8s.io/docs/user/ingress/
# - https://github.com/kubernetes-sigs/kind/issues/2875
# - https://github.com/containerd/containerd/blob/main/docs/cri/config.md#registry-configuration
# - https://github.com/containerd/containerd/blob/main/docs/hosts.md
cat <<EOF | kind create cluster --config=-
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
name: homelab
networking:
  apiServerAddress: "0.0.0.0"
  apiServerPort: 6443
nodes:
  - role: control-plane
    image: kindest/node:v1.34.2
    extraPortMappings:
      - containerPort: 80
        hostPort: 80
        protocol: TCP
      - containerPort: 443
        hostPort: 443
        protocol: TCP
  - role: worker
    image: kindest/node:v1.34.2
  - role: worker
    image: kindest/node:v1.34.2
containerdConfigPatches:
  - |-
    [plugins."io.containerd.grpc.v1.cri".registry]
      config_path = "/etc/containerd/certs.d"
kubeadmConfigPatchesJSON6902:
  - group: kubeadm.k8s.io
    version: v1beta3
    kind: ClusterConfiguration
    patch: |
      - op: add
        path: /apiServer/certSANs/-
        value: kubernetes.homelab.ricoberger.dev
EOF

# Add the registry config to the nodes
#
# We want a consistent name that works from both ends, so we tell containerd to
# alias registry.homelab.ricoberger.dev:${registry_port} to the registry
# container when pulling images
REGISTRY_DIR="/etc/containerd/certs.d/registry.homelab.ricoberger.dev:${registry_port}"
for node in $(kind get nodes); do
  docker exec "${node}" mkdir -p "${REGISTRY_DIR}"
  cat <<EOF | docker exec -i "${node}" cp /dev/stdin "${REGISTRY_DIR}/hosts.toml"
[host."http://${registry_name}:5000"]
EOF
done

# Connect the registry to the cluster network if not already connected
# This allows kind to bootstrap the network but ensures they're on the same
# network
if [ "$(docker inspect -f='{{json .NetworkSettings.Networks.kind}}' "${registry_name}")" = 'null' ]; then
  docker network connect "kind" "${registry_name}"
fi

# Document the local registry
#
# See:
# - https://github.com/kubernetes/enhancements/tree/master/keps/sig-cluster-lifecycle/generic/1755-communicating-a-local-registry
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: ConfigMap
metadata:
  name: local-registry-hosting
  namespace: kube-public
data:
  localRegistryHosting.v1: |
    host: "registry.homelab.ricoberger.dev:${registry_port}"
    help: "https://kind.sigs.k8s.io/docs/user/local-registry/"
EOF
