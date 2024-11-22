#!/usr/bin/env bash

# Tell build process to exit if there are any errors.
set -oue pipefail

# Reference: https://gist.github.com/ok-ryoko/1ff42a805d496cb1ca22e5cdf6ddefb0#usrbinchage

whitelist=(
    # https://gitlab.freedesktop.org/polkit/polkit/-/issues/168
    "/usr/lib/polkit-1/polkit-agent-helper-1"
    # https://github.com/secureblue/secureblue/issues/119
    "/usr/lib64/libhardened_malloc-light.so"
    "/usr/lib64/libhardened_malloc-pkey.so"
    "/usr/lib64/libhardened_malloc.so"
    # https://github.com/secureblue/secureblue/issues/119
    "/usr/lib64/glibc-hwcaps/x86-64/libhardened_malloc-light.so"
    "/usr/lib64/glibc-hwcaps/x86-64/libhardened_malloc-pkey.so"
    "/usr/lib64/glibc-hwcaps/x86-64/libhardened_malloc.so"
    "/usr/lib64/glibc-hwcaps/x86-64-v2/libhardened_malloc-light.so"
    "/usr/lib64/glibc-hwcaps/x86-64-v2/libhardened_malloc-pkey.so"
    "/usr/lib64/glibc-hwcaps/x86-64-v2/libhardened_malloc.so"
    "/usr/lib64/glibc-hwcaps/x86-64-v3/libhardened_malloc-light.so"
    "/usr/lib64/glibc-hwcaps/x86-64-v3/libhardened_malloc-pkey.so"
    "/usr/lib64/glibc-hwcaps/x86-64-v3/libhardened_malloc.so"
    "/usr/lib64/glibc-hwcaps/x86-64-v4/libhardened_malloc-light.so"
    "/usr/lib64/glibc-hwcaps/x86-64-v4/libhardened_malloc-pkey.so"
    "/usr/lib64/glibc-hwcaps/x86-64-v4/libhardened_malloc.so"
    # Requires cap_setgid,cap_setuid if the SUID bit is removed
    "/usr/sbin/grub2-set-bootflag"
)


is_in_whitelist() {
    local binary="$1"
    for allowed_binary in "${whitelist[@]}"; do
        if [ "$binary" = "$allowed_binary" ]; then
            return 0
        fi
    done
    return 1
}

find /usr -type f -perm /4000 |
    while IFS= read -r binary; do
        if ! is_in_whitelist "$binary"; then
            echo "Removing SUID bit from $binary"
            chmod u-s "$binary"
            echo "Removed SUID bit from $binary"
        fi
    done

find /usr -type f -perm /2000 |
    while IFS= read -r binary; do
        if ! is_in_whitelist "$binary"; then
            echo "Removing SGID bit from $binary"
            chmod g-s "$binary"
            echo "Removed SGID bit from $binary"
        fi
    done


rm /usr/bin/chsh
rm /usr/bin/pkexec
rm /usr/bin/sudo

rm /etc/dnf/protected.d/sudo.conf
rpm-ostree override remove sudo sudo-python-plugin

systemctl enable setcapsforunsuidbinaries.service
