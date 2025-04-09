FROM golang:1.24.1 AS build
WORKDIR /vitess
COPY go.mod  ./
RUN go mod download
COPY . .
RUN export CGO_ENABLED=0 && go build -o ./bin/vitess .

FROM alpine:3.21.3
RUN apk update && apk add --no-cache ca-certificates
RUN mkdir /vitess
COPY --from=build /vitess/bin/vitess /vitess
WORKDIR /vitess
USER nobody
ENTRYPOINT  [ "/vitess/vitess" ]
