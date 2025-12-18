#!/usr/bin/env bash

docker container stop homelab-k3s-agent-2
docker container stop homelab-k3s-agent-1
docker container stop homelab-k3s-server
docker container stop homelab-registry

docker container rm homelab-k3s-agent-2
docker container rm homelab-k3s-agent-1
docker container rm homelab-k3s-server
docker container rm homelab-registry

docker volume rm homelab-k3s-agent-2
docker volume rm homelab-k3s-agent-1
docker volume rm homelab-k3s-server

docker network rm homelab
