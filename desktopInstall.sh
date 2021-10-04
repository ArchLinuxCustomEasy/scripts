#!/bin/bash

# Name: desktopInstall.sh
# Description: Install a complete desktop environment and some funny stuff.
# Author: Titux Metal <tituxmetal[at]lgdweb[dot]fr>
# Url: https://github.com/ArchLinuxCustomEasy/scripts
# Version: 1.0
# Revision: 2021.10.04
# License: MIT License

# Video Driver Packages
declare -a videoDriverPackages
# Video drivers Nvidia See https://wiki.archlinux.org/title/NVIDIA
nvidiaDriverPackages="nvidia-utils nvidia-settings nvidia-dkms nvtop"
# Video drivers Nouveau See https://wiki.archlinux.org/title/Nouveau
nouveauDriverPackages="xf86-video-nouveau"
# Video drivers Intel See https://wiki.archlinux.org/title/Intel_graphics
intelDriverPackages="libva-intel-driver intel-media-driver xf86-video-intel"
# Video drivers Amd See https://wiki.archlinux.org/title/AMDGPU
amdDriverPackages="xf86-video-amdgpu xf86-video-ati radeontop vulkan-radeon amdvlk"
# Virtual Machine (kvm) video drivers
# See: https://wiki.archlinux.org/title/QEMU#Enabling_SPICE_support_on_the_guest
# Read this post: https://stackoverflow.com/a/62021367
virtualMachineDriverPackages="spice-vdagent xf86-video-qxl"
# Video drivers OpenGL See https://wiki.archlinux.org/title/OpenGL
genericDriverPackages="mesa mesa-demos xf86-video-vesa"
# Hardware Video accel. Nvidia/Intel/Amd See https://wiki.archlinux.org/title/Hardware_video_acceleration
hdwVideoAccelPackages="mesa-vdpau mesa-demos libva-mesa-driver libva-vdpau-driver libva-utils libvdpau-va-gl"

# Multimedia packages: readers/viewers, editors/capture, rip/encode, burn for images, audio, video
declare -a multimediaPackages
checkInstallMultimediaReaders=0
checkInstallMultimediaEditors=0
checkInstallMultimediaRipencode=0
checkInstallMultimediaBurn=0
multimediaReadersPackages="vlc quodlibet shotwell evince playerctl"
multimediaEditorsPackages="gimp inkscape scour vokoscreen"
multimediaRipencodePackages="asunder handbrake handbrake-cli"
multimediaBurnPackages="brasero lsdvd dvdauthor dvdbackup libdvdcss dvd+rw-tools libdvdread libdvdnav libcdio libisoburn"
# Audio/Video codec and GStreamer support
# https://wiki.archlinux.org/title/Codecs_and_containers
# https://wiki.archlinux.org/title/GStreamer
audioVideoCodecGst="gst-libav gst-plugins-bad gst-plugins-base gst-plugins-good gst-plugins-ugly libde265 gstreamer-vaapi gstreamer libfdk-aac libmad libmpcdec libvorbis libdca libwebp libavif libheif libdv libmpeg2 libtheora libvpx fdkaac aom dav1d rav1e svt-av1 x264 x265 xvidcore ogmtools ffmpeg ffmpegthumbnailer faac faad2 lame flac wavpack a52dec opencore-amr opus speex celt pavucontrol pulseaudio pulseaudio-alsa alsa-utils alsa-plugins"

# Bluetooth packages See: https://wiki.archlinux.org/title/Bluetooth
bluetoothPackages="bluez bluez-utils blueman pulseaudio-bluetooth"
checkInstallBluetooth=0

