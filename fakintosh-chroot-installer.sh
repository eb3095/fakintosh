#!/bin/bash

# Fakintosh Installaltion Script
# Version: 1.0
# Author: Eric Benner

# Assign arguments
drive={DRIVE}

# Check for UEFI
EFI=false
EFIVARS=/sys/firmware/efi/efivars
if [ -d "$EFIVARS" ]; then
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
pacman -Sy wget git unzip zip base-devel grub zsh efibootmgr dosfstools os-prober mtools sudo --noconfirm

echo
echo "Enter a root password [ENTER]:"
read -s rootpw

# Set root password
echo root:"$rootpw" | chpasswd

echo
echo "Enter a user [ENTER]:"
read user

echo
echo "Enter a $user's password [ENTER]:"
read -s userpw

# Setup user
mkdir /home/$user
cp /etc/skel/.zshrc /home/$user/.zshrc
useradd -d /home/$user $user
echo $user:"$userpw" | chpasswd
chsh -s $(which zsh) $user
chown -R $user:$user /home/$user
usermod -aG wheel $user

# Setup root
cp /etc/skel/.zshrc /root/.zshrc
chsh -s $(which zsh) root


# Setup SUDOERS
sed -i -e 's/# %wheel ALL=(ALL) NOPASSWD\: ALL/%wheelnpw ALL=(ALL) NOPASSWD\: ALL/' /etc/sudoers
sed -i -e 's/# %wheel ALL=(ALL) ALL/%wheel ALL=(ALL) ALL/' /etc/sudoers
groupadd wheelnpw

# Setup installer
uderadd fakintosh
usermod -aG wheelnpw

# Install Grub
if [ "$EFI" = true ] ; then
  grub-install --target=x86_64-efi  --bootloader-id=grub_uefi
else
  grub-install --target=i386-pc $drive
fi

# Generate Grub
grub-mkconfig -o /boot/grub/grub.cfg

# Install trizen
pushd /root/
git clone https://aur.archlinux.org/trizen.git
cd trizen
makepkg -si
cd ..
rm -rf trizen
popd

# Install packages
runuser -l fakintosh -c 'trizen -Sy --noconfirm weston plasma plasma-wayland-session kde-applications sddm opera pulseaudio tilix libreoffice-fresh kvantum-qt5 networkmanager nm-connection-editor network-manager-applet networkmanager-openvpn remmina notepadqq atom nvidia nvidia-settings thunderbird ufw vlc openssh nfs-utils bind-tools noto-fonts noto-fonts-extra noto-fonts-cjk noto-fonts-emoji numlockx screen nmap jq gotop iotop ccze htop expect sshuttle inkscape gimp jdk11-openjdk php sshfs ttf-ms-fonts kdeconnect ttf-dejavu ttf-liberation remmina-plugin-rdesktop plasma5-applets-kde-arch-update-notifier-git octopi filezilla opera-ffmpeg-codecs'

# Enable services
systemctl enable ufw
systemctl enable sddm
systemctl enable sshd
systemctl enable NetworkManager
systemctl enable dhcpcd


# Configure Firewall
ufw enable
ufw default deny incoming
ufw allow 22

# Dispose of installer user
userdel fakintosh

# Cleanup
rm /root/fakintosh-chroot-installer.sh
rm /root/bootstrap.sh
