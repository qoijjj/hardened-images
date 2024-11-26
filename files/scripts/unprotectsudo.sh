#!/usr/bin/env bash

# Tell build process to exit if there are any errors.
set -oue pipefail

rm -f /etc/dnf/protected.d/sudo.conf