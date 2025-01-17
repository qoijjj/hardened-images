# vim: set ft=make :
# Copyright 2024 secureblue
#
# This file includes code from Universal Blue which is licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS"
# BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language
# governing permissions and limitations under the License.

uid := `id -u`
shell := `grep :$(id -u): /etc/passwd | cut -d: -f7`

# Boot into this device's BIOS/UEFI screen
bios:
    #!/usr/bin/bash
    if [ -d /sys/firmware/efi ]; then
      systemctl reboot --firmware-setup
    else
      echo "Rebooting to legacy BIOS from OS is not supported."
    fi

# Show all messages from this boot
logs-this-boot:
    #! /bin/run0 /bin/bash
    journalctl -b 0

# Show all messages from last boot
logs-last-boot:
    #! /bin/run0 /bin/bash
    journalctl -b -1

# Regenerate GRUB config, useful in dual-boot scenarios where a second operating system isn't listed
regenerate-grub:
    #! /bin/run0 /bin/bash
    if [ -d /sys/firmware/efi ]; then
      grub2-mkconfig -o /etc/grub2-efi.cfg
    else
      grub2-mkconfig -o /etc/grub2.cfg
    fi

# Enroll Nvidia driver & KMOD signing key for secure boot - Enter password "universalblue" if prompted
enroll-secure-boot-key:
    run0 mokutil --timeout -1
    echo 'The next line will prompt for a MOK password. Then, input "universalblue"'
    run0 mokutil --import /etc/pki/akmods/certs/akmods-ublue.der
    echo 'At next reboot, the mokutil UEFI menu UI will be displayed (*QWERTY* keyboard input and navigation).\nThen, select "Enroll MOK", and input "universalblue" as the password'

# Toggle display of the user-motd in terminal
toggle-user-motd:
    #!/usr/bin/bash
    if test -e "${HOME}/.config/no-show-user-motd"; then
      rm -f "${HOME}/.config/no-show-user-motd"
    else
      if test ! -d "${HOME}/.config"; then
        mkdir "${HOME}/.config"
      fi
      touch "${HOME}/.config/no-show-user-motd"
    fi

# Update device firmware
[no-exit-message]
update-firmware:
    fwupdmgr refresh --force
    fwupdmgr get-updates
    fwupdmgr update

# Clean up old up unused podman images, volumes, flatpak packages and rpm-ostree content
clean-system:
    #!/usr/bin/bash
    podman image prune -af
    podman volume prune -f
    flatpak uninstall --unused
    rpm-ostree cleanup -bm

# Check for local overrides
check-local-overrides:
    #!/usr/bin/bash
    diff -r \
      --suppress-common-lines \
      --color="always" \
      --exclude "passwd*" \
      --exclude "group*" \
      --exclude="subgid*" \
      --exclude="subuid*" \
      --exclude="machine-id" \
      --exclude="adjtime" \
      --exclude="fstab" \
      --exclude="system-connections" \
      --exclude="shadow*" \
      --exclude="gshadow*" \
      --exclude="ssh_host*" \
      --exclude="cmdline" \
      --exclude="crypttab" \
      --exclude="hostname" \
      --exclude="localtime" \
      --exclude="locale*" \
      --exclude="*lock" \
      --exclude=".updated" \
      --exclude="*LOCK" \
      --exclude="vconsole*" \
      --exclude="00-keyboard.conf" \
      --exclude="grub" \
      --exclude="system.control*" \
      --exclude="cdi" \
      --exclude="default.target" \
      /usr/etc /etc 2>/dev/null | sed '/Binary\ files\ /d'

