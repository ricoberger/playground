# Secrets

We are using SOPS to manage our secrets in Git, encrypted using OpenPGP/GPG
keys. See
[https://fluxcd.io/flux/guides/mozilla-sops/](https://fluxcd.io/flux/guides/mozilla-sops/)
for more information.

## Prerequisites

Install [gnupg](https://www.gnupg.org/) and
[SOPS](https://github.com/mozilla/sops):

```sh
brew install gnupg sops
```

## Generate a GPG Key

Generate a GPG/OpenPGP key with no passphrase (`%no-protection`):

```sh
export FLUX_KEY_NAME="homelab"
export FLUX_KEY_COMMENT="Flux secrets for my homelab"

gpg --batch --full-generate-key <<EOF
%no-protection
Key-Type: 1
Key-Length: 4096
Subkey-Type: 1
Subkey-Length: 4096
Expire-Date: 0
Name-Comment: ${FLUX_KEY_COMMENT}
Name-Real: ${FLUX_KEY_NAME}
EOF
```

Retrieve the GPG key fingerprint (second row of the sec column):

```sh
gpg --list-secret-keys "${FLUX_KEY_NAME}"
```

```plaintext
sec   rsa4096 2025-12-17 [SCEAR]
      8ECEEAB78C379D845704FF358C76E8F3042C582E
uid           [ultimate] homelab (Flux secrets for my homelab)
ssb   rsa4096 2025-12-17 [SEA]
```

Store the key fingerprint as an environment variable:

```sh
export FLUX_KEY_FP=8ECEEAB78C379D845704FF358C76E8F3042C582E
```

Export the public and private keypair from your local GPG keyring and create a
Kubernetes secret named `sops-gpg` in the `flux-system` namespace:

```sh
gpg --export-secret-keys --armor "${FLUX_KEY_FP}" | kubectl create secret generic sops-gpg --namespace=flux-system --from-file=sops.asc=/dev/stdin
```

Delete the secret decryption key from your machine:

```sh
gpg --delete-secret-keys "${FLUX_KEY_FP}"
```

Export the public key into the Git directory:

```sh
gpg --export --armor "${FLUX_KEY_FP}" > ./misc/secrets/.sops.pub.asc

# Import this key
gpg --import ./misc/secrets/.sops.pub.asc
```

Write a SOPS config file:

```sh
cat <<EOF > ./misc/secrets/.sops.yaml
creation_rules:
  - path_regex: .*.yaml
    encrypted_regex: ^(data|stringData)$
    pgp: ${FLUX_KEY_FP}
EOF
```

## Encrypting Secrets Using OpenPGP

```sh
kubectl -n default create secret generic basic-auth \
  --from-literal=user=admin \
  --from-literal=password=change-me \
  --dry-run=client \
  -o yaml > ./kubernetes/basic-auth.yaml
```

```sh
sops --config ./misc/secrets/.sops.yaml --encrypt --in-place ./kubernetes/basic-auth.yaml
```
