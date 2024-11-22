#!/usr/bin/env bash

# Tell build process to exit if there are any errors.
set -oue pipefail

just --completions bash | sed -E 's/([\(_" ])just/\1ujust/g' > /usr/share/bash-completion/completions/ujust