# Debug dump pastebin for issue reporting
debug-info:
    #!/usr/bin/bash
    rpm_ostree_status=$(echo -e "=== Rpm-Ostree Status ===\n"; rpm-ostree status --verbose)
    sysinfo=$(echo -e "\n"; fpaste --sysinfo --printonly)
    flatpaks=$(echo "=== Flatpaks Installed ==="; flatpak list --columns=application,version,options)
    audit_results=$(echo -e "\n=== Audit Results ===\n"; ujust audit-secureblue)
    local_overrides=$(echo -e "\n=== Listing Local Overrides ===\n"; ujust check-local-overrides)
    recent_events=$(echo -e "\n=== Recent System Events ===\n"; journalctl -b -p err..alert --since "1 hour ago")
    failed_services=$(echo -e "\n=== Failed Services ===\n"; systemctl list-units --state=failed)
    content="$rpm_ostree_status$sysinfo$flatpaks$audit_results$local_overrides$recent_events$failed_services"
    echo "$content" | fpaste --confirm --private=1

# Rerun Yafti
rerun-yafti:
    yafti -f /usr/share/ublue-os/firstboot/yafti.yml

alias assemble := distrobox-assemble

# Create distroboxes from a defined manifest
distrobox-assemble CONTAINER="prompt" ACTION="create" FILE="/etc/distrobox/distrobox.ini":
    #!/usr/bin/bash
    # Distroboxes are gathered from distrobox.ini, please add them there
    source /usr/lib/ujust/ujust.sh
    AssembleList {{ FILE }} {{ ACTION }} {{ CONTAINER }}

# Create toolbox containers from a defined manifest (this spec will not be expanded)
toolbox-assemble CONTAINER="prompt" ACTION="create" FILE="/etc/toolbox/toolbox.ini":
    #!/usr/bin/bash
    # Toolboxes are gathered from toolbox.ini, please add them there
    source /usr/lib/ujust/ujust.sh
    ToolboxAssembleList {{ FILE }} {{ ACTION }} {{ CONTAINER }}

# Run a non-flatpak application with standard memory allocator (needs an argument!)
with-standard-malloc APP:
    #!/usr/bin/bash
    bwrap --dev-bind / / --ro-bind /dev/null /etc/ld.so.preload {{ APP }}

# Add the unfiltered Flathub flatpak repo
enable-flathub-unfiltered:
    #!/usr/bin/bash
    flatpak remote-add --if-not-exists --user flathub https://flathub.org/repo/flathub.flatpakrepo

# search for an installed SELinux module
semodule-check MODULE:
    #! /bin/run0 /bin/bash
    if [ -n "$( semodule -l | grep {{ MODULE }} )" ] ; then
        semodule -l | grep {{ MODULE }}
    fi

