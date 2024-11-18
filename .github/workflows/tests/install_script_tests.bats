#!/usr/bin/env bats

@test "Script exits with error if rpm-ostree is not installed" {

  # Run the script and check the output for the error message
  run bash "$INSTALL_SCRIPT"

  # Check if the script outputs the expected error message
  [ "$status" -eq 1 ]
  [[ "$output" == *"This script only runs on Fedora Atomic"* ]]
}