declare -a desktopEnvPackages
checkInstallDesktopXfce=0
checkInstallDesktopMate=0
checkInstallDesktopI3=0
desktopEnvironment=""
# Xfce desktop environment See: https://wiki.archlinux.org/title/Xfce
desktopXfcePackages="xfce4 mousepad thunar-archive-plugin thunar-media-tags-plugin xfce4-battery-plugin xfce4-cpufreq-plugin xfce4-cpugraph-plugin xfce4-datetime-plugin xfce4-diskperf-plugin xfce4-fsguard-plugin xfce4-mount-plugin xfce4-mpc-plugin xfce4-netload-plugin xfce4-notifyd xfce4-pulseaudio-plugin xfce4-sensors-plugin xfce4-systemload-plugin xfce4-taskmanager xfce4-wavelan-plugin xfce4-weather-plugin xfce4-whiskermenu-plugin xfce4-xkb-plugin"
# Mate desktop environment See https://wiki.archlinux.org/title/Mate
desktopMatePackages="mate atril caja-image-converter caja-open-terminal caja-sendto caja-xattr-tags engrampa eom mate-applets mate-calc mate-icon-theme-faenza mate-media mate-power-manager mate-sensors-applet mate-system-monitor mate-terminal mate-utils mozo pluma"
# I3 window manager See:
# https://wiki.archlinux.org/title/i3
# https://i3wm.org/docs/userguide.html
desktopI3Packages="i3 perl-json-xs perl-anyevent-i3 polkit-gnome dunst"
# Fonts See: https://wiki.archlinux.org/title/Fonts
commonFontPackages="terminus-font gnu-free-fonts noto-fonts ttf-bitstream-vera ttf-dejavu ttf-droid ttf-font-awesome ttf-freefont ttf-inconsolata ttf-liberation ttf-roboto ttf-ubuntu-font-family ttf-opensans ttf-fira-code ttf-fira-mono otf-fira-mono"
# Web browser and common extensions
webBrowserPackages="firefox firefox-i18n-fr firefox-ublock-origin firefox-dark-reader firefox-extension-passff firefox-extension-privacybadger torbrowser-launcher"
# System Utilities
commonSystemUtilsPackages="vim rsync htop neofetch xed alacritty rofi pcmanfm feh galculator dex"
# Archive utilities
archiveUtilsPackages="xarchiver zip unzip unrar p7zip"
# File system utilities
fileSystemUtilsPackages="gptfdisk mtools xfsprogs dosfstools gparted f2fs-tools exfatprogs gpart udftools gvfs gvfs-gphoto2 gvfs-afc gvfs-goa gvfs-google gvfs-mtp gvfs-nfs gvfs-smb libgsf sshfs fuseiso"
# Xorg
xorgPackages="xorg xorg-xinit xorg-server xdg-utils xdg-user-dirs xbindkeys xcompmgr numlockx tumbler"

# Development Packages
declare -a developmentPackages
checkInstallDevelopmentWeb=0
checkInstallDevelopmentArchlinux=0
checkInstallDevelopmentDevops=0
developmentWebPackages="nodejs yarn"
developmentArchlinuxPackages="archiso libvirt ebtables dnsmasq bridge-utils openbsd-netcat virt-manager virt-viewer virt-install libguestfs edk2-ovmf qemu dhclient dmidecode spice-vdagent spice-gtk"
developmentDevopsPackages="ansible docker docker-compose pass passff-host chezmoi"

# Work Office Packages
declare -a workOfficePackages
checkInstallLibreOffice=0
checkInstallOnlyOffice=0
checkInstallPrinter=0
libreOfficePackages="libreoffice-fresh libreoffice-fresh-fr"
onlyOfficePackages="onlyoffice-bin"
printerPackages="cups cups-pdf usbutils system-config-printer hplip ghostscript gutenprint foomatic-db foomatic-db-engine foomatic-db-ppds foomatic-db-nonfree foomatic-db-gutenprint-ppds foomatic-db-nonfree-ppds "

# Desktop/Laptop Apple keyboard See: https://wiki.archlinux.org/title/Apple_Keyboard
appleKeyboardConfig=0

# Custom Alice dark theme repository See: https://github.com/ArchLinuxCustomEasy/darkTheme.git
aliceDarkThemeRepo="https://github.com/ArchLinuxCustomEasy/darkTheme.git"
checkAddAliceDarkTheme=0

# Alice packages
alicePackages="yay-bin ly visual-studio-code-bin pamac-aur libpamac-aur downgrade timeshift"
checkAlicePackages=0

# Icon and dark themes
darkThemesPackages="arc-gtk-theme arc-icon-theme papirus-icon-theme gtk-engine-murrine archlinux-wallpaper kvantum-qt5"

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

askUpdateMirrorList() {
  printMessage "Refresh Pacman mirror list"

  PS3="Would you refresh Pacman mirror list: "
  select opt in yes no ; do
  case $opt in
    yes)
      # Reflector See: https://wiki.archlinux.org/title/Reflector
      printMessage "Refreshing Pacman mirror list"
      reflector --verbose @/etc/xdg/reflector/reflector.conf
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