# Install Steam via choice of 3 methods
install-steam:
    #!/usr/bin/bash
    if [ -z "$(pgrep Xwayland)" ] && [ -z "$(pgrep Xorg)" ] ; then
        echo "Steam requires X or Xwayland, which your variant of secureblue has disabled by default."
        echo "Please run 'ujust toggle-xwayland' to re-enable it."
        toggle_xwayland_now=""
        read -p "Would you like to run 'ujust toggle-xwayland' now? [Y/n] " toggle_xwayland_now
        toggle_xwayland_now=${toggle_xwayland_now:-y}
        if [[ "$toggle_xwayland_now" == [Yy]* ]]; then
            echo "Running 'ujust toggle-xwayland'"
            ujust toggle-xwayland
            reboot_now=""
            read -p "Would you like to reboot now? [y/N] " reboot_now
            if [[ "$reboot_now" == [Yy]* ]]; then
                echo "Rebooting"
                systemctl reboot
            fi
        fi
    fi
    valid_input="0"
    method_selection=""
    echo "Please select a method to install steam:"
    echo "    1) Flatpak - will install the steam flatpak from flathub-unverified"
    echo "    2) Distrobox - will set up steam via the bazzite-arch distrobox image"
    while [[ "$valid_input" == "0" ]]; do
        read -p "Selection [1-2]: " method_selection
        if [[ "$method_selection" == [12]* ]]; then
            valid_input="1"
        else
            echo "That is not a valid selection."
        fi
    done

    echo "" # blank space
    case "$method_selection" in
        1)
            echo "Flatpak method selected."
            echo "Enabling the unfiltered Flathub repo."
            ujust enable-flathub-unfiltered
            echo "Installing Steam flatpak."
            flatpak install -y flathub com.valvesoftware.Steam
            echo "Disabling hardened_malloc for Steam."
            flatpak override --user --unset-env=LD_PRELOAD --nofilesystem=host-os com.valvesoftware.Steam
            ;;
        2)
            echo "Distrobox method selected."
            if [ -n "$(ujust semodule-check harden_container_userns)" ] ; then
                echo "Distrobox requires that secureblue's harden-container-userns module be disabled"
                echo "Please run 'ujust toggle-container-domain-userns-creation'"
                container_userns_now=""
                read -p "Would you like to run 'ujust toggle-container-domain-userns-creation' now? [Y/n] " container_userns_now
                container_userns_now=${container_userns_now:-y}
                if [[ "$container_userns_now" == [Yy]* ]]; then
                    echo "Running 'ujust toggle-container-domain-userns-creation'"
                    ujust toggle-container-domain-userns-creation
                fi
            fi
            echo "Creating bazzite-arch distrobox."
            distrobox-create --unshare-netns --nvidia --image ghcr.io/ublue-os/bazzite-arch --name bazzite-arch -Y
            echo "Exporting Steam from bazzite-arch distrobox."
            distrobox-enter -n bazzite-arch -- distrobox-export --app steam
            ;;
    esac

    echo "Steam requires support for 32-bit processes/syscalls."
    if [ -n "$(rpm-ostree kargs | grep 'ia32_emulation=0')" ] ; then
        echo "This script will now remove the 'ia32_emulation=0' kernel argument."
        rpm-ostree kargs --delete-if-present="ia32_emulation=0"
    else
        echo "Do not set the 'ia32_emulation=0' kernel argument."
    fi

# Install the official docker packages
install-docker:
    #! /bin/run0 /bin/bash
    curl -Lo /etc/yum.repos.d/docker-ce.repo https://download.docker.com/linux/fedora/docker-ce.repo
    rpm-ostree refresh-md
    rpm-ostree install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Uninstall the official docker packages
uninstall-docker:
    #! /bin/run0 /bin/bash
    rm /etc/yum.repos.d/docker-ce.repo
    rpm-ostree refresh-md
    rpm-ostree uninstall docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Rebase to a different secureblue Desktop Environment/Atomic Desktop
rebase-secureblue:
    #!/usr/bin/bash
    /usr/bin/bash /usr/share/secureblue/install_secureblue.sh
