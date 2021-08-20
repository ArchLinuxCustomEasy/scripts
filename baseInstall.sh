#!/bin/bash

diskList=$(lsblk -d -p -n -l -o NAME,SIZE -e 7,11)
partitionList=$(lsblk -p -n -l -o NAME,SIZE -e 7,11)
installationDisk=''
bootPartition=''
rootPartition=''
rootPartUuid=''
hostName=''
userName=''
userPassword=''
rootPassword=''
swapfileSize=''

printMessage() {
  message=$1
  tput setaf 2
  echo "-------------------------------------------"
  echo "$message"
  echo "-------------------------------------------"
  tput sgr0
}

# Helper function to handle errors
handleError() {
  clear
  set -uo pipefail
  trap 's=$?; echo "$0: Error on line "$LINENO": $BASH_COMMAND"; exit $s' ERR
}

selectInstallDisk() {
  printMessage "Installation disk"

  PS3="Select the installation disk: "
  list=$(lsblk -d -p -n -l -o NAME -e 7)
  select disk in ${list}
  do
    if [[ "$REPLY" == 'q' ]]; then exit; fi

    if [[ "$disk" == "" ]]
    then
      echo "Invalid option $REPLY"
      continue
    fi

    installationDisk+=$disk
    break
  done
}

makeDiskPartitions() {
  printMessage "Disk partition"

  PS3="Make disk partitions? "
  select opt in yes no ; do
  case $opt in
    yes )
      printMessage "Reinitialize the installation disk; CAUTION: this will delete all data on ${installationDisk} disk, please do this ONLY if you are SURE!"
      PS3="Reinitialize installation disk? "
      select opt in yes no ; do
      case $opt in
        yes )
          wipefs -a ${installationDisk}
          wipe -r ${installationDisk}
          break
          ;;
        no)
          break
          ;;
        *) 
          echo "Invalid option $REPLY"
          ;;
        esac
      done

      printMessage "Make partitions on ${installationDisk}"
      gdisk ${installationDisk}
      break
      ;;
    no)
      break
      ;;
    *) 
      echo "Invalid option $REPLY"
      ;;
    esac
  done
}

selectRootPartition() {
  printMessage "Root partition"
  PS3="Select root partition: "
  list=$(lsblk -p -n -l -o NAME -e 7 $installationDisk)
  select rootPart in ${list}
  do
    if [[ "$REPLY" == 'q' ]]; then exit; fi

    if [[ "$disk" == "" ]]
    then
      echo "Invalid option $REPLY"
      continue
    fi

    rootPartition=$rootPart
    rootPartUuid=$(blkid -s PARTUUID -o value $rootPartition)
    break
  done
}

selectBootPartition() {
  printMessage "Boot partition"
  PS3="Select boot partition: "
  list=$(lsblk -p -n -l -o NAME -e 7 $installationDisk)
  select bootPart in ${list}
  do
    if [[ "$REPLY" == 'q' ]]; then exit; fi

    if [[ "$disk" == "" ]]
    then
      echo "Invalid option $REPLY"
      continue
    fi

    bootPartition=$bootPart
    break
  done
}

chooseHostname() {
  printMessage "Hostname"
  while true
  do
    read -p "Type a hostname: " choiceHostname
    if [[ "$choiceHostname" == "" ]]
      then
        echo "Invalid hostname, please retry!"
        continue
      fi
    hostName=$choiceHostname
    break
  done
}

chooseSwapfileSize() {
  printMessage "Swap file size"
  while :
  do
    read -p "Type a size in Go for the swapfile: " choiceSwapfileSize
    if [[ "$choiceSwapfileSize" == "" ]]
      then
        echo "Invalid size, please retry!"
        continue
      fi
    swapfileSize=$(expr $choiceSwapfileSize \* 1024)
    break
  done
}

chooseUsername() {
  printMessage "Username"
  while :
  do
    read -p "Type a username: " choiceUsername
    if [[ "$choiceUsername" == "" ]]
      then
        echo "Invalid username, please retry!"
        continue
      fi
    userName=$choiceUsername
    break
  done
}

chooseUserPassword() {
  printMessage "User password"
  while :
  do
    read -s -p "Type the user password: " choiceUserPassword; echo
    if [[ "$choiceUserPassword" == "" ]]
      then
        echo "Invalid user password, please retry!"
        continue
      fi
    userPassword=$choiceUserPassword
    break
  done
}

chooseRootPassword() {
  printMessage "Root password"
  while :
  do
    read -s -p "Type the root password: " choiceRootPassword; echo
    if [[ "$choiceRootPassword" == "" ]]
      then
        echo "Invalid root password, please retry!"
        continue
      fi
    rootPassword=$choiceRootPassword
    break
  done
}

formatPartitions() {
  printMessage "Formatting boot partition"
  echo "Y" | mkfs.fat -n ESP -F32 $bootPartition
  sleep 1
  printMessage "Formatting root partition"
  echo "Y" | mkfs.ext4 -L root $rootPartition
}

mountPartitions() {
  printMessage "Mounting root partition"
  mount $rootPartition /mnt
  mkdir -p /mnt/boot
  printMessage "Mounting boot partition"
  mount $bootPartition /mnt/boot
}

makeSwapFile() {
  printMessage "Creating the swapfile"
  dd if=/dev/zero of=/mnt/swapfile bs=1M count=$swapfileSize status=progress
  printMessage "Changing permissions on swapfile"
  chmod 600 /mnt/swapfile
  printMessage "Mounting/enable the swapfile"
  mkswap /mnt/swapfile
  swapon /mnt/swapfile
}

