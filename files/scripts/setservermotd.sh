#!/usr/bin/env bash

# Tell build process to exit if there are any errors.
set -oue pipefail

sed -i 's/ujust --choose/ujust/' /usr/share/ublue-os/motd/secureblue.md
