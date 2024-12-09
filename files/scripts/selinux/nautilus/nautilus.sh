#!/usr/bin/env bash

echo "Building and Loading Policy"

set -x

make -f /usr/share/selinux/devel/Makefile nautilus.pp || exit
/usr/sbin/semodule -i nautilus.pp

/sbin/restorecon -F -R -v /usr/bin/nautilus
