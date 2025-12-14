# Homelab

1. Create a `.env` file for the DNS setup with the following content:

   ```sh
   touch dns/.env
   ```

   ```plaintext
   CLOUDFLARE_API_TOKEN=
   CLOUDFLARE_ZONE_ID=
   ```

2. Create DNS records:

   ```sh
   ./dns/dns.sh --domain=<VPN>.homelab.ricoberger.dev --ip=public --operation=create

   ./dns/dns.sh --domain=registry.homelab.ricoberger.dev --ip=private --operation=create
   ./dns/dns.sh --domain=kubernetes.homelab.ricoberger.dev --ip=private --operation=create
   ```

3. Create a CronJob to update the DNS record for the VPN:

   ```sh
   crontab -e
   ```

   ```plaintext
   */5 * * * * /Users/ricoberger/Documents/GitHub/ricoberger/playground/homelab/dns/dns.sh --domain=<VPN>.homelab.ricoberger.dev --ip=public --operation=update
   # Or with logging output to file
   # */5 * * * * /Users/ricoberger/Documents/GitHub/ricoberger/playground/homelab/dns/dns.sh --domain=<VPN>.homelab.ricoberger.dev --ip=public --operation=update >> /Users/ricoberger/Desktop/dns-vpn-update.log 2>&1
   ```

   > If the CronJob fails with an error `Operation not permitted` on macOS, go
   > to **System Settings** -> **Privacy & Security** -> **Full Disk Access**
   > and add the `/usr/sbin/cron` binary.

4. Start a Kubernetes cluster via `kind`:

   ```sh
   ./kubernetes/kind.sh
   ```

5. Get the Kubeconfig for the `kind` cluster:

   ```sh
   kind export kubeconfig --name homelab --kubeconfig kind-homelab.yaml

   scp ricoberger@ricos-mac-mini.local:/Users/ricoberger/Documents/GitHub/ricoberger/playground/homelab/kind-homelab.yaml kind-homelab-original.yaml
   yq e '.clusters.[0].cluster.server |= sub("https://0.0.0.0:6443", "https://kubernetes.homelab.ricoberger.dev:6443")' kind-homelab-original.yaml > kind-homelab.yaml
   rm kind-homelab-original.yaml
   ```
