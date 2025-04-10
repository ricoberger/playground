FROM golang:1.24.1 AS build
WORKDIR /vitess-client
COPY go.mod  ./
RUN go mod download
COPY . .
RUN export CGO_ENABLED=0 && go build -o ./bin/vitess-client .

FROM alpine:3.21.3
RUN apk update && apk add --no-cache ca-certificates
RUN mkdir /vitess-client
COPY --from=build /vitess-client/bin/vitess-client /vitess-client
WORKDIR /vitess-client
USER nobody
ENTRYPOINT  [ "/vitess-client/vitess-client" ]