# Setup and configure virtualization and vfio
setup-virtualization ACTION="":
    # NOTE: all ROOT_SECTIONs are set at 4 spaces indentation because <<-ROOT_SECTION only ignores tab indents and not spaces, and this script can't be set to tabs while the rest of the file is spaces, nor can some lines be tabs and some spaces
    #!/usr/bin/bash
    source /usr/lib/ujust/ujust.sh
    if [ "$(systemctl is-enabled libvirtd.service)" == "disabled" ]; then
      echo "${b}libvirtd${n} service is ${red}disabled${n}!"
      echo "${green}enabling${n} and starting libvirtd"
      echo "If virt-manager says libvirtd.sock is not available after a big update, re-run this command."
      systemctl enable --now libvirtd 2> /dev/null
      echo "Press ESC if you want to exit and do not need to do anything"
    fi
    OPTION={{ ACTION }}
    if [ "$OPTION" == "help" ]; then
      echo "Usage: ujust setup-virtualization <option>"
      echo "  <option>: Specify the quick option to skip the prompt"
      echo "  Use 'virt-on' to select Enable Virtualization"
      echo "  Use 'virt-off' to select Disable Virtualization"
      echo "  Use 'group' to select Add $USER to libvirt group"
      echo "  Use 'vfio-on' to select Enable VFIO drivers"
      echo "  Use 'vfio-off' to select Disable VFIO drivers"
      echo "  Use 'kvmfr' to select Autocreate Looking-Glass shm"
      exit 0
    elif [ "$OPTION" == "" ]; then
      echo "${bold}Virtualization Setup${normal}"
      echo "NOTE: Enabling Virtualization will install virt-manager and set kernel args"
      echo "WARNING: This recipe will ask for your password multiple times"
      OPTION=$(Choose \
        "Enable Virtualization" \
        "Disable Virtualization" \
        "Add $USER to libvirt group" \
        "Enable VFIO drivers" \
        "Disable VFIO drivers" \
        "Enable kvmfr module" \
        "Install looking-glass" \
      )
    fi

    # Enable Virtualization option
    if [[ "${OPTION,,}" =~ (^enable[[:space:]]virtualization|virt-on) ]]; then
        if ! rpm -q virt-manager | grep -P "^virt-manager-" 1>/dev/null; then
          echo "Choose how to install virt-manager"
          METHOD=$(Choose \
              "Flatpak" \
              "Layered package" \
              )
          if [ "$METHOD" == "Flatpak" ]; then
               flatpak install flathub-verified org.virt_manager.virt-manager --noninteractive
          fi

          run0 <<ROOT_SECTION
            if [ "$METHOD" == "Layered package" ]; then
                 rpm-ostree install virt-manager libvirt qemu qemu-kvm virt-viewer
            fi
            rpm-ostree kargs \
            --append-if-missing="kvm.ignore_msrs=1" \
            --append-if-missing="kvm.report_ignored_msrs=0"
            echo "Making sure swtpm will work"
            if [ ! -d "/var/lib/swtpm-localca" ]; then
              mkdir /var/lib/swtpm-localca
            fi
            chown tss /var/lib/swtpm-localca
            if test ! -f "/etc/libvirt/hooks/qemu"; then
              echo "Adding libvirt qemu hooks"
              wget "https://raw.githubusercontent.com/PassthroughPOST/VFIO-Tools/master/libvirt_hooks/qemu" -O /etc/libvirt/hooks/qemu
              chmod +x /etc/libvirt/hooks/qemu
              grep -A1 -B1 "# Add" /etc/libvirt/hooks/qemu | sed "s/^# //g"
              if test ! -d "/etc/libvirt/hooks/qemu.d"; then
                mkdir /etc/libvirt/hooks/qemu.d
              fi
            fi
            systemctl enable libvirtd-setup.service \
    ROOT_SECTION

            && echo "libvirtd will be enabled at next reboot"
          echo 'Please reboot to apply changes'
        fi

    # Disable Virtualization option
    elif [[ "${OPTION,,}" =~ (^disable[[:space:]]virtualization|virt-off) ]]; then

    # Root
      run0 <<ROOT_SECTION
        if [ "$(systemctl is-enabled libvirtd.service)" == "enabled" ]; then
          echo "${red}Disabling${n} libvirtd before removal"
          systemctl disable --now libvirtd 2> /dev/null
        fi
        if [ "$(systemctl is-enabled libvirtd-setup.service)" == "enabled" ]; then
          echo "${red}Disabling${n} libvirtd-setup"
          systemctl disable --now libvirtd-setup.service 2> /dev/null
        fi
        echo "Removing virt-manager..."
        layered_installed=$(rpm -q virt-manager)
        if [ "$layered_installed" != "package virt-manager is not installed" ]; then
          rpm-ostree uninstall virt-manager libvirt qemu qemu-kvm virt-viewer
        fi
        rpm-ostree kargs \
        --delete-if-present="kvm.ignore_msrs=1" \
        --delete-if-present="kvm.report_ignored_msrs=0"
    ROOT_SECTION

      # Non-root
      flatpak_installed=$(flatpak list | grep org.virt_manager.virt-manager)
      if [ "$flatpak_installed" != "" ]; then
        flatpak uninstall org.virt_manager.virt-manager
      fi
      echo 'Please reboot to apply changes'

    # Enable VFIO Drivers
    elif [[ "${OPTION,,}" =~ (^enable[[:space:]]vfio|vfio-on) ]]; then
      echo "Enabling VFIO..."
      VIRT_TEST=$(rpm-ostree kargs)
      CPU_VENDOR=$(grep "vendor_id" "/proc/cpuinfo" | uniq | awk -F": " '{ print $2 }')
      VENDOR_KARG="unset"

      run0 --setenv=VIRT_TEST --setenv=CPU_VENDOR --setenv=VENDOR_KARG <<ROOT_SECTION
        if [[ ${VIRT_TEST} == *kvm.report_ignored_msrs* ]]; then
          rpm-ostree initramfs --enable
          if [[ ${CPU_VENDOR} == "AuthenticAMD" ]]; then
            VENDOR_KARG="amd_iommu=on"
          elif [[ ${CPU_VENDOR} == "GenuineIntel" ]]; then
            VENDOR_KARG="intel_iommu=on"  
          fi
          if [[ ${VENDOR_KARG} == "unset" ]]; then
            echo "Failed to get CPU vendor, exiting..."
            exit 1
          else
            rpm-ostree kargs \
              --append-if-missing="${VENDOR_KARG}" \
              --append-if-missing="iommu=pt" \
              --append-if-missing="rd.driver.pre=vfio-pci" \
              --append-if-missing="vfio_pci.disable_vga=1"
            echo "VFIO will be enabled on next boot, make sure you enable IOMMU, VT-d or AMD-v in your BIOS!"
            echo "Please understand that since this is such a niche use case, support will be very limited!"
            echo 'Use the command "ls-iommu -grk" to get iommu information about your GPUs, use the "--help" flag for more options'
            echo ""
            echo "${b}Systems with multiple GPUs${n}"
            echo "Bind your unused/second GPU device ids to the vfio driver by running"
            echo 'rpm-ostree kargs --append-if-missing="vfio_pci.ids=xxxx:yyyy,xxxx:yyzz"'
            echo "You will require a $(Urllink "https://www.amazon.com/s?k=hdmi+displayport+dummy+plug" "Dummy HDMI/DisplayPort plug (Ghost Adapter)") or hook the GPU"
            echo "to a separate monitor input in order to turn the GPU on when starting the VM."
            echo "NOTE: Your second GPU should be as different as possible from your main GPU and will not be usable by the host after you bind it to the vfio driver!"
            echo ""
            echo "${b}Systems with 1 GPU${n}"
            echo "Once rebooted you can continue setting up whatever scripts and hooks you need"
            echo "to get Single GPU passthrough working, however ${u}you will be on your own${n}."
            echo "${b}Do not ask for support for setting up Single GPU Passthrough, we can not help you!${n}"
          fi
        fi
      ROOT_SECTION

    # Disable VFIO
    elif [[ "${OPTION,,}" =~ (^disable[[:space:]]vfio|vfio-off) ]]; then
      echo ""
      echo "Make sure you have ${b}disabled autostart of all VMs using VFIO${n} before continuing!"
      CONFIRM=$(Choose Cancel Continue)
      if [ "$CONFIRM" == "Continue" ]; then
        echo "Disabling VFIO..."
        VFIO_IDS="$(rpm-ostree kargs | sed -E 's/.+(vfio_pci.ids=.+\s)/\1/' | awk '{ print $1 }' | grep vfio_pci.ids)"
        VFIO_IDS_KARG=""
        if [ -n "$VFIO_IDS" ]; then
          echo "Found VFIO ids in kargs, adding the below line to removal list"
          echo "$VFIO_IDS"
          VFIO_IDS_KARG="--delete-if-present=\"$VFIO_IDS\""
        fi
        KVMFR_VAL="$(rpm-ostree kargs | sed -E 's/.+(kvmfr.static_size_mb=.+\s)/\1/' | awk '{ print $1 }' | grep kvmfr.static_size_mb)"
        KVMFR_KARG=""
        if [ -n "$KVMFR_VAL" ]; then
          echo "Found KVMFR static_size_mb in kargs, adding the below line to removal list"
          echo "$KVMFR_VAL"
          KVMFR_KARG="--delete-if-present=\"$KVMFR_VAL\""
        fi
        echo "Removing deprecated dracut modules"

        # Root section
        run0 --setenv=VFIO_IDS_KARG --setenv=KVMFR_KARG <<ROOT_SECTION
          rm /etc/dracut.conf.d/vfio.conf
          rm /etc/modprobe.d/kvmfr.conf
          rpm-ostree kargs \
          --delete-if-present="iommu=pt" \
          --delete-if-present="iommu=on" \
          --delete-if-present="amd_iommu=on" \
          --delete-if-present="intel_iommu=on" \
          --delete-if-present="rd.driver.pre=vfio-pci" \
          --delete-if-present="vfio_pci.disable_vga=1" \
          --delete-if-present="vfio_pci.disable_vga=0" \
          $VFIO_IDS_KARG \
          $KVMFR_KARG
    ROOT_SECTION

      fi

    # Enable kvmfr
    elif [[ "${OPTION,,}" =~ kvmfr ]]; then
      echo "$(Urllink "https://looking-glass.io/docs/rc/ivshmem_kvmfr/#libvirt" "This module") along with $(Urllink "https://looking-glass.io" "Looking Glass") is very experimental and not recommended for production use!"
      echo "The ublue team packages the kvmfr module only because it has to be supplied with the system image while using an atomic desktop."
      echo "To use the kvmfr module after enabling it, just add and edit the xml for libvirt from the documentation in the first link."
      CONFIRM=$(Choose Ok Cancel)
      if [ "$CONFIRM" == "Cancel" ]; then
        exit 0
      fi
      echo ""
      echo "Setting up kvmfr module so it loads next boot"

      run0 <<ROOT_SECTION
      if [ -f "/etc/modprobe.d/kvmfr.conf" ]; then
        echo "Re-creating dummy kvmfr modprobe file"
        rm /etc/modprobe.d/kvmfr.conf
      fi
      cat << KVMFR_MODPROBE > /etc/modprobe.d/kvmfr.conf
    # This is a dummy file and changing it does nothing
    # If you want to change the kvmfr static_size_mb
    # Run "rpm-ostree kargs --replace=kvmfr.static_size_mb=oldvalue=newvalue"
    # Default value set by us is 128 which is enough for 4k SDR
    # Find the current value by running "rpm-ostree kargs"
    KVMFR_MODPROBE
      rpm-ostree kargs --append-if-missing="kvmfr.static_size_mb=128"
      if [ -f "/etc/udev/rules.d/99-kvmfr.rules" ]; then
        echo "Re-creating kvmfr udev rules"
        rm /etc/udev/rules.d/99-kvmfr.rules
      fi
      echo "Adding udev rule for /dev/kvmfr0"
      cat << KVMFR_UDEV > /etc/udev/rules.d/99-kvmfr.rules
    SUBSYSTEM=="kvmfr", OWNER="'$USER'", GROUP="qemu", MODE="0660"
    KVMFR_UDEV
      echo "Adding /dev/kvmfr0 to qemu cgroup_device_acl"
      run0 perl -0777 -pi -e 's/
    #cgroup_device_acl = \[
    #    "\/dev\/null", "\/dev\/full", "\/dev\/zero",
    #    "\/dev\/random", "\/dev\/urandom",
    #    "\/dev\/ptmx", "\/dev\/kvm",
    #    "\/dev\/userfaultfd"
    #\]
    /
    cgroup_device_acl = \[
        "\/dev\/null", "\/dev\/full", "\/dev\/zero",
        "\/dev\/random", "\/dev\/urandom",
        "\/dev\/ptmx", "\/dev\/kvm",
        "\/dev\/userfaultfd", "\/dev\/kvmfr0"
    \]
    /' /etc/libvirt/qemu.conf
      echo "Adding SELinux context record for /dev/kvmfr0"
      semanage fcontext -a -t svirt_tmpfs_t /dev/kvmfr0
      echo "Adding SELinux access rules for /dev/kvmfr0"
      if [ ! -d "$HOME/.config/selinux_te/mod" ]; then
        mkdir -p "$HOME/.config/selinux_te/mod"
      fi
      if [ ! -d "$HOME/.config/selinux_te/pp" ]; then
        mkdir -p "$HOME/.config/selinux_te/pp"
      fi
      bash -c "cat << KVMFR_SELINUX > $HOME/.config/selinux_te/kvmfr.te
    module kvmfr 1.0;

    require {
        type device_t;
        type svirt_t;
        class chr_file { open read write map };
    }

    #============= svirt_t ==============
    allow svirt_t device_t:chr_file { open read write map };
    KVMFR_SELINUX"
      echo "This is the type enforcement we wrote for SELinux and you can find it in $HOME/.config/selinux_te/kvmfr.te"
      echo "#======= start of kvmfr.te ======="
      cat "$HOME/.config/selinux_te/kvmfr.te"
      echo "#======== end of kvmfr.te ========"
      checkmodule -M -m -o "$HOME/.config/selinux_te/mod/kvmfr.mod" "$HOME/.config/selinux_te/kvmfr.te"
      semodule_package -o "$HOME/.config/selinux_te/pp/kvmfr.pp" -m "$HOME/.config/selinux_te/mod/kvmfr.mod"
      run0 semodule -i "$HOME/.config/selinux_te/pp/kvmfr.pp"
      echo "Loading kvmfr module so you do not have to reboot to use it the first time"
      modprobe kvmfr static_size_mb=128
      chown $USER:qemu /dev/kvmfr0
      echo ""
      echo "Kvmfr0 $(Urllink "https://looking-glass.io/docs/B7-rc1/install_libvirt/#determining-memory" "static size is set to 128mb by default")"
      echo "this will work with up to 4K SDR resolutiion, as most dummy plugs go up to 4K"
      echo "some games will try use the adapters max resolution on first boot and cause issues if the value is too low."
      echo "Most ghost display adapters max out at 4k, hence the default value of 128mb."
      echo ""
      echo "If you need to change it to a different value"
      echo "you can do that by running \"rpm-ostree kargs --replace=kvmfr.static_size_mb=128=newvalue\""
      echo "You can check the current kernel arguments with \"rpm-ostree kargs\""
      echo "$(Urllink "https://looking-glass.io/docs/rc/ivshmem_kvmfr/#libvirt" "Please read official documentation for kvmfr for how to use it")"
      echo "${b}NOTE: You can start using kvmfr right now without rebooting if you already rebooted after enabling VFIO.${n}"
      CONFIRM=$(Choose OK)
    elif [[ "${OPTION,,}" =~ group ]]; then
      if ! grep -q "^libvirt" /etc/group; then
        grep '^libvirt' /usr/lib/group | tee -a /etc/group > /dev/null
      fi
      usermod -aG libvirt $USER
    ROOT_SECTION

    # Install looking-glass
    elif [ "$OPTION" == "Install looking-glass" ]; then
      run0 <<ROOT_SECTION
      curl -fsSL https://copr.fedorainfracloud.org/coprs/pgaskin/looking-glass-client/repo/fedora-41/pgaskin-looking-glass-client-fedora-41.repo | tee /etc/yum.repos.d/_copr_pgaskin-looking-glass-client.repo
      rpm-ostree refresh-md
      rpm-ostree install looking-glass-client
    ROOT_SECTION
    fi
