# Audit secureblue
audit-secureblue:
    #!/bin/bash

    STATUS_SUCCESS="SUCCESS"
    STATUS_WARNING="WARNING"
    STATUS_FAILURE="FAILURE"
    print_status() {
        local check_name="$1"
        local status="$2"

        local color_code
        case "$status" in
            $STATUS_SUCCESS) color_code=32 ;; # Green
            $STATUS_WARNING) color_code=33 ;; # Yellow
            $STATUS_FAILURE) color_code=31 ;;    # Red
            *) color_code=0 ;;
        esac

        local formatted_status
        formatted_status=$(printf "%*s" $(( (7 + ${#status}) / 2 )) "$status")
        formatted_status=$(printf "%-7s" "$formatted_status")

        printf "%-64s [ \033[%dm%s\033[0m ]\n" "$check_name"... "$color_code" "$formatted_status"
    }

    hasPermission() {
        local permissions=$1
        local prefix=$2
        local query=$3
        local line=$(grep "^${prefix}=" <<< "$permissions" | sed -e "s/^${prefix}=//" -e "s/#.*//")
        IFS=';' read -r -a list <<< "$line"
        for p in ${list[@]}; do
            if [[ "$p" =~ ^$query$ ]]; then
                return
            fi
        done
        return 1
    }

    KARGS=$(rpm-ostree kargs)
    KARGS_LIST=(
        "init_on_alloc=1"
        "init_on_free=1"
        "slab_nomerge"
        "page_alloc.shuffle=1"
        "randomize_kstack_offset=on"
        "vsyscall=none"
        "lockdown=confidentiality"
        "random.trust_cpu=off"
        "random.trust_bootloader=off"
        "iommu=force"
        "intel_iommu=on"
        "amd_iommu=force_isolation"
        "iommu.passthrough=0"
        "iommu.strict=1"
        "pti=on"
        "module.sig_enforce=1"
        "mitigations=auto,nosmt"
        "spectre_v2=on"
        "spec_store_bypass_disable=on"
        "l1d_flush=on"
        "gather_data_sampling=force"
        "efi=disable_early_pci_dma"
        "debugfs=off"
        "ia32_emulation=0"
    )

    for karg in "${KARGS_LIST[@]}"; do
        KARG_TEST_STRING="Checking for $karg karg"
        if echo "$KARGS" | grep -q "$karg"; then
            print_status "$KARG_TEST_STRING" "$STATUS_SUCCESS"
        else
            print_status "$KARG_TEST_STRING" "$STATUS_FAILURE"
        fi
    done

    SYSCTL_TEST_STRING="Ensuring no sysctl overrides"
    readarray -t sysctl_hardening_conf < <(grep -v -E -e "^#" -e "^$" </usr/etc/sysctl.d/hardening.conf)
    declare -A sysctl_hardening
    for line in "${sysctl_hardening_conf[@]}"; do
        parameter="$(sed -E -e "s/(.*) = .*/\1/"  <<<"$line")"
        value="$(sed -E "s/.* = (.*)/\1/" <<<"$line")"
        sysctl_hardening["$parameter"]+="$value"
    done
    sysctl_results="$(sysctl -a 2> >(grep -v "sysctl: permission denied on key "))"
    sysctl_errors=()
    for sysctl_parameter in "${!hardening[@]}"; do
        hardened_parameter_value="${hardening["$sysctl_parameter"]}"
        parameter_name="$(sed -E -e "s/\./\\\./g" -e "s/\*/\.\*/" <<<"$sysctl_parameter")"
        readarray -t sysctl_parameter_values < <(grep -E "^$key = " <<<"$sysctl_results")
        for parameter_value in "${sysctl_parameter_values[@]}"; do
            parameter_value="$(sed -E  -e "s/.* = (.*)/\1/" -e "s/\t/ /g" <<<"$result" | tr -s " " )"
            if [[ "$parameter_value" != "$hardened_parameter_value" && ("$hardened_parameter_value" != 0 && "$parameter_value" != disabled) ]]; then
                sysctl_errors+=("$sysctl_parameter should be $hardened_parameter_value, found $parameter_value")
            fi
        done
    done
    if [[ "${#sysctl_errors}" == 0 ]] && diff /usr/etc/sysctl.d/hardening.conf /etc/sysctl.d/hardening.conf > /dev/null; then
        print_status "$SYSCTL_TEST_STRING" "$STATUS_SUCCESS"
    else
        print_status "$SYSCTL_TEST_STRING" "$STATUS_FAILURE"
        for error in "${sysctl_errors[@]}"; do
            echo "> $error"
        done
    fi

    SIGNED_IMAGE_TEST_STRING="Ensuring a signed image is in use"
    if rpm-ostree status | grep -q "● ostree-image-signed"; then
        print_status "$SIGNED_IMAGE_TEST_STRING" "$STATUS_SUCCESS"
    else
        print_status "$SIGNED_IMAGE_TEST_STRING" "$STATUS_FAILURE"
    fi

    MODPROBE_TEST_STRING="Ensuring no modprobe overrides"
    readarray -t unwanted_modules < <(comm -12 <(lsmod | cut -f 1 -d " " | sort) <(cat /usr/etc/modprobe.d/blacklist.conf | grep -E '^(blacklist)|(install)' | cut -f 2 -d " " | sort))
    if [[ "${#unwanted_modules[@]}" == 0 ]] && diff /usr/etc/modprobe.d/blacklist.conf /etc/modprobe.d/blacklist.conf > /dev/null; then
        print_status "$MODPROBE_TEST_STRING" "$STATUS_SUCCESS"
    else
        print_status "$MODPROBE_TEST_STRING" "$STATUS_FAILURE"
        for module in "${unwanted_modules[@]}"; do
            echo "> $module is in blacklist.conf but it is loaded"
            if [[ "$module" == "bluetooth" ]]; then
                bluetooth_loaded=true
            fi
        done
    fi

    PTRACE_TEST_STRING="Ensuring ptrace is forbidden"
    if [[ "$(cat /proc/sys/kernel/yama/ptrace_scope)" == 3 ]]; then
        print_status "$PTRACE_TEST_STRING" "$STATUS_SUCCESS"
    else
        print_status "$PTRACE_TEST_STRING" "$STATUS_FAILURE"
        ptrace_allowed=true
    fi

    AUTHSELECT_TEST_STRING="Ensuring no authselect overrides"
    if diff /usr/etc/authselect /etc/authselect --suppress-common-lines -r > /dev/null; then
        print_status "$AUTHSELECT_TEST_STRING" "$STATUS_SUCCESS"
    else
        print_status "$AUTHSELECT_TEST_STRING" "$STATUS_FAILURE"
    fi

    CONTAINER_POLICY_TEST_STRING="Ensuring no container policy overrides"
    if diff /usr/etc/containers/policy.json /etc/containers/policy.json > /dev/null && [ ! -f $HOME/.config/containers/policy.json ]; then
        print_status "$CONTAINER_POLICY_TEST_STRING" "$STATUS_SUCCESS"
    else
        print_status "$CONTAINER_POLICY_TEST_STRING" "$STATUS_FAILURE"
    fi

    USBGUARD_TEST_STRING="Ensuring usbguard is active"
    if systemctl is-active --quiet usbguard; then
        print_status "$USBGUARD_TEST_STRING" "$STATUS_SUCCESS"
    else
        print_status "$USBGUARD_TEST_STRING" "$STATUS_FAILURE"
    fi

    CHRONYD_TEST_STRING="Ensuring chronyd is active"
    if systemctl is-active --quiet chronyd; then
        print_status "$CHRONYD_TEST_STRING" "$STATUS_SUCCESS"
    else
        print_status "$CHRONYD_TEST_STRING" "$STATUS_FAILURE"
    fi

    SECUREDNS_TEST_STRING="Ensuring system DNS resolution is secure"
    if systemctl is-active --quiet systemd-resolved; then
        DNSSEC_STATUS="$(cat /etc/systemd/resolved.conf.d/10-securedns.conf | grep "DNSSEC")"
        DOT_STATUS="$(cat /etc/systemd/resolved.conf.d/10-securedns.conf | grep "DNSOverTLS")"
        if [[ "$DNSSEC_STATUS" == "DNSSEC=true" && "$DOT_STATUS" == "DNSOverTLS=true" ]]; then
            print_status "$SECUREDNS_TEST_STRING" "$STATUS_SUCCESS"
        else
            print_status "$SECUREDNS_TEST_STRING" "$STATUS_FAILURE"
        fi
    else
        print_status "$SECUREDNS_TEST_STRING" "$STATUS_FAILURE"
    fi

    BASH_TEST_STRING="Ensuring bash environment lockdown"
    BASH_ENV_FILES=(~/.bashrc ~/.bash_profile)
    all_locked=1

    for file in "${BASH_ENV_FILES[@]}"; do
        if [ -f "$file" ]; then
            if lsattr "$file" 2>/dev/null | awk '{print $1}' | grep -q 'i'; then
                continue
            else
                all_locked=0
                break
            fi
        else
            all_locked=0
            break
        fi
    done

    if [ "$all_locked" -eq 1 ]; then
        print_status "$BASH_TEST_STRING" "$STATUS_SUCCESS"
    else
        print_status "$BASH_TEST_STRING" "$STATUS_FAILURE"
    fi

    WHEEL_TEST_STRING="Ensuring user is not a member of wheel"
    if groups | grep -q "\bwheel\b"; then
        print_status "$WHEEL_TEST_STRING" "$STATUS_FAILURE"
    else
        print_status "$WHEEL_TEST_STRING" "$STATUS_SUCCESS"
    fi

    GNOME_XWAYLAND_TEST_STRING="Ensuring xwayland is disabled for GNOME"
    if [ -f "/etc/systemd/user/org.gnome.Shell@wayland.service.d/override.conf" ]; then
        print_status "$GNOME_XWAYLAND_TEST_STRING" "$STATUS_SUCCESS"
    else
        print_status "$GNOME_XWAYLAND_TEST_STRING" "$STATUS_FAILURE"
    fi

    PLASMA_XWAYLAND_TEST_STRING="Ensuring xwayland is disabled for KDE Plasma"
    if [ -f "/etc/systemd/user/plasma-kwin_wayland.service.d/override.conf" ]; then
        print_status "$PLASMA_XWAYLAND_TEST_STRING" "$STATUS_SUCCESS"
    else
        print_status "$PLASMA_XWAYLAND_TEST_STRING" "$STATUS_FAILURE"
    fi

    SWAY_XWAYLAND_TEST_STRING="Ensuring xwayland is disabled for Sway"
    if [ -f "/etc/sway/config.d/99-noxwayland.conf" ]; then
        print_status "$SWAY_XWAYLAND_TEST_STRING" "$STATUS_SUCCESS"
    else
        print_status "$SWAY_XWAYLAND_TEST_STRING" "$STATUS_FAILURE"
    fi

    EXTENSIONS_TEST_STRING="Ensuring GNOME user extensions are disabled"
    if command -v gnome-shell &> /dev/null; then
        if [ "$(gsettings get org.gnome.shell allow-extension-installation)" = "false" ]; then
            print_status "$EXTENSIONS_TEST_STRING" "$STATUS_SUCCESS"
        else
            print_status "$EXTENSIONS_TEST_STRING" "$STATUS_FAILURE"
        fi
    fi

    SELINUX_TEST_STRING="Ensuring SELinux is in Enforcing mode"
    if [ "$(getenforce)" = "Enforcing" ]; then
        print_status "$SELINUX_TEST_STRING" "$STATUS_SUCCESS"
    else
        print_status "$SELINUX_TEST_STRING" "$STATUS_FAILURE"
    fi

    ENVIRONMENT_TEST_STRING="Ensuring no environment file overrides"
    if diff /usr/etc/environment /etc/environment > /dev/null; then
        print_status "$ENVIRONMENT_TEST_STRING" "$STATUS_SUCCESS"
    else
        print_status "$ENVIRONMENT_TEST_STRING" "$STATUS_WARNING"
    fi

    GHNS_TEST_STRING="Ensuring KDE GHNS is disabled"
    KDE_GLOBALS_FILE="/etc/xdg/kdeglobals"
    if test -e $KDE_GLOBALS_FILE; then
        GHNS_STRING="$(grep 'ghns=false' $KDE_GLOBALS_FILE)"
        if [[ $GHNS_STRING == "ghns=false" ]]; then
            print_status "$GHNS_TEST_STRING" "$STATUS_SUCCESS"
        else
            print_status "$GHNS_TEST_STRING" "$STATUS_FAILURE"
        fi
    fi

    HARDENED_MALLOC_TEST_STRING="Ensuring hardened_malloc is set in ld.so.preload"
    if diff /usr/etc/ld.so.preload /etc/ld.so.preload > /dev/null; then
        print_status "$HARDENED_MALLOC_TEST_STRING" "$STATUS_SUCCESS"
    else
        print_status "$HARDENED_MALLOC_TEST_STRING" "$STATUS_FAILURE"
    fi

    SECUREBOOT_TEST_STRING="Ensuring secure boot is enabled"
    if [ "$(mokutil --sb-state)" == "SecureBoot enabled" ]; then
        print_status "$SECUREBOOT_TEST_STRING" "$STATUS_SUCCESS"
    else
        print_status "$SECUREBOOT_TEST_STRING" "$STATUS_FAILURE"
    fi

    if command -v flatpak &> /dev/null; then
        remotes="$(flatpak remotes -d)"
        while read -r remote ; do
            ref="$(cut -f 1 <<<"$remote")"
            url="$(cut -f 3 <<< "$remote")"
            subset="$(cut -f 5 <<< "$remote")"
            remote_string="Auditing flatpak remote $ref"
            if [[ "$url" != "https://dl.flathub.org/repo/" && "$url" != "https://dl.flathub.org/beta-repo/" ]]; then
                print_status "$remote_string" "$STATUS_FAILURE"
                echo "> $ref is configured with an unknown url!"
            elif [ "$subset" != "verified" ]; then
                print_status "$remote_string" "$STATUS_FAILURE"
                echo "> $ref is not a verified repo!"
            else
                print_status "$remote_string" "$STATUS_SUCCESS"
            fi
        done <<< "$remotes"

        declare -A flatpaks
        while read -r ref version; do
            flatpaks+=(["${ref}"]="${ref}//${version}")
        done < <(flatpak list | sort -k 1 | cut --fields 2,4)

        for f in ${!flatpaks[@]}; do
            warnings=()
            status="$STATUS_SUCCESS"
            fullref=${flatpaks["$f"]}
            permissions=$(flatpak info --show-permissions "$fullref")

            if hasPermission "$permissions" "shared" "network"; then
                [[ "$status" != "$STATUS_FAILURE" ]] && status="$STATUS_WARNING"
                warnings+=("> $f has network access!")
                warnings+=("> To remove it use Flatseal or run:")
                warnings+=("> 'flatpak override -u --unshare=network $f'")
            fi
            if hasPermission "$permissions" "sockets" "x11" && ! hasPermission "$permissions" "sockets" "fallback-x11"; then
                status="$STATUS_FAILURE"
                warnings+=("> $f has x11 access!")
                warnings+=("> To remove it use Flatseal or run:")
                warnings+=("> 'flatpak override -u --nosocket=x11 $f'")
            fi
            if hasPermission "$permissions" "sockets" "session-bus"; then
                [[ "$status" != "$STATUS_FAILURE" ]] && status="$STATUS_WARNING"
                warnings+=("> $f has access to the D-Bus session bus!")
                warnings+=("> To remove it use Flatseal or run:")
                warnings+=("> 'flatpak override -u --nosocket=session-bus $f'")
            fi
            if hasPermission "$permissions" "sockets" "system-bus"; then
                [[ "$status" != "$STATUS_FAILURE" ]] && status="$STATUS_WARNING"
                warnings+=("> $f has access to the D-Bus system bus!")
                warnings+=("> To remove it use Flatseal or run:")
                warnings+=("> 'flatpak override -u --nosocket=system-bus $f'")
            fi
            if ! hasPermission "$permissions" "LD_PRELOAD" .*"/libhardened_malloc.so"; then
                status="$STATUS_FAILURE"
                warnings+=("> $f is not requesting hardened_malloc!")
                warnings+=("> To enable it run:")
                warnings+=("> 'ujust harden-flatpak $f'")
            fi
            if ! hasPermission "$permissions" "filesystems" "host-os:ro"; then
                status="$STATUS_FAILURE"
                warnings+=("> $f is missing host-os:ro permission,")
                warnings+=("> which is needed to load hardened_malloc!")
                warnings+=("> To add it use Flatseal or run:")
                warnings+=("> 'flatpak override -u --filesystem=host-os:ro $f'")
            fi
            if [[ "$bluetooth_loaded" == "true" ]] && hasPermission "$permissions" "features" "bluetooth"; then
                status="$STATUS_FAILURE"
                warnings+=("> $f has bluetooth access!")
                warnings+=("> To remove it use Flatseal or run:")
                warnings+=("> 'flatpak override -u --disallow=bluetooth $f'")
            fi
            if [[ "$ptrace_allowed" == "true" ]] && hasPermission "$permissions" "features" "devel"; then
                status="$STATUS_FAILURE"
                warnings+=("> $f has ptrace access!")
                warnings+=("> To remove it use Flatseal or run:")
                warnings+=("> 'flatpak override -u --disallow=devel $f'")
            fi
            if hasPermission "$permissions" "shared" "ipc"; then
                status="$STATUS_FAILURE"
                warnings+=("> $f has inter-process communications access!")
                warnings+=("> To remove it use Flatseal or run:")
                warnings+=("> 'flatpak override -u --unshare=ipc $f'")
            fi
            if hasPermission "$permissions" "devices" "all"; then
                [[ "$status" != "$STATUS_FAILURE" ]] && status="$STATUS_WARNING"
                warnings+=("> $f has device=all permission,")
                warnings+=("> granting access to GPU, input devices, raw USB, and virtualization,")
                warnings+=("> and introducing a vector for sandbox escapes!")
                warnings+=("> To remove it use Flatseal or run:")
                warnings+=("> 'flatpak override -u --nodevice=all $f'")
                warnings+=("> We recommend you enable device=dri to grant GPU access, if needed by the app")
                warnings+=("> To add GPU access use Flatseal or run:")
                warnings+=("> 'flatpak override -u --device=dri $f'")
            fi
            flatpak_test_string="Auditing $f"
            print_status "$flatpak_test_string" "$status"
            for warning in "${warnings[@]}"; do
                echo "$warning"
            done
        done
    fi
