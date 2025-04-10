# Getting Started with YugabyteDB

Set up for the
[**Getting Started with YugabyteDB**](https://ricoberger.de/blog/posts/getting-started-with-yugabytedb/)
blog post.

```sh
docker buildx build --platform=linux/amd64 -f ./Dockerfile -t registry.homelab.ricoberger.dev/yugabytedb-client:latest .
docker buildx build --platform=linux/arm64 -f ./Dockerfile -t registry.homelab.ricoberger.dev/yugabytedb-client:latest .
docker push registry.homelab.ricoberger.dev/yugabytedb-client:latest

kubectl apply --server-side -f deployment.yaml
```