installBaseSystemInChroot() {
  printMessage "Installing the base system in chroot"
  pacstrap /mnt base linux linux-firmware vim nano intel-ucode bash-completion git openssh rsync
}

baseConfigurationInChroot() {
  printMessage "Changing pacman configuration in chroot"
  cp /etc/pacman.conf /mnt/etc/pacman.conf
  sed -i "s/# Misc options/# Misc options\nColor\nParallelDownloads=6\nVerbosePkgLists\nILoveCandy/" /mnt/etc/pacman.conf

  printMessage "Timezone configuration in chroot"
  ln -sf /usr/share/zoneinfo/Europe/Paris /mnt/etc/localtime
  
  printMessage "Locale configuration in chroot"
  sed -i '/#fr_FR.UTF-8/s/^#//g' /mnt/etc/locale.gen
  echo "LANG=fr_FR.UTF-8
  LC_COLLATE=C" > /mnt/etc/locale.conf

  printMessage "Console keyboard configuration in chroot"
  echo "KEYMAP=fr" > /mnt/etc/vconsole.conf

  printMessage "Hostname configuration in chroot"
  echo "$hostName" > /mnt/etc/hostname
  echo "127.0.0.1     localhost
  ::1     localhost
  127.0.1.1       $hostName.local $hostName" > /mnt/etc/hosts
}

systemConfigurationInChroot() {
  printMessage "Updating system clock"
  timedatectl set-ntp true

  printMessage "Setting hardware clock from system clock"
  arch-chroot /mnt hwclock --systohc

  printMessage "Generating locales"
  arch-chroot /mnt locale-gen

  printMessage "Changing root password"
  echo root:$rootPassword | arch-chroot /mnt chpasswd

  printMessage "Generating fstab"
  genfstab -U /mnt >> /mnt/etc/fstab

  printMessage "Optimizing swap usage"
  echo "vm.swappiness=10
  vm.vfs_cache_pressure=50" > /mnt/etc/sysctl.d/99-swappiness.conf
}

bootLoaderInChroot() {
  printMessage "Installing systemd-boot"
  arch-chroot /mnt bootctl install

  printMessage "Systemd-boot pacman hook"
  mkdir -p /mnt/etc/pacman.d/hooks
  echo "[Trigger]
  Type = Package
  Operation = Upgrade
  Target = systemd
  [Action]
  Description = Updating systemd-boot
  When = PostTransaction
  Exec = /usr/bin/bootctl update" > /mnt/etc/pacman.d/hooks/100-systemd-boot.hook

  printMessage "Systemd-boot entries configuration"
  echo "title     Arch Linux
  linux       /vmlinuz-linux
  initrd      /intel-ucode.img
  initrd      /initramfs-linux.img
  options     root=PARTUUID=${rootPartUuid} rw" > /mnt/boot/loader/entries/archlinux.conf
  echo "title     Arch Linux (fallback initramfs)
  linux       /vmlinuz-linux
  initrd      /intel-ucode.img
  initrd      /initramfs-linux-fallback.img
  options     root=PARTUUID=${rootPartUuid} rw" > /mnt/boot/loader/entries/archlinux-fallback.conf

  printMessage "Systemd-boot loader configuration"
  echo "default  arch*.conf
  timeout  1" > /mnt/boot/loader/loader.conf

  printMessage "Systemd-boot update"
  arch-chroot /mnt bootctl update
}

endInstallation() {
  printMessage "Adding common utilities"
  pacstrap /mnt base-devel linux-headers efibootmgr dhcpcd ntp modemmanager iwd inetutils dnsutils nss-mdns reflector avahi
  
  printMessage "Starting services"
  arch-chroot /mnt systemctl enable sshd avahi-daemon reflector fstrim.timer iwd ModemManager systemd-resolved ntpd dhcpcd

  printMessage "Adding reflection configuration"
  reflectorConfig="
    --country France
    --protocol https
    --latest 10
    --sort rate
    --save /etc/pacman.d/mirrorlist
  "
  echo "${reflectorConfig}" > /mnt/etc/xdg/reflector/reflector.conf
  printMessage "${reflectorConfig}"

  printMessage "Adding the user"
  arch-chroot /mnt useradd -m $userName

  printMessage "Adding the user password"
  echo $userName:$userPassword | arch-chroot /mnt chpasswd

  printMessage "Adding the user in some groups"
  arch-chroot /mnt usermod -aG wheel,audio,optical,storage,video $userName

  printMessage "Adding the user in sudoers"
  echo "%wheel ALL=(ALL) ALL
Defaults timestamp_type=global
Defaults timestamp_timeout=30" > /mnt/etc/sudoers.d/wheel

  printMessage "Congratulation! The base system is installed, you can now reboot!"
}

configureInstallation() {
  selectInstallDisk
  makeDiskPartitions
  selectBootPartition
  selectRootPartition
  chooseHostname
  chooseUsername
  chooseUserPassword
  chooseRootPassword
  chooseSwapfileSize
  printMessage "
    Installation Disk: ${disk}
    Boot Partition: ${bootPartition}
    Root Partition: ${rootPartition}
    Hostname: ${hostName}
    Username: ${userName}
    User password: ${userPassword}
    Root password: ${rootPassword}
    Swap file size: ${swapfileSize}
    Root partition PARTUUID: ${rootPartUuid}
  "
}

main() {
  handleError
  configureInstallation
  formatPartitions
  mountPartitions
  makeSwapFile
  installBaseSystemInChroot
  baseConfigurationInChroot
  systemConfigurationInChroot
  bootLoaderInChroot
  endInstallation
}

time main

exit 0
