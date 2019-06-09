#!/bin/bash

# Fakintosh Installaltion Script
# Version: 1.0
# Author: Eric Benner

# Set the time and date
timedatectl set-ntp true

# Check for UEFI
EFI=false
EFIVARS=/sys/firmware/efi/efivars
if [ -d "$EFI" ]; then
    EFI=true
fi

echo "WARNING: THIS WILL WIPE THE DRIVE"
echo "What drive do you want to install to? (/dev/sda) [ENTER]:"
read DRIVE

# Partition drive
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

# Format drive
mkswap "$drive"2
swapon "$drive"2
mkfs.ext4 "$drive"3
mount "$drive"3 /mnt

# Mount drive
if [ "$EFI" = true ] ; then
  mkdir /mnt/efi
  mount "$drive"1 /mnt/efi
else
  mkdir /mnt/boot
  mount "$drive"1 /mnt/boot
fi

# Install base
pacstrap /mnt base

# Generate fstab
genfstab -U /mnt >> /mnt/etc/fstab

# Download script
wget https://raw.githubusercontent.com/eb3095/fakintosh/master/fakintosh-chroot-installer.sh
mv fakintosh-chroot-installer.sh /mnt/root/fakintosh-chroot-installer.sh

# Chroot in and run second part
arch-chroot /mnt /mnt/root/fakintosh-chroot-installer.sh
