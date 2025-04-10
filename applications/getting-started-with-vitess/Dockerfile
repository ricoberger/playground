FROM golang:1.24.1 AS build
WORKDIR /database-client
COPY go.mod  ./
RUN go mod download
COPY . .
RUN export CGO_ENABLED=0 && go build -o ./bin/database-client .

FROM alpine:3.21.3
RUN apk update && apk add --no-cache ca-certificates
RUN mkdir /database-client
COPY --from=build /database-client/bin/database-client /database-client
WORKDIR /database-client
USER nobody
ENTRYPOINT  [ "/database-client/database-client" ]
