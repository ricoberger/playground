# Homelab

1. Create a `k3s` cluster:

   ```sh
   ./k3s/k3s.sh
   ```

2. Get the Kubeconfig for the `k3s` cluster:

   ```sh
   yq e '.clusters.[0].cluster.server |= sub("https://127.0.0.1:6443", "https://kubernetes.homelab.ricoberger.dev:6443") | .clusters.[0].name |= sub("default", "homelab") | .contexts.[0].context.cluster |= sub("default", "homelab") | .contexts.[0].context.user |= sub("default", "homelab") | .contexts.[0].name |= sub("default", "homelab") | .users.[0].name |= sub("default", "homelab") | .current-context |= sub("default", "homelab")' kubeconfig.yaml > homelab.yaml

   # To copy the Kubeconfig to another machine, run the following command:
   scp ricoberger@ricos-mac-mini:~/Documents/GitHub/ricoberger/playground/homelab/homelab.yaml homelab.yaml
   ```

3. Deploy Flux:

   ```sh
   kubectl kustomize ./kubernetes/base | kubectl apply --server-side -f -
   kubectl kustomize ./kubernetes/flux-system | kubectl apply --server-side -f -
   ```

4. Create the following secrets manually:

   ```sh
   kubectl create secret generic cloudflare --namespace cert-manager --from-literal=CLOUDFLARE_API_TOKEN=$HOMELAB_CLOUDFLARE_API_TOKEN
   kubectl create secret generic cloudflare --namespace external-dns --from-literal=CLOUDFLARE_API_TOKEN=$HOMELAB_CLOUDFLARE_API_TOKEN
   kubectl create secret generic grafana-credentials --namespace observability --from-literal=GF_SECURITY_ADMIN_USER=$HOMELAB_GRAFANA_ADMIN_USER --from-literal=GF_SECURITY_ADMIN_PASSWORD=$HOMELAB_GRAFANA_ADMIN_PASSWORD --from-literal=GF_RENDERING_RENDERER_TOKEN=$HOMELAB_GRAFANA_RENDERING_RENDERER_TOKEN
   ```
