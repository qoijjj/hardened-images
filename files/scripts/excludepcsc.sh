#!/usr/bin/env bash

# Tell build process to exit if there are any errors.
set -oue pipefail

sed -i 's/add_dracutmodules+=" fido2 tpm2-tss pkcs11 pcsc "/add_dracutmodules+=" fido2 tpm2-tss pkcs11 "/' /usr/lib/dracut/dracut.conf.d/90-ublue-luks.conf
