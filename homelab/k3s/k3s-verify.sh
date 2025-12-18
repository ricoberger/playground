#!/usr/bin/env bash

# Verify the registry and k3s installation by pulling a sample applicationimage,
# retagging it for the local registry, pushing it to the local registry,
# deploying it in the k3s cluster, and finally cleaning up the deployment.
#
# To use the local registry it might be possible that the registry must be added
# to the list of insecure registries in the "/etc/docker/daemon.json" or
# "~/.docker/daemon.json" configuration file depending on your setup.
#
# "insecure-registries":["registry.homelab.ricoberger.dev:5555"]

echo "Verifying K3s installation by deploying a sample application..."

echo "Pull sample application image from public registry, retag it for local registry, and push it to local registry"
docker pull gcr.io/google-samples/hello-app:1.0
docker tag gcr.io/google-samples/hello-app:1.0 registry.homelab.ricoberger.dev:5555/hello-app:1.0
docker push registry.homelab.ricoberger.dev:5555/hello-app:1.0
sleep 5

echo "Creating deployment in K3s cluster using the image from local registry..."
kubectl create deployment hello-server --namespace default --image=registry.homelab.ricoberger.dev:5555/hello-app:1.0
sleep 10

echo "Listing all pods in all namespaces to verify deployment..."
kubectl get pods -A
sleep 5

echo "Cleaning up: Deleting the sample deployment..."
kubectl delete deployment hello-server --namespace default
sleep 5

echo "Listing all pods in all namespaces to verify clean up..."
kubectl get pods -A
