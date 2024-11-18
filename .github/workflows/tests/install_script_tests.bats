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


@test "Test image name for silverblue-main-userns-hardened" {
  sudo bash -c 'echo "empty file" > /usr/bin/rpm-ostree'
  run bash -c "echo 'no' | bash '$INSTALL_SCRIPT'"
  [ "$status" -eq 0 ]
  [[ "$output" == *"silverblue-main-userns-hardened"* ]]
}

