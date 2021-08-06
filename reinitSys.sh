#!/bin/bash

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

isRootUser() {
  if [[ ! "$EUID" = 0 ]]; then 
    printMessage "Please Run As Root"
    exit 0
  fi
  printMessage "Ok to continue running the script"
}

reinitSys() {
  printMessage "Mark all packages as dependencies"
  pacman -D --asdeps $(pacman -Qqe)

  printMessage "Mark base packages as explicit"
  pacman -D --asexplicit base base-devel linux linux-firmware vim nano intel-ucode bash-completion git openssh rsync linux-headers efibootmgr dhcpcd ntp modemmanager iwd inetutils bind nss-mdns reflector avahi sudo xf86-video-vesa

  printMessage "Remove all non explicit packages"
  pacman -Qttdq | pacman -Rns -

  printMessage "Enable base services"
  systemctl enable sshd avahi-daemon reflector.timer fstrim.timer iwd ModemManager systemd-resolved ntpd dhcpcd
}

postInstall() {
  printMessage "System reinitialization is done! You can install manually your packages or launch the xfceInstall.sh script."

  PS3="Launch xfceInstall.sh script? "
  select opt in yes no ; do
  case $opt in
    yes )
      sh xfceInstall.sh
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

main() {
  handleError
  isRootUser
  reinitSys
  postInstall
}

time main

exit 0
