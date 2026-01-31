#!/usr/bin/env bash

while :; do
  grpcurl -format-error -insecure -authority echoserver-grpc.homelab.ricoberger.dev -d '{ "status": "random" }' echoserver-grpc.homelab.ricoberger.dev:443 Echoserver.Status
  grpcurl -format-error -insecure -authority echoserver-grpc.homelab.ricoberger.dev -d '{ "uri": "localhost:8081", "method": "Echoserver.Status", "message": "{ \"status\": \"random\" }" }' echoserver-grpc.homelab.ricoberger.dev:443 Echoserver.Request
  curl -o /dev/null -s -w 'Total: %{time_total}s | Status: %{http_code}\n' 'https://echoserver-http.homelab.ricoberger.dev/status?status=random'
  curl -o /dev/null -s -w 'Total: %{time_total}s | Status: %{http_code}\n' -X POST -d '{"method":"GET","url":"http://echoserver.svc.cluster.local:8080/status?status=200"}' 'https://echoserver-http.homelab.ricoberger.dev/request'
  sleep 1
done
