#!/bin/bash

# Name: baseInstall.sh
# Description: Install the Archlinux system, based on official documentation, with some customizations.
# Author: Titux Metal <tituxmetal[at]lgdweb[dot]fr>
# Url: https://github.com/ArchLinuxCustomEasy/scripts
# Version: 1.0
# Revision: 2021.09.17
# License: MIT License

diskList="$(lsblk -d -p -n -l -o NAME,SIZE -e 7,11)"
partitionList="$(lsblk -p -n -l -o NAME,SIZE -e 7,11)"
chrootPath="/mnt/alice"
installationDisk=""
bootPartition=""
rootPartition=""
rootPartUuid=""
hostName=""
userName=""
userPassword=""
rootPassword=""
swapfileSize=""
addAliceRepo=""
copyInstallDesktopScript=""
unmountNewSystem=""

printMessage() {
  message=$1
  tput setaf 2
  echo -en "-------------------------------------------\n"
  echo -en "${message}\n"
  echo -en "-------------------------------------------\n"
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
  printMessage "Partition the disk"

  PS3="Make the disk partitions? "
  select opt in yes no ; do
  case $opt in
    yes )
      printMessage "Reset the installation disk; CAUTION: This action deletes ALL data on ${installationDisk} disk, please do it ONLY if you are absolutely SURE!"
      PS3="Reinitialize installation disk? "
      select opt in yes no ; do
      case $opt in
        yes )
          wipefs -a ${installationDisk}
          echo Y | parted ${installationDisk} mklabel gpt
          partprobe --summary ${installationDisk}
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
      parted ${installationDisk} mkpart "EFI" fat32 1MiB 300MiB set 1 esp on
      parted ${installationDisk} mkpart "root" ext4 300MiB 100%
      parted ${installationDisk} print align-check optimal 2
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

askAddAlicePkgRepo() {
  printMessage "Add Alice Custom package repository"

  PS3="Would you add Alice Custom package repository? "
  select opt in yes no ; do
  case $opt in
    yes)
      addAliceRepo="yes"
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

askCopyDesktopInstallScript() {
  printMessage "Copy the desktop install script on new system"

  PS3="Would you copy the desktop install script on new system? "
  select opt in yes no ; do
  case $opt in
    yes)
      copyInstallDesktopScript="yes"
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

askUnountNewSystem() {
  printMessage "Unmount partitions from chroot"

  PS3="Would you unmount the partitions from chroot? "
  select opt in yes no ; do
  case $opt in
    yes)
      unmountNewSystem="yes"
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

formatPartitions() {
  printMessage "Formatting boot partition"
  echo "Y" | mkfs.fat -n ESP -F32 $bootPartition
  sleep 1
  printMessage "Formatting root partition"
  echo "Y" | mkfs.ext4 -L root $rootPartition
}

mountPartitions() {
  printMessage "Creating the chroot mount point ${chrootPath}"
  mkdir -p ${chrootPath}
  printMessage "Mounting root partition in ${chrootPath}"
  mount $rootPartition ${chrootPath}
  printMessage "Mounting boot partition in ${chrootPath}/boot"
  mkdir -p ${chrootPath}/boot
  mount $bootPartition ${chrootPath}/boot
}

makeSwapFile() {
  printMessage "Creating the swapfile in ${chrootPath}/swapfile"
  dd if=/dev/zero of=${chrootPath}/swapfile bs=1M count=$swapfileSize status=progress
  printMessage "Changing permissions and enable swapfile"
  chmod 600 ${chrootPath}/swapfile
  mkswap ${chrootPath}/swapfile
  swapon ${chrootPath}/swapfile
}

installBaseSystemInChroot() {
  printMessage "Installing the base system in chroot"
  pacstrap ${chrootPath} base linux linux-firmware vim nano intel-ucode bash-completion git openssh rsync
}

baseConfigurationInChroot() {
  printMessage "Changing pacman configuration in chroot"
  cp /etc/pacman.conf ${chrootPath}/etc/pacman.conf
  sed -i "s/# Misc options/# Misc options\nColor\nParallelDownloads=6\nVerbosePkgLists\nILoveCandy/" ${chrootPath}/etc/pacman.conf

  printMessage "Timezone configuration in chroot"
  ln -sf /usr/share/zoneinfo/Europe/Paris ${chrootPath}/etc/localtime

  printMessage "Locale configuration in chroot"
  sed -i '/#fr_FR.UTF-8/s/^#//g' ${chrootPath}/etc/locale.gen
  echo -en "LANG=fr_FR.UTF-8\nLC_COLLATE=C" > ${chrootPath}/etc/locale.conf

  printMessage "Console keyboard configuration in chroot"
  echo "KEYMAP=fr" > ${chrootPath}/etc/vconsole.conf

  printMessage "Hostname configuration in chroot"
  echo "$hostName" > ${chrootPath}/etc/hostname
  cat > "${chrootPath}/etc/hosts" << EOF
127.0.0.1   localhost
::1         localhost
127.0.1.1   $hostName.local $hostName
EOF
}

