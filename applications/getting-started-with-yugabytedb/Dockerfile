FROM golang:1.24.1 AS build
WORKDIR /yugabytedb-client
COPY go.mod  ./
RUN go mod download
COPY . .
RUN export CGO_ENABLED=0 && go build -o ./bin/yugabytedb-client .

FROM alpine:3.21.3
RUN apk update && apk add --no-cache ca-certificates
RUN mkdir /yugabytedb-client
COPY --from=build /yugabytedb-client/bin/yugabytedb-client /yugabytedb-client
WORKDIR /yugabytedb-client
USER nobody
ENTRYPOINT  [ "/yugabytedb-client/yugabytedb-client" ]
