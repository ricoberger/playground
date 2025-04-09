# Getting Started with Vitess

Set up for the
[**Getting Started with Vitess**](https://ricoberger.de/blog/posts/getting-started-with-vitess/)
blog post.

```sh
docker buildx build --platform=linux/amd64 -f ./Dockerfile -t registry.example.com/vitess:latest .
docker push registry.example.com/vitess:latest

kubectl apply --server-side -f deployment.yaml
```
