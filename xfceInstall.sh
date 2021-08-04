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

askUpdateMirrorList() {
  PS3="Would you update mirror list: "
  select opt in yes no ; do
  case $opt in
    yes)
      # Reflector See: https://wiki.archlinux.org/title/Reflector
      printMessage "Updating mirror list"
      sudo reflector --country France --protocol https --age 6 --sort rate --verbose --save /etc/pacman.d/mirrorlist
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
  PS3="Select which video drivers to install: "
  select opt in nvidia nouveau intel amd default ; do
  case $opt in
    nvidia)
      # Video drivers Nvidia See https://wiki.archlinux.org/title/NVIDIA
      printMessage "Installing Nvidia (official) video drivers"
      sudo pacman -S --noconfirm nvidia-utils nvidia-dkms nvtop
      break
      ;;
    nouveau)
      # Video drivers Nouveau See https://wiki.archlinux.org/title/Nouveau
      printMessage "Installing Nouveau (open source Nvidia) video drivers"
      sudo pacman -S --noconfirm xf86-video-nouveau
      break
      ;;
    intel)
      # Video drivers Intel See https://wiki.archlinux.org/title/Intel_graphics
      printMessage "Installing Intel video drivers"
      sudo pacman -S --noconfirm libva-intel-driver intel-media-driver xf86-video-intel
      break
      ;;
    amd)
      # Video drivers Amd See https://wiki.archlinux.org/title/AMDGPU
      printMessage "Installing Amd video drivers"
      sudo pacman -S --noconfirm xf86-video-{amdgpu,ati} radeontop vulkan-radeon amdvlk
      break
      ;;
    default)
      # Video drivers OpenGL See https://wiki.archlinux.org/title/OpenGL
      printMessage "Installing default generic video drivers"
      sudo pacman -S --noconfirm mesa mesa-demos xf86-video-vesa
      break
      ;;
    *) 
      echo "Invalid option $REPLY"
      ;;
    esac
  done
}

askInstallHdwVideoAccLib() {
  PS3="Would you install hardware video acceleration libs: "
  select opt in yes no ; do
  case $opt in
    yes)
      # Graphics accel. Nvidia/Intel/Amd See https://wiki.archlinux.org/title/Hardware_video_acceleration
      printMessage "Installing hardware video acceleration libs"
      sudo pacman -S --noconfirm mesa-{vdpau,demos} libva-{mesa-driver,vdpau-driver,utils} libvdpau-va-gl
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

askInstallGstreamerSupport() {
  PS3="Would you install Gstreamer support tools: "
  select opt in yes no ; do
  case $opt in
    yes)
      # GStreamer support See https://wiki.archlinux.org/title/GStreamer
      printMessage "Installing Gstreamer support tools"
      sudo pacman -S --noconfirm gst-{libav,plugins-bad,plugins-base,plugins-good,plugins-ugly} libde265 gstreamer-vaapi gstreamer
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

askInstallAudioVideoCodec() {
  PS3="Would you install audio/video codecs: "
  select opt in yes no ; do
  case $opt in
    yes)
      # Audio/Video codec support See: https://wiki.archlinux.org/title/Codecs_and_containers
      printMessage "Installing audio/video codecs"
      sudo pacman -S --noconfirm lib{fdk-aac,mad,mpcdec,vorbis,dca,webp,avif,heif,dv,mpeg2,theora,vpx,dvdread,dvdnav,dvdcss,cdio,isoburn} fdkaac aom dav1d rav1e svt-av1 x264 x265 xvidcore ogmtools ffmpeg faac faad2 lame flac wavpack a52dec opencore-amr opus speex celt
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

askInstallBluetoothSupport() {
  PS3="Would you install bluetooth support: "
  select opt in yes no ; do
  case $opt in
    yes)
      # Bluetooth support See: https://wiki.archlinux.org/title/Bluetooth
      printMessage "Installing bluetooth support"
      sudo pacman -S --noconfirm bluez bluez-utils blueman pulseaudio-bluetooth
      sudo systemctl enable bluetooth.service
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

askInstallBaseFonts() {
  PS3="Would you install base fonts: "
  select opt in yes no ; do
  case $opt in
    yes)
      # Fonts See: https://wiki.archlinux.org/title/Fonts
      printMessage "Installing base fonts"
      sudo pacman -S --noconfirm noto-fonts ttf-{bitstream-vera,dejavu,droid,font-awesome,freefont,inconsolata,liberation,roboto}
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

# @TODO Separate in more categorized choices, eg. audio utils, archives utils...
askInstallDesktopUtils() {
  PS3="Would you install desktop utilities: "
  select opt in yes no ; do
  case $opt in
    yes)
      # Audio/Video/Image utilities
      printMessage "Installing desktop utilities"
      sudo pacman -S --noconfirm gvfs gvfs-{gphoto2,afc,goa,google,mtp,nfs,smb} vlc handbrake quodlibet mpv asunder nomacs gptfdisk mtools xfsprogs dosfstools xarchiver zip unzip unrar p7zip llpp shotwell gimp inkscape scour xcompmgr tumbler ffmpegthumbnailer rsync htop gparted f2fs-tools exfatprogs gpart udftools vokoscreen neofetch
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

# @TODO Add more choices, eg. xfce, i3, openbox, dwm...
askInstallDesktopManager() {
  PS3="Would you install desktop xfce desktop + theme: "
  select opt in yes no ; do
  case $opt in
    yes)
      printMessage "Installing desktop xfce desktop + theme"
      sudo pacman -S --noconfirm xorg xorg-{xinit,twm,apps} xdg-{utils,user-dirs} xbindkeys pavucontrol xfce4 xfce4-goodies numlockx firefox firefox-{i18n-fr,ublock-origin} arc-gtk-theme arc-icon-theme papirus-icon-theme materia-gtk-theme kvantum-theme-materia terminus-font vim xed
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
  askUpdateMirrorList
  askInstallVideoDrivers
  askInstallHdwVideoAccLib
  askInstallGstreamerSupport
  askInstallAudioVideoCodec
  askInstallBluetoothSupport
  askInstallBaseFonts
  askInstallDesktopUtils
  askInstallDesktopManager
}

time main

exit 0
