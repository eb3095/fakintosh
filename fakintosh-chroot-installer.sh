#!/bin/bash

# Fakintosh Installaltion Script
# Version: 1.0
# Author: Eric Benner

# Check for UEFI
EFI=false
EFIVARS=/sys/firmware/efi/efivars
if [ -d "$EFI" ]; then
    EFI=true
fi

# Set time zone
ln -sf /usr/share/zoneinfo/America/New_York /etc/localtime

# Set the clock
hwclock --systohc

# Configure locale
sed -i -e "s/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/" /etc/locale.gen

# Generate locale
locale-gen

# Configure locale
echo LANG=en_US.UTF-8 > /etc/locale.conf

# Set hostname
echo iMac > /etc/hostname

# Create Hosts file
echo "127.0.0.1      localhost" >> /etc/hosts
echo "::1            localhost" >> /etc/hosts
echo "127.0.1.1      iMac.localdomain iMac" >> /etc/hosts

# Make initramfs
mkinitcpio -p linux

# Install ABSOLUTE essentials
pacman -Sy wget git unzip zip base-devel grub zsh --noconfirm

echo "Enter a root password [ENTER]:"
read rootpw

# Set root password
echo $rootpw | passwd root --stdin

echo "Enter a user [ENTER]:"
read user

echo "Enter a $user's password [ENTER]:"
read userpw

# Setup user
mkdir /home/$user
cp /etc/skel/.zshrc /home/$user/.zshrc
useradd -d /home/$user $user
echo $userpw | passwd $user --stdin
chsh -s $(which zsh) $user
chown -R $user:$user /home/$user

# Install Grub
if [ "$EFI" = true ] ; then
  grub-install --target=x86_64-efi --efi-directory=esp --bootloader-id=GRUB
else
  grub-install --target=i386-pc /dev/vda
fi

# Generate Grub
grub-mkconfig -o /boot/grub/grub.cfg
