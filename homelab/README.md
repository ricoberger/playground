# Homelab

1. Create a `.env.` file for the DNS setup with the following content:

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

   ./dns/dns.sh --domain=traefik.homelab.ricoberger.dev --ip=private --operation=create
   ./dns/dns.sh --domain=ollama.homelab.ricoberger.dev --ip=private --operation=create
   ./dns/dns.sh --domain=open-webui.homelab.ricoberger.dev --ip=private --operation=create
   ```

3. Create a CronJob to update the DNS record for the VPN:

   ```sh
   crontab -e
   ```

   ```plaintext
   */5 * * * * /Users/ricoberger/Documents/GitHub/ricoberger/playground/homelab/dns/dns.sh --domain=<VPN>.homelab.ricoberger.dev --ip=public --operation=update
   ```

   > If the CronJob fails with an error `Operation not permitted` on macOS, go
   > to **System Settings** -> **Privacy & Security** -> **Full Disk Access**
   > and add the `/usr/sbin/cron` binary.

4. Create a `.env.` file for the Traefik setup with the following content:

   ```sh
   touch traefik/.env
   ```

   ```plaintext
   CF_DNS_API_TOKEN=
   TRAEFIK_CERTIFICATESRESOLVERS_CLOUDFLARE_ACME_EMAIL=
   TRAEFIK_DASHBOARD_CREDENTIALS=
   ```

5. Create a `acme.json` file for Traefik, which is used to store the
   certificates:

   ```sh
   touch traefik/data/acme.json
   chmod 600 traefik/data/acme.json
   ```

6. Create a network for Docker:

   ```sh
   docker network create proxy
   ```

7. Start all services:

   ```sh
   docker-compose -f traefik/docker-compose.yaml up -d --force-recreate
   docker-compose -f open-webui/docker-compose.yaml up -d --force-recreate
   ```