askInstallVideoDrivers() {
  printMessage "Choose video driver video drivers"

  PS3="Select which video drivers to install: "
  select opt in nvidia nouveau intel amd vm generic nodriver ; do
  case $opt in
    nvidia)
      videoDriverPackages+=($nvidiaDriverPackages)
      printMessage "Nvidia (official) video drivers: ${nvidiaDriverPackages}"
      break
      ;;
    nouveau)
      videoDriverPackages+=($nouveauDriverPackages)
      printMessage "Nouveau (open source Nvidia) video drivers: ${videoDriverPackages}"
      break
      ;;
    intel)
      videoDriverPackages+=($intelDriverPackages)
      printMessage "Intel video drivers: ${intelDriverPackages}"
      break
      ;;
    amd)
      videoDriverPackages+=($amdDriverPackages)
      printMessage "Amd video drivers: ${amdDriverPackages}"
      break
      ;;
    vm)
      videoDriverPackages+=($virtualMachineDriverPackages)
      printMessage "Virtual machine (kvm) video drivers: ${virtualMachineDriverPackages}"
      break
      ;;
    generic)
      videoDriverPackages+=($genericDriverPackages)
      printMessage "Default generic video drivers: ${genericDriverPackages}"
      break
      ;;
    nodriver)
      printMessage "No drivers would be installed"
      break
      ;;
    *)
      echo "Invalid option $REPLY"
      ;;
    esac
  done
}

askInstallMultimediaUtils() {
  printMessage "Multimedia readers/viewers, editors, cd/dvd burn, rip/encode"

  PS3="Choose what Multimedia utilities to install: "
  select opt in readers editors ripencode burn quit ; do
  case $opt in
    readers)
      if [[ $checkInstallMultimediaReaders == 0 ]] ; then
        multimediaPackages+=($multimediaReadersPackages)
        checkInstallMultimediaReaders=1
        printMessage "Multimedia readers packages: ${multimediaReadersPackages}"
        continue
      fi
      ;;
    editors)
      if [[ $checkInstallMultimediaEditors == 0 ]] ; then
        multimediaPackages+=($multimediaEditorsPackages)
        checkInstallMultimediaEditors=1
        printMessage "Multimedia editors packages: ${multimediaEditorsPackages}"
        continue
      fi
      ;;
    ripencode)
      if [[ $checkInstallMultimediaRipencode == 0 ]] ; then
        multimediaPackages+=($multimediaRipencodePackages)
        checkInstallMultimediaRipencode=1
        printMessage "Multimedia rip/encode packages: ${multimediaRipencodePackages}"
        continue
      fi
      ;;
    burn)
      if [[ $checkInstallMultimediaBurn == 0 ]] ; then
        multimediaPackages+=($multimediaBurnPackages)
        checkInstallMultimediaBurn=1
        printMessage "Multimedia cd/dvd burn packages: ${multimediaBurnPackages}"
        continue
      fi
      ;;
    quit)
      if ! [ -z "${multimediaPackages[*]}" ]; then
        multimediaPackages+=($audioVideoCodecGst)
        printMessage "Multimedia packages that would be installed: ${multimediaPackages[*]}"
      fi
      printMessage "Multimedia done!"
      break
      ;;
    *)
      echo "Invalid option $REPLY"
      ;;
    esac
  done
}

askInstallDevelopmentUtils() {
  printMessage "Development utilities"

  PS3="Choose what Development utilities to install: "
  select opt in web archlinux devops quit ; do
  case $opt in
    web)
      if [[ $checkInstallDevelopmentWeb == 0 ]] ; then
        developmentPackages+=($developmentWebPackages)
        checkInstallDevelopmentWeb=1
        printMessage "Development Web packages: ${developmentWebPackages}"
        continue
      fi
      ;;
    archlinux)
      if [[ $checkInstallDevelopmentArchlinux == 0 ]] ; then
        developmentPackages+=($developmentArchlinuxPackages)
        checkInstallDevelopmentArchlinux=1
        printMessage "Development Archlinux packages: ${developmentArchlinuxPackages}"
        continue
      fi
      ;;
    devops)
      if [[ $checkInstallDevelopmentDevops == 0 ]] ; then
        developmentPackages+=($developmentDevopsPackages)
        checkInstallDevelopmentDevops=1
        printMessage "Development devops packages: ${developmentDevopsPackages}"
        continue
      fi
      ;;
    quit)
      if ! [ -z "${developmentPackages[*]}" ]; then
        printMessage "Development utilities packages that would be installed: ${developmentPackages[*]}"
      fi
      printMessage "Multimedia done!"
      break
      ;;
    *)
      echo "Invalid option $REPLY"
      ;;
    esac
  done
}

