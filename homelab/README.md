# Homelab

1. Create a `.env` file for the DNS setup with the following content:

   ```sh
   touch misc/dns/.env
   ```

   ```plaintext
   CLOUDFLARE_API_TOKEN=
   CLOUDFLARE_ZONE_ID=
   ```

2. Create DNS records:

   ```sh
   ./misc/dns/dns.sh --domain=<VPN>.homelab.ricoberger.dev --ip=public --operation=create

   ./misc/dns/dns.sh --domain=registry.homelab.ricoberger.dev --ip=private --operation=create
   ./misc/dns/dns.sh --domain=kubernetes.homelab.ricoberger.dev --ip=private --operation=create
   ```

3. Create a CronJob to update the DNS record for the VPN:

   ```sh
   crontab -e
   ```

   ```plaintext
   */5 * * * * /Users/ricoberger/Documents/GitHub/ricoberger/playground/homelab/misc/dns/dns.sh --domain=<VPN>.homelab.ricoberger.dev --ip=public --operation=update
   # Or with logging output to file
   # */5 * * * * /Users/ricoberger/Documents/GitHub/ricoberger/playground/homelab/misc/dns/dns.sh --domain=<VPN>.homelab.ricoberger.dev --ip=public --operation=update >> /Users/ricoberger/Desktop/dns-vpn-update.log 2>&1
   ```

   > If the CronJob fails with an error `Operation not permitted` on macOS, go
   > to **System Settings** -> **Privacy & Security** -> **Full Disk Access**
   > and add the `/usr/sbin/cron` binary.

4. Create a `k3s` cluster:

   ```sh
   ./k3s/k3s.sh
   ```

5. Get the Kubeconfig for the `k3s` cluster:

   ```sh
   scp ricoberger@ricos-mac-mini.local:/Users/ricoberger/Documents/GitHub/ricoberger/playground/homelab/kubeconfig.yaml kubeconfig.yaml
   yq e '.clusters.[0].cluster.server |= sub("https://127.0.0.1:6443", "https://kubernetes.homelab.ricoberger.dev:6443") | .clusters.[0].name |= sub("default", "homelab") | .contexts.[0].context.cluster |= sub("default", "homelab") | .contexts.[0].context.user |= sub("default", "homelab") | .contexts.[0].name |= sub("default", "homelab") | .users.[0].name |= sub("default", "homelab") | .current-context |= sub("default", "homelab")' kubeconfig.yaml > homelab.yaml
   rm kubeconfig.yaml
   ```

6. Deploy Flux:

   ```sh
   ssh-keygen -t ed25519 -C mail@ricoberger.dev -f deploy-key

   kubectl -n flux-system create secret generic deploy-key \
     --from-file=identity=deploy-key \
     --from-file=identity.pub=deploy-key.pub \
     --from-literal=known_hosts="$(ssh-keyscan github.com 2> /dev/null)" \
     --dry-run=client -o yaml > deploy-key.yaml
   ```

   ```sh
   kubectl create namespace flux-system --dry-run=client -o yaml | kubectl apply --server-side -f -
   kubectl apply -n flux-system --server-side -f deploy-key.yaml
   kubectl apply -n flux-system --server-side -f soaps-gpg.yaml

   kubectl kustomize ./kubernetes/base | kubectl apply --server-side -f -
   kubectl kustomize ./kubernetes/flux-system | kubectl apply --server-side -f -
   ```

> [!NOTE]
>
> We are using SOPS to manage [secrets in Flux](./misc/secrets/README.md), so
> that we only have to create the following secrets manually, because I do not
> want to add them to a public Git respository.
>
> ```sh
> kubectl create secret generic cloudflare --namespace cert-manager --from-literal=CLOUDFLARE_API_TOKEN=<CLOUDFLARE-API-TOKEN>
> kubectl create secret generic cloudflare --namespace external-dns --from-literal=CLOUDFLARE_API_TOKEN=<CLOUDFLARE-API-TOKEN>
> ```
