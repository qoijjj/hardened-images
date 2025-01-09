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

# Harden Flatpaks further by disabling all permissions by default and rejecting known arbitrary DBus names, applies only to the current user
flatpak-permissions-lockdown:
    #!/usr/bin/bash
    kCommand="flatpak override --user"
    kSharePermissions=("network" "ipc")
    kSocketPermissions=("inherit-wayland-socket" "gpg-agent" "cups" "pcsc" "ssh-auth" "system-bus" "session-bus" "pulseaudio" "fallback-x11" "x11")
    kDevicePermissions=("all" "shm" "kvm" "input" "usb")
    kFeaturePermissions=("per-app-dev-shm" "canbus" "bluetooth" "multiarch" "devel")
    kFilesystemPermissions=("home" "host-etc" "host")
    kDangerousFilesystemPermissions=("~/.bashrc" "~/.bash_profile" "/home" "/var/home" "/var" "/media" "/run/media" "/run" "/mnt")
    kKnownSessionBusNames=("org.gnome.Settings" "org.gnome.SettingsDaemon.MediaKeys" "org.gnome.SessionManager" "org.kde.kiod5" "org.kde.JobViewServer" "org.gtk.vfs.*" "org.freedesktop.secrets" "org.kde.kconfig.notify" "org.kde.kpasswdserver" "org.kde.*" "org.kde.StatusNotifierWatcher" "org.kde.kded6" "org.kde.kpasswdserver6" "org.kde.kiod6" "com.canonical.Unity" "org.freedesktop.Notifications" "org.freedesktop.FileManager1" "org.freedesktop.impl.portal.PermissionStore" "org.freedesktop.Flatpak" "com.canonical.AppMenu.Registrar" "org.kde.KGlobalSettings" "org.kde.kded5" "com.canonical.Unity.LauncherEntry" "org.kde.kwalletd5" "org.gnome.SettingsDaemon" "org.a11y.Bus" "com.canonical.indicator.application" "org.freedesktop.ScreenSaver" "ca.desrt.dconf" "org.freedesktop.PowerManagement" "org.gnome.Software" "org.freedesktop.Tracker3.Writeback" "io.missioncenter.MissionCenter.Gatherer")
    kKnownSystemBusNames=("org.freedesktop.systemd1" "org.freedesktop.Avahi.*" "org.freedesktop.login1" "org.freedesktop.NetworkManager" "org.freedesktop.UPower" "org.freedesktop.UDisks2" "org.freedesktop.fwupd")
    kFlatsealNameAccess=("org.gnome.Software" "org.freedesktop.impl.portal.PermissionStore")

    echo "This will configure flatpak to automatically reject most permissions (with the exception of the Wayland socket and the Dri device, since these are commonly used and ensure at the very least most apps will work without crashing)."
    echo "This will also grant Flatseal access to certain permissions to allow it to operate and make reconfiguring much easier."
    echo "NOTE: This will break just about all Flatpaks by default, it is ON YOU to configure them to work with this configuration."
    echo "NOTE 2: This DOES NOT enable hardened_malloc, use the harden-flatpak ujust command."
    echo ""
    echo "-- Share Permissions --"
    for i in ${kSharePermissions[@]}; do
        echo "	Rejecting $i..."
        $kCommand --unshare=$i
    done
    echo ""
    echo "-- Socket Permissions --"
    for i in ${kSocketPermissions[@]}; do
        echo "	Rejecting $i..."
        $kCommand --nosocket=$i
    done
    echo ""
    echo "-- Device Permissions --"
    for i in ${kDevicePermissions[@]}; do
        echo "	Rejecting $i..."
        $kCommand --nodevice=$i
    done
    echo ""
    echo "-- Feature Permissions --"
    for i in ${kFeaturePermissions[@]}; do
        echo "	Rejecting $i..."
        $kCommand --disallow=$i
    done
    echo ""
    echo "-- Filesystem Permissions --"
    for i in ${kFilesystemPermissions[@]}; do
        echo "	Rejecting $i..."
        $kCommand --nofilesystem=$i
    done
    echo ""
    echo "-- Dangerous Filesystem Permissions --"
    echo "Note: This is a VERY flawed implementation but it does cover a few blatant sandbox escape methods (such as the .bashrc escape or mounted drive access)"
    echo "It is not possible to cover all files since each file can be requested manually and therefore must be rejected manually"
    for i in ${kDangerousFilesystemPermissions[@]}; do
        echo "	Rejecting $i..."
        $kCommand --nofilesystem=$i
    done
    echo ""
    echo "NOTE: The next 2 lockdowns are NOT complete and only cover a list of known names, this can be expanded at any time"
    echo "-- Session Bus Name Access --"
    for i in ${kKnownSessionBusNames[@]}; do
        echo "	Rejecting $i..."
        $kCommand --no-talk-name=$i
    done
    echo ""
    echo "-- System Bus Name Access --"
    for i in ${kKnownSystemBusNames[@]}; do
        echo "	Rejecting $i..."
        $kCommand --system-no-talk-name=$i
    done
    echo ""
    echo "-- Peristent Filesystem Grant --"
    echo "Note: This is to unbreak many Flatpaks by allowing the app to store persistent data in their own, isolated home directory without accessing the user's"
    echo "	Granting access to peristent home..."
    $kCommand --persist=.
    echo ""
    echo "-- Granting Access to Common Permissions --"
    echo "Note: This will grant all apps access to some permissions to ensure most apps work by default, this also encourages the use of these permissions instead of their alternatives"
    echo "	Granting access to Wayland and hardware acceleration..."
    $kCommand --socket=wayland --device=dri
    echo ""
    echo "-- Granting Flatseal Access to Bus Names --"
    for i in ${kFlatsealNameAccess[@]}; do
        echo "	Rejecting $i..."
        $kCommand --talk-name=$i com.github.tchx84.Flatseal
    done
    echo ""
    echo "Done"