askInstallWorkOfficeUtils() {
  printMessage "Work Office utilities"

  PS3="Choose what Work Office utilities to install: "
  select opt in libreoffice onlyoffice printer quit ; do
  case $opt in
    libreoffice)
      if [[ $checkInstallLibreOffice == 0 ]] ; then
        workOfficePackages+=($libreOfficePackages)
        checkInstallLibreOffice=1
        printMessage "Libre Office packages: ${libreOfficePackages}"
        continue
      fi
      ;;
    onlyoffice)
      if [[ $checkInstallOnlyOffice == 0 ]] ; then
        checkInstallOnlyOffice=1
        printMessage "Only Office packages: ${onlyOfficePackages}"
        continue
      fi
      ;;
    printer)
      if [[ $checkInstallPrinter == 0 ]] ; then
        workOfficePackages+=($printerPackages)
        checkInstallPrinter=1
        printMessage "Printer packages: ${printerPackages}"
        continue
      fi
      ;;
    quit)
      printMessage "Work Office done!"
      break
      ;;
    *)
      echo "Invalid option $REPLY"
      ;;
    esac
  done
}

askAddBluetoothSupport() {
  if ( dmesg | grep Bluetooth > /dev/null ); then
    printMessage "Bluetooth detected"

    PS3="Would you install bluetooth packages: "
    select opt in yes no ; do
    case $opt in
      yes)
        checkInstallBluetooth=1
        printMessage "Bluetooth packages: ${bluetoothPackages}"
        break
        ;;
      no)
        checkInstallBluetooth=0
        printMessage "No bluetooth packages"
        break
        ;;
      *)
        echo "Invalid option $REPLY"
        ;;
      esac
    done
  fi
}

askDesktopEnvironmentInstall() {
  printMessage "Choose desktop environment to install: Xfce, I3, Mate or nothing"

  PS3="Select which desktop environment to install: "
  select opt in xfce i3wm mate nodesktop ; do
  case $opt in
    xfce)
      desktopEnvPackages+=(${desktopXfcePackages})
      checkInstallDesktopXfce=1
      desktopEnvironment="xfce4"
      printMessage "Xfce desktop packages: ${desktopEnvPackages[*]}"
      break
      ;;
    i3wm)
      desktopEnvPackages+=(${desktopI3Packages})
      checkInstallDesktopI3=1
      desktopEnvironment="i3"
      printMessage "I3 window manager packages (WIP): ${desktopEnvPackages[*]}"
      break
      ;;
    mate)
      desktopEnvPackages+=(${desktopMatePackages})
      checkInstallDesktopMate=1
      desktopEnvironment="mate"
      printMessage "Mate desktop packages (WIP): ${desktopEnvPackages[*]}"
      break
      ;;
    nodesktop)
      printMessage "No desktop would be installed"
      break
      ;;
    *)
      echo "Invalid option $REPLY"
      ;;
    esac
  done
}

askAddAppleKeyboardConfig() {
  printMessage "Apple keyboard configuration for desktop or laptop"

  PS3="Would you add Apple keyboard configuration for Xorg: "
  select opt in desktop laptop no ; do
  case $opt in
    desktop)
      printMessage "Apple keyboard configuration for desktop"
      appleKeyboardConfig=0
      break
      ;;
    laptop)
      printMessage "Apple keyboard configuration for laptop"
      appleKeyboardConfig=1
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

askAddAlicePackages() {
  printMessage "Install a login manager, package manager GUI and Visual studio code"

  PS3="Would you add Alice packages: "
  select opt in yes no ; do
  case $opt in
    yes)
      printMessage "Alice packages: ${alicePackages}"
      checkAlicePackages=1
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

