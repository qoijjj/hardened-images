#!/bin/bash
set -euo pipefail

echo "Configuring PAM to use pam_athramp"

system_service="/etc/pam.d/system-auth"
password_service="/etc/pam.d/password-auth"

header="# Generated by Secureblue"
authramp_preauth="auth        required                                     libpam_authramp.so preauth"
authramp_authfail="auth        [default=die]                                libpam_authramp.so authfail"
authramp_account="account     required                                     libpam_authramp.so"

update_pam_service() {
    local file="$1"

    sed -i "/^# Generated by authselect/,/^# See authselect(8) for more details./c$header" "$file"
    sed -i "/^auth\\s\\+sufficient\\s\\+pam_unix\\.so/i$authramp_preauth" "$file"
    sed -i "/^auth\\s\\+required\\s\\+pam_deny\\.so/i$authramp_authfail" "$file"
    sed -i "/^account\\s\\+required\\s\\+pam_unix\\.so/i$authramp_account" "$file"
}

update_pam_service "$system_service"
update_pam_service "$password_service"