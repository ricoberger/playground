#!/bin/sh

mount --make-shared /var/lib/kubelet
mount --make-rshared /

exec /bin/k3s "$@"
