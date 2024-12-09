#!/usr/bin/env bash

echo "Building and Loading Policy"

set -x


make -f /usr/share/selinux/devel/Makefile flatpakfull.pp || exit
/usr/sbin/semodule -i flatpakfull.pp


/sbin/restorecon -F -R -v /usr/bin

/sbin/restorecon -F -R -v /usr/libexec/