# Resets Flatpak's global overrides
flatpak-reset-global-overrides:
    #!/usr/bin/bash
    GLOBAL_OVERRIDES="$HOME/.local/share/flatpak/overrides/global"
    echo "This will undo the flatpak-harden command, the flatpak-permissions-lockdown command, as well as any other global overrides (individual app overrides will not be affected)."
    echo "It will not delete the file, but simply move it from $GLOBAL_OVERRIDES to $GLOBAL_OVERRIDES.save"
    mv $GLOBAL_OVERRIDES $GLOBAL_OVERRIDES.save

# Setup USBGuard
setup-usbguard:
    #!/usr/bin/bash
    echo "Notice: This will generate a policy based on your existing connected USB devices."
    run0 sh -c '
        mkdir -p /var/log/usbguard
        mkdir -p /etc/usbguard
        chmod 755 /etc/usbguard
        usbguard generate-policy > /etc/usbguard/rules.conf
        sed -i "/IPCAllowedGroups=wheel/s/$/ usbguard/" /etc/usbguard/usbguard-daemon.conf
        restorecon -vR /var/log/usbguard
        systemctl enable --now usbguard.service
        usbguard add-user $1
    ' -- $USER
    systemctl enable --user --now usbguard-notifier.service

# Allow new device via usbguard
allow-usbguard-device:
    #! /bin/run0 /bin/bash
    [ "$UID" -eq 0 ] || { echo "This script must be run as root."; exit 1;}    
    if [ -f "/etc/usbguard/rules.conf" ]; then
        echo "usbguard appears to be configured and setup."
    else 
        echo "usbguard does not appear to be configured or setup."
        echo "Try 'just setup-usbguard'"
        exit 1
    fi    
    if [ "$(systemctl is-active usbguard.service)" != "active" ]; then
        systemctl restart usbguard.service
    	if [ "$(systemctl is-active usbguard.service)" != "active" ]; then
    		echo "usbguard.service is not active and could not be restarted"
    		exit 1
    	fi
    	echo "Warning: usbguard.service was not active and had to be restarted."
    else
    	echo "usbguard.service is running."
    fi
    if [ "$(systemctl is-enabled usbguard.service)" != "enabled" ]; then
    	echo "Warning: usbguard.service is not enabled and will not automatically start after boot"
    	echo "Would you like this script to set usbguard.service to start automatically after boot across the system? [y/n]"
    	read -r response
    	if [[ "$response" == [yY]* ]]; then
    		echo "Enabling usbguard.service"
    		systemctl enable --system --now usbguard.service
    	fi
    fi    
    valid_devices=$(usbguard list-devices -b)
    if [ -z "$valid_devices" ]; then
    	echo "No blocked devices detected!"
    	exit
    fi
    valid_response=0
    device=""
    echo ""
    echo "Choose your desired device to allow based off the number it's labeled (#: block id ...)."
    usbguard list-devices -b
    echo "Please give valid response (only numbers considered, only one device at a time):"
    while [ "$valid_response" == 0 ]; do
        read -r device
        device="${device//[!0-9]/}"
        valid_num=$(usbguard list-devices -b | sed 's/: block.*//' | tr '\n' ',' | sed 's/,*$//')
        if [ -n "$device" ] && [[ "$valid_num" == *"$device"* ]]; then
                valid_response=1
        else
                echo ""
                usbguard list-devices -b
                echo "Please give valid response ($valid_num):"
        fi
    done    
    read -r -p "Would you like this device to continue to be allowed after a reboot? [y/n]" permanent
    if [[ "$permanent" == [yY]* ]]; then
    	usbguard allow-device "$device" -p
    else
    	echo "Change will not persist after reboot."
    	usbguard allow-device "$device"
    fi
    echo "USB device now allowed." 
 
