#!/usr/bin/env bash

# Tell build process to exit if there are any errors.
set -oue pipefail

echo "Disabling print services"
systemctl disable cups
systemctl mask cups

systemctl disable cups-browsed
systemctl mask cups-browsed
