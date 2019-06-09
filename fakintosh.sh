#!/bin/bash

# Fakintosh Installaltion Script
# Version: 1.0
# Author: Eric Benner

timedatectl set-ntp true

EFI=false
EFIVARS=/sys/firmware/efi/efivars
if [ -d "$EFI" ]; then
    EFI=true
fi

echo "WARNING: THIS WILL WIPE THE DRIVE"
echo "What drive do you want to install to? (/dev/sda) [ENTER]:"
read DRIVE

if [ "$EFI" = true ] ; then
  parted --script $drive mklabel gpt
  parted --script $drive mkpart primary fat32 1MiB 261MiB
  parted --script $drive set 1 esp on
  parted --script $drive mkpart primary linux-swap 261MiB 8.5GiB
  parted --script $drive mkpart primary ext4 8.5GiB 100%
  mkfs.fat -F32 "$drive"1
else
  parted --script $drive mklabel msdos
  parted --script $drive mkpart primary ext4 1MiB 100MiB
  parted --script $drive set 1 boot on
  parted --script $drive mkpart primary linux-swap 100MiB 8.2GiB
  parted --script $drive mkpart primary ext4 8.2GiB 100%
  mkfs.ext4 "$drive"1
fi

mkswap "$drive"2
swapon "$drive"2
mkfs.ext4 "$drive"3
mount "$drive"3 /mnt

if [ "$EFI" = true ] ; then
  mkdir /mnt/efi
  mount "$drive"1 /mnt/efi
else
  mkdir /mnt/boot
  mount "$drive"1 /mnt/boot
fi

pacstrap /mnt base
genfstab -U /mnt >> /mnt/etc/fstab

# Get second part of the installer
wget 
mv fakintosh-chroot-installer.sh /mnt/root/fakintosh-chroot-installer.sh
arch-chroot /mnt /mnt/root/fakintosh-chroot-installer.sh
