FROM alpine:3.23.0 AS certs
RUN apk --update add ca-certificates

FROM golang:1.25.5 AS build-stage
WORKDIR /build
COPY ./manifest.yaml manifest.yaml
RUN --mount=type=cache,target=/root/.cache/go-build GO111MODULE=on go install go.opentelemetry.io/collector/cmd/builder@v0.144.0
RUN --mount=type=cache,target=/root/.cache/go-build builder --config manifest.yaml

FROM gcr.io/distroless/base:latest
COPY --from=certs /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/ca-certificates.crt
COPY --from=build-stage /build/otel-collector /otel-collector/otel-collector
ENTRYPOINT ["/otel-collector/otel-collector"]
