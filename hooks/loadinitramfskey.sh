#!/bin/sh

# This hook script is called by update-initramfs. The script checks for the
# existence of the key file loading script getinitramfskey.sh and copies it
# to initramfs if it's missing.
# This script also copies the key file autounlock.key to the /root/ directory
# of the initramfs. This file is accessed by getinitramfskey.sh, as specified
# in /etc/crypttab.

PREREQ=""

prereqs() {
    echo "$PREREQ"
}

case "$1" in
    prereqs)
        prereqs
        exit 0
    ;;
esac


. "${CONFDIR}/initramfs.conf"
. /usr/share/initramfs-tools/hook-functions

if [ ! -f "${DESTDIR}/lib/cryptsetup/scripts/getinitramfskey.sh" ]; then
    if [ ! -d "${DESTDIR}/lib/cryptsetup/scripts" ]; then
        mkdir -p "${DESTDIR}/lib/cryptsetup/scripts"
    fi
cp /etc/cryptroot/getinitramfskey.sh "${DESTDIR}/lib/cryptsetup/scripts/"
fi
if [ ! -d "${DESTDIR}/etc/cryptroot/" ]; then
    mkdir -p "${DESTDIR}/etc/cryptroot/"
fi
cp /etc/cryptroot/preset.key "${DESTDIR}/etc/cryptroot/"
cp /etc/cryptroot/keyout "${DESTDIR}/etc/cryptroot/"

