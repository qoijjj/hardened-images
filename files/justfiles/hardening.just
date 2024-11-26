# Harden flatpaks by preloading hardened_malloc (highest supported hwcap). When called with a flatpak application ID as an argument, applies the overrides to that application instead of globally.
harden-flatpak FLATPAK="":
    #!/usr/bin/bash
    var1={{ FLATPAK }}
    flatpak_id="${var1:-}"
    flatpak override --user --filesystem=host-os:ro $flatpak_id
    uarches="$(/usr/lib64/ld-linux-x86-64.so.2 --help | grep '(supported, searched)' | cut -d'v' -f2)"
    bestuarch="${uarches:0:1}"
    if [ -z "$bestuarch" ] ; then
        echo "No microarchitecture support detected. Using default x86-64-v1 architecture${flatpak_id:+" for $flatpak_id's malloc"}."
        flatpak override --user --env=LD_PRELOAD=/var/run/host/usr/lib64/libhardened_malloc.so $flatpak_id
    else
        echo "x86-64-v$bestuarch support detected. Using x86-64-v$bestuarch microarchitecture${flatpak_id:+" for $flatpak_id's malloc"}."
        flatpak override --user --env=LD_PRELOAD=/var/run/host/usr/lib64/glibc-hwcaps/x86-64-v"$bestuarch"/libhardened_malloc.so $flatpak_id
    fi

# Setup USBGuard
setup-usbguard:
    #!/usr/bin/bash
    echo "Notice: This will generate a policy based on your existing connected USB devices."
    ACTIVE_USERNAME=$(whoami)
    run0 sh -c '
        mkdir -p /var/log/usbguard
        mkdir -p /etc/usbguard
        chmod 755 /etc/usbguard
        usbguard generate-policy > /etc/usbguard/rules.conf
        systemctl enable --now usbguard.service
        usbguard add-user $1
    ' -- $ACTIVE_USERNAME
    systemctl enable --user --now usbguard-notifier.service
