#!/usr/bin/env bats

@test "Script exits with error if rpm-ostree is not installed" {
  run bash "$INSTALL_SCRIPT"
  [ "$status" -eq 1 ]
  [[ "$output" == *"This script only runs on Fedora Atomic"* ]]
}

@test "Script passes rpm-ostree check if it is installed" {
  sudo bash -c 'echo "empty file" > /usr/bin/rpm-ostree'
  run bash "$INSTALL_SCRIPT"
  [ "$status" -eq 1 ]
  [[ "$output" == *"Is this for a server?"* ]]
}
