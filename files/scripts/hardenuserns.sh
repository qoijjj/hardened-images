#!/usr/bin/env bash

# Tell build process to exit if there are any errors.
set -oue pipefail

cd ./selinux/chromium
bash chromium.sh
cd ../..

cd ./selinux/flatpakfull
bash flatpakfull.sh
cd ../..

semodule -i ./user_namespace/grant_userns.cil
semodule -i ./user_namespace/harden_userns.cil