askAddAliceDarkTheme() {
  printMessage "Alice dark theme"

  PS3="Would you add Alice dark theme: "
  select opt in yes no ; do
  case $opt in
    yes)
      printMessage "Alice dark theme repository: ${aliceDarkThemeRepo}"
      checkAddAliceDarkTheme=1
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

addBluetoothSupport() {
  if [[ $checkInstallBluetooth != 0 ]] ; then
    printMessage "Adding bluetooth support"
    systemctl enable bluetooth.service
  fi
}

installPackages() {
  # The array of all the packages that must be installed
  declare -a packagesToInstall
  packagesToInstall+=("${commonSystemUtilsPackages}" "${archiveUtilsPackages}" "${fileSystemUtilsPackages}" "${xorgPackages}" )

  if ! [ -z "${videoDriverPackages[*]}" ]; then
    printMessage "Add video driver and hw video accel packages"
    packagesToInstall+=("${videoDriverPackages[*]}" "${hdwVideoAccelPackages}")
  fi

  if ! [ -z "${multimediaPackages[*]}" ]; then
    printMessage "Add multimedia and audio/video codec packages"
    packagesToInstall+=("${multimediaPackages[*]}" "${audioVideoCodecGst}")
  fi

  if ! [ -z "${workOfficePackages[*]}" ]; then
    printMessage "Add work office packages"
    packagesToInstall+=("${workOfficePackages[*]}")
  fi

  if [[ $checkInstallBluetooth != 0 ]] ; then
    printMessage "Add bluetooth packages"
    packagesToInstall+=("${bluetoothPackages}")
  fi

  if ! [ -z "${desktopEnvPackages[*]}" ]; then
    printMessage "Add desktop environment packages"
    packagesToInstall+=("${desktopEnvPackages[*]}" "${commonFontPackages}" "${webBrowserPackages}")
  fi

  if [[ $checkAddAliceDarkTheme != 0 ]] ; then
    printMessage "Add dark theme packages"
    packagesToInstall+=("${darkThemesPackages}")
  fi

  if ! [ -z "${developmentPackages[*]}" ]; then
    printMessage "Add development packages"
    packagesToInstall+=("${developmentPackages[*]}")
  fi

  if [[ $checkAlicePackages != 0 ]] ; then
    printMessage "Add Alice packages"
    packagesToInstall+=("${alicePackages}")
  fi

  printMessage "Clear Pacman cache"
  pacman -Scc --noconfirm

  pacman -Syu --noconfirm

  pacman-key --init && pacman-key --populate archlinux

  printMessage "Packages that would be installed: ${packagesToInstall[*]}"
  pacman -Sy --noconfirm --needed ${packagesToInstall[*]}

  if ( ! ls /etc/systemd/system/display-manager.service &>/dev/null ) ; then
    printMessage "Enable ly service"
    systemctl enable ly.service
  fi

  if [[ $checkInstallOnlyOffice != 0 ]] ; then
    su - $(logname) -c "yay -Sy --nocleanmenu --nodiffmenu --noeditmenu --needed --noconfirm ${onlyOfficePackages}"
  fi

  if [[ $checkInstallPrinter != 0 ]] ; then
    systemctl enable cups.socket
  fi

  if [[ $checkInstallDevelopmentArchlinux != 0 ]] ; then
    printMessage "Enable libvirtd service"
    systemctl enable virtlogd libvirtd
    printMessage "Copy default configuration file in /home/$(logname)/.config/libvirt"
    su - $(logname) -c "mkdir -p /home/$(logname)/.config/libvirt"
    su - $(logname) -c "cp -v /etc/libvirt/libvirt.conf /home/$(logname)/.config/libvirt/libvirt.conf"
    chown -R $(logname):wheel /home/$(logname)/.config/libvirt
    usermod -aG libvirt $(logname)
  fi

  if [[ $checkInstallDevelopmentDevops != 0 ]] ; then
    printMessage "Add $(logname) user to docker group"
    usermod -aG docker $(logname)
    printMessage "Enable docker service"
    systemctl enable docker
  fi
}

