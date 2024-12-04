#!/usr/bin/env bash

# Tell build process to exit if there are any errors.
set -oue pipefail

curl -Lo /etc/yum.repos.d/secureblue-selinux-policy-fedora-41.repo https://copr.fedorainfracloud.org/coprs/secureblue/selinux-policy/repo/fedora-41/secureblue-selinux-policy-fedora-41.repo
sed -i '0,/enabled=1/{s/enabled=1/enabled=1\npriority=90/}' /etc/yum.repos.d/secureblue-selinux-policy-fedora-41.repo

rpm-ostree override replace \
  --experimental \
  --from repo='copr:copr.fedorainfracloud.org:secureblue:selinux-policy' \
    selinux-policy \
    selinux-policy-targeted \
    selinux-policy-devel