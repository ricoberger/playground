#!/usr/bin/env bash

set -o errexit
set -o pipefail
set -o nounset

docker buildx build \
  --platform=linux/arm64,linux/amd64 \
  -f ./Dockerfile \
  -t registry.homelab.ricoberger.dev:5555/otel-collector-agent:v0.144.0 \
  --output=type=registry,registry.insecure=true \
  --push \
  .
