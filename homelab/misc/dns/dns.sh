#!/usr/bin/env bash

set -o errexit
set -o pipefail
set -o nounset
# set -o xtrace

if [[ "$#" -lt 1 ]]; then
  echo "Usage: $(basename "$0") -d|--domain=<domain> -i|--ip=<ip> -o|--operation=<operation>

Description:
  A script to create and update DNS records on Cloudflare.

Options:
  -d, --domain     Set the domain which should be used.
  -i, --ip         Set the IP address which should be used. Must be 'public' or 'private'.
  -o, --operation  Set the operation which should be used. Must be 'create' or 'update'.

Examples:
  $(basename "$0") --domain=vpn.example.com --ip=public --operation=update"

  exit 1
fi

for arg in "$@"
do
  case ${arg} in
    -d=*|--domain=*)
    domain="${arg#*=}"
    shift
    ;;
    -i=*|--ip=*)
    ip="${arg#*=}"
    shift
    ;;
    -o=*|--operation=*)
    operation="${arg#*=}"
    shift
    ;;
    *)
    ;;
  esac
done

# Validate the 'domain', 'ip' and 'operation' arguments. The domain must not be
# empty. The IP must be 'public' or 'private'. The operation must be 'create' or
# 'update'.
if [ -z "${domain}" ]; then
  echo "You have to provide a domain"
  exit 1
fi

if [ -z "${ip}" ]; then
  echo "You have to provide an IP"
  exit 1
fi

if [ "${ip}" != "public" ] && [ "${ip}" != "private" ]; then
  echo "The IP argument must be 'public' or 'private'"
  exit 1
fi

if [ -z "${operation}" ]; then
  echo "You have to provide a operation"
  exit 1
fi

if [ "${operation}" != "create" ] && [ "${operation}" != "update" ]; then
  echo "The IP argument must be 'public' or 'private'"
  exit 1
fi

# Go into the directory where the script is located and load the environment.
cd "$(dirname "$0")"

set -a && source .env && set +a

# When the IP is 'public', then get the public IP address. Otherwise get the
# private IP address.
if [ "${ip}" == "public" ]; then
  ipaddress=$(curl 'https://api.ipify.org?format=json' | jq -r .ip)
else
  ipaddress=$(ipconfig getifaddr en0 || ipconfig getifaddr en1)
fi

echo "Domain: ${domain}"
echo "IP Address: ${ipaddress}"
echo "Operation: ${operation}"

# If the operation is 'create', then create the DNS record with the IP from the
# last address.
if [ "${operation}" == "create" ]; then
  curl https://api.cloudflare.com/client/v4/zones/${CLOUDFLARE_ZONE_ID}/dns_records \
    -H "Authorization: Bearer ${CLOUDFLARE_API_TOKEN}" \
    -H "Content-Type: application/json" \
    -d '{
      "content": "'${ipaddress}'",
      "name": "'${domain}'",
      "proxied": false,
      "ttl": 300,
      "type": "A"
    }'
fi

# If the operation is 'update', then update the DNS record with the IP from the
# last step. For that we have to get the existing DNS record first, because the
# update is done via the ID of the DNS record. Afterwards we can use the ID to
# update the DNS record with the new IP.
if [ "${operation}" == "update" ]; then
  dnsrecord=$(curl -s -X GET "https://api.cloudflare.com/client/v4/zones/${CLOUDFLARE_ZONE_ID}/dns_records?type=A&name=${domain}" \
    -H "Authorization: Bearer ${CLOUDFLARE_API_TOKEN}" \
    -H "Content-Type: application/json")


  dnsrecordid=$(echo "${dnsrecord}" | jq -r '{"result"}[] | .[0] | .id')
  dnsrecordipaddress=$(echo "${dnsrecord}" | jq -r '{"result"}[] | .[0] | .content')

  # If the IP of the DNS record is already up to date, we can skip the request
  # to update the IP.
  if [ "${ipaddress}" == "${dnsrecordipaddress}" ]; then
    echo "DNS record is already up to date"
    exit 0
  fi

  curl -X PUT https://api.cloudflare.com/client/v4/zones/${CLOUDFLARE_ZONE_ID}/dns_records/${dnsrecordid} \
    -H "Authorization: Bearer ${CLOUDFLARE_API_TOKEN}" \
    -H "Content-Type: application/json" \
    -d '{
      "content": "'${ipaddress}'",
      "name": "'${domain}'",
      "proxied": false,
      "ttl": 300,
      "type": "A"
    }'
fi
