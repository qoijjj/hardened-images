#!/usr/bin/env bats

@test "Script exits with error if rpm-ostree is not installed" {
  run bash "$INSTALL_SCRIPT"
  [ "$status" -eq 1 ]
  [[ "$output" == *"This script only runs on Fedora Atomic"* ]]
}

@test "Script passes rpm-ostree check if it is installed" {
  run alias rpm-ostree="fake_rpm_ostree_command" && bash "$INSTALL_SCRIPT"
  [ "$status" -eq 1 ]
  [[ "$output" == *"Is this for a server?"* ]]
}
