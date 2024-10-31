#!/usr/bin/env bash

# Tell build process to exit if there are any errors.
set -oue pipefail

systemctl --global enable flatpak-user-update.timer
systemctl enable flatpak-system-update.timer