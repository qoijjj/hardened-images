#!/usr/bin/env bats

@test "Script exits with error if rpm-ostree is not installed" {
  sudo bash -c 'rm -f /usr/bin/rpm-ostree'
  run bash "$INSTALL_SCRIPT"
  [ "$status" -eq 1 ]
  [[ "$output" == *"This script only runs on Fedora Atomic"* ]]
}

@test "Script passes rpm-ostree check if it is installed" {
  sudo bash -c 'echo "empty file" > /usr/bin/rpm-ostree'
  run bash "$INSTALL_SCRIPT"
  [ "$status" -eq 0 ]
  [[ "$output" == *"Welcome to the secureblue interactive installer"* ]]
}

@test "Test command for silverblue-main-userns-hardened" {
  sudo bash -c 'echo "empty file" > /usr/bin/rpm-ostree'
  run bash -c "echo -e 'no\n1\nno\nyes\nno' | bash '$INSTALL_SCRIPT'"
  [ "$status" -eq 0 ]
  [[ "$output" == *"silverblue-main-userns-hardened"* ]]
}

@test "Test command for silverblue-nvidia-userns-hardened" {
  sudo bash -c 'echo "empty file" > /usr/bin/rpm-ostree'
  run bash -c "echo -e 'no\n1\nyes\nno\nyes\nno' | bash '$INSTALL_SCRIPT'"
  [ "$status" -eq 0 ]
  [[ "$output" == *"silverblue-nvidia-userns-hardened"* ]]
}

@test "Test command for silverblue-nvidia-open-userns-hardened" {
  sudo bash -c 'echo "empty file" > /usr/bin/rpm-ostree'
  run bash -c "echo -e 'no\n1\nyes\nyes\nyes\nno' | bash '$INSTALL_SCRIPT'"
  [ "$status" -eq 0 ]
  [[ "$output" == *"silverblue-nvidia-open-userns-hardened"* ]]
}

@test "Test command for silverblue-nvidia-open-hardened" {
  sudo bash -c 'echo "empty file" > /usr/bin/rpm-ostree'
  run bash -c "echo -e 'no\n1\nyes\nyes\no\nno' | bash '$INSTALL_SCRIPT'"
  [ "$status" -eq 0 ]
  [[ "$output" == *"silverblue-nvidia-open-hardened"* ]]
}

@test "Test command for kinoite-main-userns-hardened" {
  sudo bash -c 'echo "empty file" > /usr/bin/rpm-ostree'
  run bash -c "echo -e 'no\n2\nno\nyes\nno' | bash '$INSTALL_SCRIPT'"
  [ "$status" -eq 0 ]
  [[ "$output" == *"kinoite-main-userns-hardened"* ]]
}

@test "Test command for sericea-main-userns-hardened" {
  sudo bash -c 'echo "empty file" > /usr/bin/rpm-ostree'
  run bash -c "echo -e 'no\n3\nno\nyes\nno' | bash '$INSTALL_SCRIPT'"
  [ "$status" -eq 0 ]
  [[ "$output" == *"sericea-main-userns-hardened"* ]]
}

@test "Test command for wayblue-wayfire-main-userns-hardened" {
  sudo bash -c 'echo "empty file" > /usr/bin/rpm-ostree'
  run bash -c "echo -e 'no\n4\nno\nyes\nno' | bash '$INSTALL_SCRIPT'"
  [ "$status" -eq 0 ]
  [[ "$output" == *"wayblue-wayfire-main-userns-hardened"* ]]
}

@test "Test command for wayblue-sway-main-userns-hardened" {
  sudo bash -c 'echo "empty file" > /usr/bin/rpm-ostree'
  run bash -c "echo -e 'no\n5\nno\nyes\nno' | bash '$INSTALL_SCRIPT'"
  [ "$status" -eq 0 ]
  [[ "$output" == *"wayblue-sway-main-userns-hardened"* ]]
}

@test "Test command for wayblue-river-main-userns-hardened" {
  sudo bash -c 'echo "empty file" > /usr/bin/rpm-ostree'
  run bash -c "echo -e 'no\n6\nno\nyes\nno' | bash '$INSTALL_SCRIPT'"
  [ "$status" -eq 0 ]
  [[ "$output" == *"wayblue-river-main-userns-hardened"* ]]
}

@test "Test command for wayblue-hyprland-main-userns-hardened" {
  sudo bash -c 'echo "empty file" > /usr/bin/rpm-ostree'
  run bash -c "echo -e 'no\n7\nno\nyes\nno' | bash '$INSTALL_SCRIPT'"
  [ "$status" -eq 0 ]
  [[ "$output" == *"wayblue-hyprland-main-userns-hardened"* ]]
}

@test "Test command for cosmic-main-userns-hardened" {
  sudo bash -c 'echo "empty file" > /usr/bin/rpm-ostree'
  run bash -c "echo -e 'no\n8\nno\nyes\nno' | bash '$INSTALL_SCRIPT'"
  [ "$status" -eq 0 ]
  [[ "$output" == *"cosmic-main-userns-hardened"* ]]
}

@test "Test command for securecore-zfs-main-userns-hardened" {
  sudo bash -c 'echo "empty file" > /usr/bin/rpm-ostree'
  run bash -c "echo -e 'yes\nyes\nno\nyes\no' | bash '$INSTALL_SCRIPT'"
  [ "$status" -eq 0 ]
  [[ "$output" == *"securecore-zfs-main-userns-hardened"* ]]
}

@test "Test command for securecore-main-userns-hardened" {
  sudo bash -c 'echo "empty file" > /usr/bin/rpm-ostree'
  run bash -c "echo -e 'yes\nno\nno\nyes\no' | bash '$INSTALL_SCRIPT'"
  [ "$status" -eq 0 ]
  [[ "$output" == *"securecore-main-userns-hardened"* ]]
}

