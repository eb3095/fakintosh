#!/bin/bash

# Fakintosh Installaltion Script
# Version: 1.0
# Author: Eric Benner

# Set the time and date
timedatectl set-ntp true

# Check for UEFI
EFI=false
EFIVARS=/sys/firmware/efi/efivars
if [ -d "$EFIVARS" ]; then
    EFI=true
fi

echo "WARNING: THIS WILL WIPE THE DRIVE"
echo "What drive do you want to install to? (/dev/sda) [ENTER]:"
read drive

# Partition drive
if [ "$EFI" = true ] ; then
  parted --script /dev/vda mklabel gpt
  parted --script /dev/vda mkpart primary fat32 1MiB 261MiB
  parted --script /dev/vda set 1 esp on
  parted --script /dev/vda mkpart primary linux-swap 261MiB 8.5GiB
  parted --script /dev/vda mkpart primary ext4 8.5GiB 100%
  mkfs.vfat -F32 "$drive"1
else
  parted --script $drive mklabel msdos
  parted --script $drive set 1 boot on
  parted --script $drive mkpart primary linux-swap 1MiB 8GiB
  parted --script $drive mkpart primary ext4 8GiB 100%
  mkfs.ext4 -F "$drive"1
fi

# Format drive
mkswap "$drive"2
swapon "$drive"2
mkfs.ext4 -F "$drive"3
mount "$drive"3 /mnt

# Install base
pacstrap /mnt base

# Generate fstab
genfstab -U /mnt >> /mnt/etc/fstab

# Download script
wget https://raw.githubusercontent.com/eb3095/fakintosh/master/fakintosh-chroot-installer.sh
mv fakintosh-chroot-installer.sh /mnt/root/fakintosh-chroot-installer.sh

# Chroot in and run second part
arch-chroot /mnt /root/fakintosh-chroot-installer.sh
