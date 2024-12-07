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
