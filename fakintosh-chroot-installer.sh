#!/bin/bash

# Fakintosh Installaltion Script
# Version: 1.0
# Author: Eric Benner

ln -sf /usr/share/zoneinfo/America/New_York /etc/localtime
hwclock --systohc
sed -i -e "s/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/" /etc/locale.gen
locale-gen
echo LANG=en_US.UTF-8 > /etc/locale.conf
echo iMac > /etc/hostname
echo "127.0.0.1      localhost" >> /etc/hosts
echo "::1            localhost" >> /etc/hosts
echo "127.0.1.1      iMac.localdomain iMac" >> /etc/hosts
mkinitcpio -p linux

pacman -Sy wget git unzip zip base-devel grub zsh --noconfirm

echo "Enter a root password [ENTER]:"
read rootpw

echo $rootpw | passwd root --stdin

echo "Enter a user [ENTER]:"
read user

echo "Enter a $user's password [ENTER]:"
read userpw

mkdir /home/$user
cp /etc/skel/.zshrc /home/$user/.zshrc
useradd -d /home/$user $user
echo $userpw | passwd $user --stdin
chsh -s $(which zsh) $user

# BIOS
# grub-install --target=i386-pc /dev/vda

# GPT
# grub-install --target=x86_64-efi --efi-directory=esp --bootloader-id=GRUB