# Block device via usbguard
block-usbguard-device:
    #! /bin/run0 /bin/bash
    [ "$UID" -eq 0 ] || { echo "This script must be run as root."; exit 1;}    
    if [ -f "/etc/usbguard/rules.conf" ]; then
        echo "usbguard appears to be configured and setup."
    else 
        echo "usbguard does not appear to be configured or setup."
        echo "Try 'just setup-usbguard'"
        exit 1
    fi    
    if [ "$(systemctl is-active usbguard.service)" != "active" ]; then
        systemctl restart usbguard.service
    	if [ "$(systemctl is-active usbguard.service)" != "active" ]; then
    		echo "usbguard.service is not active and could not be restarted"
    		exit 1
    	fi
    	echo "Warning: usbguard.service was not active and had to be restarted."
    else
    	echo "usbguard.service is running."
    fi
    if [ "$(systemctl is-enabled usbguard.service)" != "enabled" ]; then
    	echo "Warning: usbguard.service is not enabled and will not automatically start after boot"
    	echo "Would you like this script to set usbguard.service to start automatically after boot across the system? [y/n]"
    	read -r response
    	if [[ "$response" == [yY]* ]]; then
    		echo "Enabling usbguard.service"
    		systemctl enable --system --now usbguard.service
    	fi
    fi    
    valid_devices=$(usbguard list-devices -a)
    if [ -z "$valid_devices" ]; then
    	echo "No allowed devices detected!"
    	echo "How on earth did we get here? How are you using this TUI? A PS/2 Keyboard?"
    	echo "Godspeed unknown PS/2 wielding hero!"
    	exit
    fi
    echo "WARNING: if you block your keyboard and/or your mouse, you will be in for a very bad time."
    valid_response=0
    device=""
    echo ""
    echo "Choose your desired device to block based off the number it's labeled (#: allow id ...)."
    usbguard list-devices -a
    echo "Please give valid response (only numbers considered, only one device at a time):"
    while [ "$valid_response" == 0 ]; do
        read -r device
        device="${device//[!0-9]/}"
        valid_num=$(usbguard list-devices -a | sed 's/: allow.*//' | tr '\n' ',' | sed 's/,*$//')
        if [ -n "$device" ] && [[ "$valid_num" == *"$device"* ]]; then
                valid_response=1
        else
                echo ""
                usbguard list-devices -a
                echo "Please give valid response ($valid_num):"
        fi
    done
    read -r -p "Would you like this device to continue to be blocked after a reboot? [y/n]" permanent
    if [[ "$permanent" == [yY]* ]]; then
    	usbguard block-device "$device" -p
    else
    	echo "Change will not persist after reboot."
    	usbguard block-device "$device"
    fi    
    echo "USB device now blocked."