systemConfigurationInChroot() {
  printMessage "Updating system clock"
  timedatectl set-ntp true

  printMessage "Setting hardware clock from system clock"
  arch-chroot ${chrootPath} hwclock --systohc

  printMessage "Generating locales"
  arch-chroot ${chrootPath} locale-gen

  printMessage "Changing root password"
  echo root:$rootPassword | arch-chroot ${chrootPath} chpasswd

  printMessage "Generating fstab"
  genfstab -U ${chrootPath} >> ${chrootPath}/etc/fstab

  printMessage "Optimizing swap usage"
  echo -en "vm.swappiness=10\nvm.vfs_cache_pressure=50" > ${chrootPath}/etc/sysctl.d/99-swappiness.conf
}

bootLoaderInChroot() {
  printMessage "Installing systemd-boot"
  arch-chroot ${chrootPath} bootctl install

  printMessage "Systemd-boot pacman hook"
  mkdir -p ${chrootPath}/etc/pacman.d/hooks
  cat > "${chrootPath}/etc/pacman.d/hooks/100-systemd-boot.hook" << EOF
[Trigger]
Type = Package
Operation = Upgrade
Target = systemd
[Action]
Description = Updating systemd-boot
When = PostTransaction
Exec = /usr/bin/bootctl update
EOF

  printMessage "Systemd-boot entries configuration"
  cat > "${chrootPath}/boot/loader/entries/archlinux.conf" << EOF
title   Arch Linux
linux   /vmlinuz-linux
initrd  /intel-ucode.img
initrd  /initramfs-linux.img
options root=PARTUUID=${rootPartUuid} rw
EOF
  cat > "${chrootPath}/boot/loader/entries/archlinux-fallback.conf" << EOF
title   Arch Linux (fallback initramfs)
linux   /vmlinuz-linux
initrd  /intel-ucode.img
initrd  /initramfs-linux-fallback.img
options root=PARTUUID=${rootPartUuid} rw
EOF

  printMessage "Systemd-boot loader configuration"
  cat > "${chrootPath}/boot/loader/loader.conf" << EOF
default  arch*.conf
timeout  1
EOF

  printMessage "Systemd-boot update"
  arch-chroot ${chrootPath} bootctl update
}

endInstallation() {
  printMessage "Adding Numlock On service"
  cat > ${chrootPath}/etc/systemd/system/numlockon.service << "EOF"
[Unit]
Description=Switch on numlock from tty1 to tty6
[Service]
ExecStart=/bin/bash -c 'for tty in /dev/tty{1..6};do /usr/bin/setleds -D +num < \"$tty\";done'
[Install]
WantedBy=multi-user.target
EOF

  printMessage "Adding common utilities"
  pacstrap ${chrootPath} base-devel linux-headers efibootmgr dhcpcd ntp modemmanager iwd inetutils dnsutils nss-mdns reflector avahi

  printMessage "Starting services"
  arch-chroot ${chrootPath} systemctl enable sshd avahi-daemon numlockon fstrim.timer iwd ModemManager systemd-resolved ntpd dhcpcd

  printMessage "Adding reflection configuration"
  cat > "${chrootPath}/etc/xdg/reflector/reflector.conf" << EOF
--country France
--protocol https
--latest 5
--sort rate
--save /etc/pacman.d/mirrorlist
EOF

  printMessage "Adding the user"
  arch-chroot ${chrootPath} useradd -m $userName

  printMessage "Adding the user password"
  echo $userName:$userPassword | arch-chroot ${chrootPath} chpasswd

  printMessage "Adding the user in some groups"
  arch-chroot ${chrootPath} usermod -aG wheel,audio,optical,storage,video $userName

  printMessage "Do not lock the user when password is given wrong 3 times"
  sed -i "s/# admin_group =/admin_group = wheel/" ${chrootPath}/etc/security/faillock.conf

  printMessage "Adding the user in sudoers"
  cat > "${chrootPath}/etc/sudoers.d/wheel" << EOF
%wheel ALL=(ALL) ALL
Defaults timestamp_type=global
Defaults timestamp_timeout=30
EOF

  if [[ "${addAliceRepo}" == "yes" ]] ;then
    printMessage "Add Alice package repository to the new system"
    git clone https://github.com/ArchLinuxCustomEasy/repository.git /tmp/alice
    rsync -rltv --progress --stats --exclude=.git /tmp/alice ${chrootPath}/opt/
    echo -en '[alice]\nSigLevel = Never\nServer = file:///opt/alice/$arch' >> ${chrootPath}/etc/pacman.conf
  fi

  if [[ "${copyInstallDesktopScript}" == "yes" ]] ;then
    printMessage "Copy desktopInstall.sh file to the new system"
    cp ./desktopInstall.sh ${chrootPath}/home/${userName}/
    chmod +x ${chrootPath}/home/${userName}/desktopInstall.sh
  fi

  if [[ "${unmountNewSystem}" == "yes" ]] ;then
    printMessage "Unmouting the new system"
    swapoff ${chrootPath}/swapfile
    umount -R ${chrootPath}/boot
    umount -R ${chrootPath}
  fi

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
  askAddAlicePkgRepo
  askCopyDesktopInstallScript
  askUnountNewSystem
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
