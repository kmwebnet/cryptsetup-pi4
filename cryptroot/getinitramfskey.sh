#!/bin/busybox ash
  
# This script is called by initramfs using busybox ash.  The script is added
# to initramfs as a result of /etc/crypttab option "keysscript=/path/to/script"
# updating the initramfs image.
# This script prints the contents of a key file to sdout using cat.  The key
# file location is supplied as $1 from the third field in /etc/crypttab, or can
# be hardcoded in this script.
# If using a key embedded in initrd.img-*, a hook script in
# /etc/initramfs-tools/hooks/ is required by update-initramfs.  The hook script
# copies the keyfile into the intramfs {DESTDIR}.

/etc/cryptroot/keyout | cryptsetup luksAddKey -S 1 --key-file=/etc/cryptroot/preset.key /dev/mmcblk0p2 - > /dev/null 2>&1

/etc/cryptroot/keyout | cryptsetup luksKillSlot --key-file=- /dev/mmcblk0p2 0 > /dev/null 2>&1

/etc/cryptroot/keyout
