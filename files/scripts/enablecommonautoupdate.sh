#!/usr/bin/env bash

# Tell build process to exit if there are any errors.
set -oue pipefail

systemctl enable rpm-ostreed-automatic.timer
systemctl --global enable podman-auto-update.timer