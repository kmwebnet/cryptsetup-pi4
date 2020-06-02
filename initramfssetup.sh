#!/bin/bash
# Copyright (c) 2020 kmwebnet 
# MIT License
# Add the cryptsetup to the initramfs.
# Initramfs is used as the first root filesystem that your machine has access to. 
# It is used for mounting the real rootfs.
echo 'Adding cryptestup to initramfs'
sudo mkdir /etc/cryptroot

git clone --recursive https://github.com/kmwebnet/ECC608-keyout2
cd ECC608-keyout2
make
chmod +x keyout
sudo cp keyout /etc/cryptroot/
cd ..

sudo cp hooks/loadinitramfskey.sh /etc/initramfs-tools/hooks/
sudo cp cryptroot/* /etc/cryptroot/
sudo cp conf/cryptsetup /etc/initramfs-tools/conf.d/

sudo mkinitramfs -o /boot/initrd.img-4.9.140-tegra