addAppleKeyboardConfig() {
  if ! [ -z "$appleKeyboardConfig" ]; then
    printMessage "Adding apple keyboard configuration in xorg"
    cat > "/etc/X11/xorg.conf.d/00-keyboard.conf" << EOF
Section "InputClass"
  Identifier "system-keyboard"
  MatchIsKeyboard "on"
  Option "XkbLayout" "fr"
  Option "XkbModel" "pc105"
  Option "XkbVariant" "mac"
EndSection
EOF

    printMessage "Adding Apple keyboard module"
    echo -en "options hid_apple iso_layout=${appleKeyboardConfig}\noptions hid_apple fnmode=1" > /etc/modprobe.d/hid_apple.conf
  fi
}

addAliceDarkTheme() {
  if ! [ -z "$aliceDarkThemeRepo" ]; then
    printMessage "Adding Alice dark theme"
    workDir="/tmp/aliceDarkTheme"
    userHomeDir="/home/$(logname)"
    userConfigDir="/home/$(logname)/.config"
    printMessage "Clone ${aliceDarkThemeRepo} in ${workDir}"
    git clone ${aliceDarkThemeRepo} ${workDir}
    params="-rltv --stats --progress"

    if (ls ${workDir}/${desktopEnvironment} &> /dev/null) ;then
      printMessage "Copy ${desktopEnvironment} files in ${userConfigDir}/ with rsync"
      su - $(logname) -c "rsync ${params} ${workDir}/${desktopEnvironment} ${userConfigDir}/"
    fi

    printMessage "Copy dotConfig/* files in ${userConfigDir}/ with rsync"
    su - $(logname) -c "rsync ${params} ${workDir}/dotConfig/* ${userConfigDir}/"
    printMessage "Copy dotFiles/* files in ${userHomeDir}/ with rsync"
    su - $(logname) -c "rsync ${params} ${workDir}/dotFiles/ ${userHomeDir}/"
    printMessage "Copy dotMozilla/* files in ${userHomeDir}/ with rsync"
    su - $(logname) -c "rsync ${params} ${workDir}/dotMozilla/ ${userHomeDir}/.mozilla"
    printMessage "Copy gtkrc files in /etc/gtk... for dark theme support with apps launched with sudo command"
    cp ${workDir}/dotFiles/.gtkrc-2.0 /etc/gtk-2.0/gtkrc
    cp ${workDir}/dotConfig/gtk-3.0/settings.ini /etc/gtk-3.0/settings.ini

    printMessage "Create dconf profile directory"
    mkdir -p /etc/dconf/{profile,db/local.d}
    printMessage "Add user config file in dconf"
    echo -en "service-db:keyfile/user\nuser-db:user" > /etc/dconf/profile/user

    printMessage "Add xedEditor.ini in dconf"
    cat ${workDir}/xedEditor.ini > ${workDir}/user.txt
    printMessage "Create dconf directory in ${userConfigDir}"
    su - $(logname) -c "mkdir -p ${userConfigDir}/dconf"

    if (cat ${workDir}/${desktopEnvironment}Desktop.ini &> /dev/null) ;then
      printMessage "Add ${desktopEnvironment}Desktop.ini in dconf"
      cat ${workDir}/${desktopEnvironment}Desktop.ini >> ${workDir}/user.txt
    fi

    printMessage "Compile dconf file"
    cp -v ${workDir}/user.txt /etc/dconf/db/local.d/user
    dconf compile /etc/dconf/db/user /etc/dconf/db/local.d
    printMessage "Copy user.txt file in ${userConfigDir}/dconf"
    su - $(logname) -c "cp ${workDir}/user.txt ${userConfigDir}/dconf/"
    printMessage "Remove ${workDir}. End of addAliceDarkTheme function."
    rm -rf ${workDir}
  fi
}

prepare() {
  askUpdateMirrorList
  askInstallVideoDrivers
  askInstallMultimediaUtils
  askAddBluetoothSupport
  askDesktopEnvironmentInstall
  askAddAppleKeyboardConfig
  askInstallWorkOfficeUtils
  askInstallDevelopmentUtils
  askAddAlicePackages
  askAddAliceDarkTheme
  printMessage "End of preparation, start install!"
}

main() {
  handleError
  isRootUser
  prepare
  installPackages
  addBluetoothSupport
  addAppleKeyboardConfig
  addAliceDarkTheme
  printMessage "Congratulation, all is Done!"
}

time main

exit 0
