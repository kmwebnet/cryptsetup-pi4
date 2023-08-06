#!/bin/bash
# Copyright (c) 2023 kmwebnet 
# MIT License
# Add the cryptsetup to the initramfs.
# Initramfs is used as the first root filesystem that your machine has access to. 
# It is used for mounting the real rootfs.
echo 'Adding cryptestup to initramfs'


sudo mkdir /etc/cryptroot

git clone --recursive https://github.com/kmwebnet/ecc608-keyout-pi4.git
cd ecc608-keyout-pi4
make
chmod +x keyout
sudo cp keyout /etc/cryptroot/
cd ..

sudo cp hooks/loadinitramfskey.sh /etc/initramfs-tools/hooks/
sudo cp cryptroot/* /etc/cryptroot/
sudo cp conf/cryptsetup /etc/initramfs-tools/conf.d/

sudo update-initramfs -c -k `uname -r`
current_release=$(uname -r)

#find necessary modules and add to /etc/initramfs-tools/modules
FILE="/etc/initramfs-tools/modules"
SEARCH_FOR="dm-crypt"

# Use && to check if grep found string
if ! grep -q $SEARCH_FOR "$FILE"; then
    sudo sh -c "echo 'dm-crypt' >> /etc/initramfs-tools/modules"
fi

SEARCH_FOR="i2c-dev"
# Use && to check if grep found string
if ! grep -q $SEARCH_FOR "$FILE"; then
    sudo sh -c "echo 'i2c-dev' >> /etc/initramfs-tools/modules"
fi

#find initramfs strings in /boot/config.txt and replace with new version
FILE="/boot/config.txt"
SEARCH_FOR="initramfs"

# Check if the file exists
if [ ! -f $FILE ]; then
    echo "$FILE does not exist."
    exit 1
fi

# Check if the file is readable
if [ ! -r $FILE ]; then
    echo "$FILE is not readable."
    exit 2
fi

# Use && to check if grep found string
if grep -q $SEARCH_FOR "$FILE"; then
    echo "Found $SEARCH_FOR in $FILE"
    sudo sed -i "/$SEARCH_FOR/d" "$FILE"
    sudo sh -c "echo 'initramfs initrd.img-$current_release followkernel' >> /boot/config.txt"
else
    sudo sh -c "echo 'initramfs initrd.img-$current_release followkernel' >> /boot/config.txt"
fi

FILE="/boot/cmdline.txt.old"

if [ ! -f "$FILE" ]; then
    sudo cp /boot/cmdline.txt /boot/cmdline.txt.old
fi

sudo echo "cryptdevice=PARTUUID=$(blkid -s PARTUUID -o value /dev/mmcblk0p2):luks cryptopts=keyscript=/lib/cryptsetup/scripts/getinitramfskey.sh,source=/dev/mmcblk0p2,target=luks root=/dev/mapper/luks rootfstype=ext4 elevator=deadline fsck.repair=yes rootwait quiet splash plymouth.ignore-serial-consoles" > /boot/cmdline.txt
