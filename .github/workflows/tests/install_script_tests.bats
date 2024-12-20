#!/usr/bin/env bats

setup() {
    sudo snap install distrobox --edge --devmode
    distrobox create --image quay.io/fedora-ostree-desktops/base-atomic:41 -Y
    distrobox-enter -n base-atomic-41 -- '  distrobox-export --app rpm-ostree'
}

@test "Script exits with error if rpm-ostree is not installed" {
  sudo bash -c 'mv /usr/bin/rpm-ostree /usr/bin/rpm-ostree.backup'
  run bash "$INSTALL_SCRIPT"
  [ "$status" -eq 1 ]
  [[ "$output" == *"This script only runs on Fedora Atomic"* ]]
  sudo bash -c 'mv /usr/bin/rpm-ostree.backup /usr/bin/rpm-ostree'
}

@test "Script passes rpm-ostree check if it is installed" {
  run bash "$INSTALL_SCRIPT"
  [ "$status" -eq 0 ]
  [[ "$output" == *"Welcome to the secureblue interactive installer"* ]]
}

@test "Test command for silverblue-main-hardened" {
  run bash -c "echo -e 'no\n1\nno\nno' | bash '$INSTALL_SCRIPT'"
  [ "$status" -eq 0 ]
  [[ "$output" == *"silverblue-main-hardened"* ]]
}

@test "Test command for silverblue-nvidia-hardened" {
  run bash -c "echo -e 'no\n1\nyes\nno\nno' | bash '$INSTALL_SCRIPT'"
  [ "$status" -eq 0 ]
  [[ "$output" == *"silverblue-nvidia-hardened"* ]]
}


@test "Test command for silverblue-nvidia-open-hardened" {
  run bash -c "echo -e 'no\n1\nyes\nyes\no\nno' | bash '$INSTALL_SCRIPT'"
  [ "$status" -eq 0 ]
  [[ "$output" == *"silverblue-nvidia-open-hardened"* ]]
}

@test "Test command for kinoite-main-hardened" {
  run bash -c "echo -e 'no\n2\nno\nno' | bash '$INSTALL_SCRIPT'"
  [ "$status" -eq 0 ]
  [[ "$output" == *"kinoite-main-hardened"* ]]
}

@test "Test command for sericea-main-hardened" {
  run bash -c "echo -e 'no\n3\nno\nno' | bash '$INSTALL_SCRIPT'"
  [ "$status" -eq 0 ]
  [[ "$output" == *"sericea-main-hardened"* ]]
}

@test "Test command for wayblue-wayfire-main-hardened" {
  run bash -c "echo -e 'no\n4\nno\nno' | bash '$INSTALL_SCRIPT'"
  [ "$status" -eq 0 ]
  [[ "$output" == *"wayblue-wayfire-main-hardened"* ]]
}

@test "Test command for wayblue-sway-main-hardened" {
  run bash -c "echo -e 'no\n5\nno\nno' | bash '$INSTALL_SCRIPT'"
  [ "$status" -eq 0 ]
  [[ "$output" == *"wayblue-sway-main-hardened"* ]]
}

@test "Test command for wayblue-river-main-hardened" {
  run bash -c "echo -e 'no\n6\nno\nno' | bash '$INSTALL_SCRIPT'"
  [ "$status" -eq 0 ]
  [[ "$output" == *"wayblue-river-main-hardened"* ]]
}

@test "Test command for wayblue-hyprland-main-hardened" {
  run bash -c "echo -e 'no\n7\nno\nno' | bash '$INSTALL_SCRIPT'"
  [ "$status" -eq 0 ]
  [[ "$output" == *"wayblue-hyprland-main-hardened"* ]]
}

@test "Test command for cosmic-main-hardened" {
  run bash -c "echo -e 'no\n8\nno\nno' | bash '$INSTALL_SCRIPT'"
  [ "$status" -eq 0 ]
  [[ "$output" == *"cosmic-main-hardened"* ]]
}

@test "Test command for securecore-zfs-main-hardened" {
  run bash -c "echo -e 'yes\nyes\nno\no' | bash '$INSTALL_SCRIPT'"
  [ "$status" -eq 0 ]
  [[ "$output" == *"securecore-zfs-main-hardened"* ]]
}

@test "Test command for securecore-main-hardened" {
  run bash -c "echo -e 'yes\nno\nno\no' | bash '$INSTALL_SCRIPT'"
  [ "$status" -eq 0 ]
  [[ "$output" == *"securecore-main-hardened"* ]]
}

