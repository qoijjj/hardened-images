#!/usr/bin/env bash

# Tell build process to exit if there are any errors.
set -oue pipefail

echo "X-GNOME-Autostart-enabled=false" >> /etc/xdg/autostart/sealertauto.desktop
