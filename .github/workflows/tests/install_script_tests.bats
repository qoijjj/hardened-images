#!/usr/bin/env bats

setup() {
    load 'test_helper/bats-support/load'
    load 'test_helper/bats-assert/load'
}

@test "Script exits with error if rpm-ostree is not installed" {
  run bash "$INSTALL_SCRIPT"  
  assert_output --partial "This script only runs on Fedora Atomic"
  [ "$status" -eq 1 ]
}

@test "Script passes rpm-ostree check if it is installed" {
  run alias rpm-ostree="fake_rpm_ostree_command" && bash "$INSTALL_SCRIPT"
  assert_output --partial "Is this for a server?"
  [ "$status" -eq 1 ]
}
