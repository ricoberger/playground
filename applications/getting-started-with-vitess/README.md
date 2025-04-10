# Getting Started with Vitess

Set up for the
[**Getting Started with Vitess**](https://ricoberger.de/blog/posts/getting-started-with-vitess/)
blog post.

```sh
docker buildx build --platform=linux/amd64 -f ./Dockerfile -t registry.homelab.ricoberger.dev/vitess-client:latest .
docker buildx build --platform=linux/arm64 -f ./Dockerfile -t registry.homelab.ricoberger.dev/vitess-client:latest .
docker push registry.homelab.ricoberger.dev/vitess-client:latest

kubectl apply --server-side -f deployment.yaml
```
