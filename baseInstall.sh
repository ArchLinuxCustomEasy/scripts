#!/bin/bash

# cpuType = $(lscpu | grep GenuineIntel)
# diskList = $(lsblk -d -p -n -l -o NAME,SIZE -e 7,11)
# partitionList = $(lsblk -p -n -l -o NAME -e 7,11)
# partUuid = $(blkid -s PARTUUID -o value /dev/vda2)
# partType = $(blkid -s TYPE -o value /dev/vda2)
# use cgdisk to manually make partitions on disk: cgdisk /dev/vda
# format partition (ext4) with label: mkfs.ext4 -L root /dev/vda2
# format partition (fat32) with label: mkfs.fat -n ESP -F32 /dev/vda1
# Libvirt services: libvirtd virtlogd

# Update the system clock
timedatectl set-ntp true

# Format the root partition
mkfs.ext4 -L root /dev/vda2

# Format the boot partition
mkfs.fat -n ESP -F32 /dev/vda1

# Mount partitions
mount /dev/vda2 /mnt
mkdir -p /mnt/boot
mount /dev/vda1 /mnt/boot

# Install base system
pacstrap /mnt base linux linux-firmware vim nano intel-ucode bash-completion git openssh rsync

# pacman configuration
cp /etc/pacman.conf /mnt/etc/pacman.conf
sed -i "s/# Misc options/# Misc options\nColor\nParallelDownloads=6\nVerbosePkgLists\nILoveCandy/" /mnt/etc/pacman.conf

# networkmanager network-manager-applet dialog wpa_supplicant mtools dosfstools xdg-user-dirs xdg-utils gvfs gvfs-smb nfs-utils bluez bluez-utils blueman pulseaudio-bluetooth alsa-utils tlp sof-firmware acpid ntfs-3g terminus-font

ln -sf /usr/share/zoneinfo/Europe/Paris /mnt/etc/localtime
arch-chroot /mnt hwclock --systohc
echo "LANG=fr_FR.UTF-8\nLC_COLLATE=C" > /mnt/etc/locale.conf
echo "KEYMAP=fr" > /mnt/etc/vconsole.conf
echo "arch" > /mnt/etc/hostname
echo "127.0.0.1     localhost
::1     localhost
127.0.1.1       arch.local arch" > /mnt/etc/hosts
sed -i '/#fr_FR.UTF-8/s/^#//g' /mnt/etc/locale.gen
arch-chroot /mnt locale-gen

echo root:toor | arch-chroot /mnt chpasswd

genfstab -U /mnt >> /mnt/etc/fstab

# systemd-boot install
arch-chroot /mnt bootctl install

# systemd-boot pacman hook
mkdir -p /mnt/etc/pacman.d/hooks

echo "[Trigger]
Type = Package
Operation = Upgrade
Target = systemd

[Action]
Description = Updating systemd-boot
When = PostTransaction
Exec = /usr/bin/bootctl update" > /mnt/etc/pacman.d/hooks/100-systemd-boot.hook

# archlinux entries for systemd-boot
echo "title     Arch Linux
linux       /vmlinuz-linux
initrd      /intel-ucode.img
initrd      /initramfs-linux.img
options     root=PARTUUID=$(blkid -s PARTUUID -o value /dev/vda2) rw" > /mnt/boot/loader/entries/archlinux.conf

# archlinux-fallback entries for systemd-boot
echo "title     Arch Linux (fallback initramfs)
linux       /vmlinuz-linux
initrd      /intel-ucode.img
initrd      /initramfs-linux-fallback.img
options     root=PARTUUID=$(blkid -s PARTUUID -o value /dev/vda2) rw" > /mnt/boot/loader/entries/archlinux-fallback.conf

# systemd-boot configuration
echo "default  arch*.conf
timeout  1" > /mnt/boot/loader/loader.conf

# Update systemd-boot
arch-chroot /mnt bootctl update


pacstrap /mnt base-devel linux-headers efibootmgr dhcpcd ntp modemmanager iwd inetutils dnsutils nss-mdns reflector avahi xorg xorg-{xinit,twm,apps}
# enable all necessary services
arch-chroot /mnt systemctl enable sshd avahi-daemon reflector.timer fstrim.timer iwd ModemManager systemd-resolved ntpd dhcpcd
reflector --country France --protocol https --age 6 --sort rate --verbose --save /mnt/etc/pacman.d/mirrorlist

# NetworkManager bluetooth

arch-chroot /mnt useradd -m tuxi
echo tuxi:tuxi | arch-chroot /mnt chpasswd
arch-chroot /mnt usermod -aG wheel,audio,optical,storage,video tuxi

echo "%wheel ALL=(ALL) ALL" >> /mnt/etc/sudoers.d/wheel

echo 'Section "InputClass"
  Identifier "system-keyboard"
  MatchIsKeyboard "on"
  Option "XkbLayout" "fr"
  Option "XkbModel" "pc105"
  Option "XkbVariant" "mac"
EndSection' > /mnt/etc/X11/xorg.conf.d/00-keyboard.conf

echo "options hid_apple iso_layout = 0
options hid_apple fnmode = 1" > /mnt/etc/modprobe.d/hid_apple.conf

# Making a 8G swap file
dd if=/dev/zero of=/mnt/swapfile bs=1M count=8192 status=progress
chmod 600 /mnt/swapfile
mkswap /mnt/swapfile
swapon /mnt/swapfile
echo "/swapfile none swap defaults 0 0" >> /mnt/etc/fstab

# Reduce swap usage
echo "vm.swappiness=10
vm.vfs_cache_pressure=50" > /mnt/etc/sysctl.d/99-swappiness.conf

# Umount partitions
umount -R /mnt