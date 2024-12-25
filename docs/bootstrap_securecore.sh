#!/bin/bash

SC_BUTANE_CONF_URL="https://github.com/secureblue/secureblue/blob/live/docs/securecore.butane"
ARCH="$(uname -m)"
COREOS_BUTANE_VER="0.23.0"
COREOS_BUTANE_BIN_URL="https://github.com/coreos/butane/releases/download/v${COREOS_BUTANE_VER}/butane-${ARCH}-unknown-linux-gnu"
COREOS_BUTANE_ASC_URL="${COREOS_BUTANE_BIN_URL}.asc"
FEDORA_KEY_URL="https://fedoraproject.org/fedora.gpg"

fetch_butane_cfg() {
    curl --silent --output-dir /tmp -L -O ${SC_BUTANE_CONF_URL}
    if [ $? != 0 ]; then
        echo "[!] There was an error downloading securecore.butane"
        exit 1
    fi
    SC_BUTANE_CONF="/tmp/securecore.butane"
}

fetch_butane_bin() {
    curl --silent --output-dir /tmp -L --remote-name-all ${FEDORA_KEY_URL} ${COREOS_BUTANE_BIN_URL} ${COREOS_BUTANE_ASC_URL}
    if [ $? != 0 ]; then
        echo "[!] There was an error downloading fedora key, butane binary, or butane asc"
        exit 1
    fi
    # remove url stuff to get filename. doing this complicated stuff because
    # the filename could vary based on arch
    BUTANE_BIN="/tmp/$(sed -r 's@.*(butane-.*)@\1@' <<< ${COREOS_BUTANE_BIN_URL})"
    BUTANE_ASC="${BUTANE_BIN}.asc"
    gpg --quiet --import /tmp/fedora.gpg
    gpg --verify ${BUTANE_ASC} ${BUTANE_BIN} 2>/dev/null
    if [ $? != 0 ]; then
        echo "[!] Bad signature for ${BUTANE_BIN} with ${BUTANE_ASC}"
        exit 1
    fi
    chmod +x ${BUTANE_BIN}
}

edit_butane_cfg() {
    local USER_PASSWORD CONFIRM_USER_PASSWORD
    while true
    do
        read -s -p 'Enter desired password: ' USER_PASSWORD
        echo
        read -s -p 'Confirm password: ' CONFIRM_USER_PASSWORD
        echo
        if [ "${USER_PASSWORD}" != "${CONFIRM_USER_PASSWORD}" ]; then
            echo "Passwords do not match"
            USER_PASSWORD=""
            CONFIRM_USER_PASSWORD=""
        else
            break
        fi
    done
    # mkpasswd is not bundled in the live DVD, must use chpasswd unfortunately
    echo "core:${USER_PASSWORD}" | sudo chpasswd -s 11 -c YESCRYPT
    sed -i "s@\$y\$.*@$(sudo grep -e ^core /etc/shadow | cut -d : -f 2)@" ${SC_BUTANE_CONF}

    # you can pass USER_SSH_KEY="" to the script if it is better for you
    # if not, it will be read interactively here
    if [[ ${USER_SSH_KEY} != "ssh-"* ]]; then
        local USER_SSH_KEY
        read -p 'Enter ssh public key (ssh-<alg> <key>): ' USER_SSH_KEY
        echo
    fi
    sed -i "s@ssh-ed25519 <key>@${USER_SSH_KEY}@" ${SC_BUTANE_CONF}
}

conv_butane_cfg() {
    ${BUTANE_BIN} --pretty ${SC_BUTANE_CONF} > /tmp/securecore.ign
    if [ $? != 0 ]; then
        echo "[!] Butane encountered an error"
        exit 1
    fi
}

fetch_butane_cfg
fetch_butane_bin
edit_butane_cfg
conv_butane_cfg
echo "Butane file configured. Now run the following:"
echo "  sudo coreos-installer install /dev/<disk> -i /tmp/securecore.ign"