#!/usr/bin/env bash

set -o errexit

if [ "$(docker inspect -f '{{.State.Running}}' homelab-registry 2>/dev/null || true)" != 'true' ]; then
  docker run \
    -d \
    --restart always \
    --network bridge \
    -p 5555:5000 \
    --name homelab-registry \
    registry:2
fi

docker inspect homelab >/dev/null 2>&1 || docker network create homelab

docker volume create homelab-k3s-server
docker volume create homelab-k3s-agent-1
docker volume create homelab-k3s-agent-2

if [ "$(docker inspect -f '{{.State.Running}}' homelab-k3s-server 2>/dev/null || true)" != 'true' ]; then
  docker run \
    -d \
    --tmpfs /run,/var/run \
    --ulimit nproc=65535 \
    --ulimit nofile=65535:65535 \
    --privileged \
    --restart always \
    --network homelab \
    -e K3S_TOKEN=bfz82BRQankBv7bx99H7Maa68wgBUd4f \
    -e K3S_KUBECONFIG_OUTPUT=/output/kubeconfig.yaml \
    -e K3S_KUBECONFIG_MODE=666 \
    -e K3S_NODE_NAME=homelab-k3s-server \
    -v homelab-k3s-server:/var/lib/rancher/k3s \
    -v $(pwd)/k3s/registries.yaml:/etc/rancher/k3s/registries.yaml \
    -v .:/output \
    -p 6443:6443 \
    -p 80:80 \
    -p 443:443 \
    --name homelab-k3s-server \
    rancher/k3s:v1.34.2-k3s1 server --tls-san kubernetes.homelab.ricoberger.dev --disable servicelb --disable traefik
fi

if [ "$(docker inspect -f '{{.State.Running}}' homelab-k3s-agent-1 2>/dev/null || true)" != 'true' ]; then
  docker run \
    -d \
    --tmpfs /run,/var/run \
    --ulimit nproc=65535 \
    --ulimit nofile=65535:65535 \
    --privileged \
    --restart always \
    --network homelab \
    -e K3S_URL=https://homelab-k3s-server:6443 \
    -e K3S_TOKEN=bfz82BRQankBv7bx99H7Maa68wgBUd4f \
    -e K3S_NODE_NAME=homelab-k3s-agent-1 \
    -v homelab-k3s-agent-1:/var/lib/rancher/k3s \
    -v $(pwd)/k3s/registries.yaml:/etc/rancher/k3s/registries.yaml \
    --name homelab-k3s-agent-1 \
    rancher/k3s:v1.34.2-k3s1 agent
fi

if [ "$(docker inspect -f '{{.State.Running}}' homelab-k3s-agent-2 2>/dev/null || true)" != 'true' ]; then
  docker run \
    -d \
    --tmpfs /run,/var/run \
    --ulimit nproc=65535 \
    --ulimit nofile=65535:65535 \
    --privileged \
    --restart always \
    --network homelab \
    -e K3S_URL=https://homelab-k3s-server:6443 \
    -e K3S_TOKEN=bfz82BRQankBv7bx99H7Maa68wgBUd4f \
    -e K3S_NODE_NAME=homelab-k3s-agent-2 \
    -v homelab-k3s-agent-2:/var/lib/rancher/k3s \
    -v $(pwd)/k3s/registries.yaml:/etc/rancher/k3s/registries.yaml \
    --name homelab-k3s-agent-2 \
    rancher/k3s:v1.34.2-k3s1 agent
fi

if [ "$(docker inspect -f='{{json .NetworkSettings.Networks.homelab}}' homelab-registry)" = 'null' ]; then
  docker network connect homelab homelab-registry
fi
