#!/usr/bin/env bash

# Tell build process to exit if there are any errors.
set -oue pipefail

systemctl enable secureblue-firstrun.service
systemctl enable secureblue-cleanup.service