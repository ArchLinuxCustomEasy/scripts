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

askUpdateMirrorList() {
  printMessage "Update mirror list"
  
  PS3="Would you update mirror list: "
  select opt in yes no ; do
  case $opt in
    yes)
      # Reflector See: https://wiki.archlinux.org/title/Reflector
      printMessage "Updating mirror list"
      systemctl start reflector
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
  select opt in nvidia nouveau intel amd default ; do
  case $opt in
    nvidia)
      # Video drivers Nvidia See https://wiki.archlinux.org/title/NVIDIA
      printMessage "Installing Nvidia (official) video drivers"
      pacman -S --noconfirm nvidia-utils nvidia-dkms nvtop
      break
      ;;
    nouveau)
      # Video drivers Nouveau See https://wiki.archlinux.org/title/Nouveau
      printMessage "Installing Nouveau (open source Nvidia) video drivers"
      pacman -S --noconfirm xf86-video-nouveau
      break
      ;;
    intel)
      # Video drivers Intel See https://wiki.archlinux.org/title/Intel_graphics
      printMessage "Installing Intel video drivers"
      pacman -S --noconfirm libva-intel-driver intel-media-driver xf86-video-intel
      break
      ;;
    amd)
      # Video drivers Amd See https://wiki.archlinux.org/title/AMDGPU
      printMessage "Installing Amd video drivers"
      pacman -S --noconfirm xf86-video-{amdgpu,ati} radeontop vulkan-radeon amdvlk
      break
      ;;
    default)
      # Video drivers OpenGL See https://wiki.archlinux.org/title/OpenGL
      printMessage "Installing default generic video drivers"
      pacman -S --noconfirm mesa mesa-demos xf86-video-vesa
      break
      ;;
    *) 
      echo "Invalid option $REPLY"
      ;;
    esac
  done
}

askInstallHdwVideoAccLib() {
  printMessage "Hardware acceleration support"
  
  PS3="Would you install hardware video acceleration libs: "
  select opt in yes no ; do
  case $opt in
    yes)
      # Graphics accel. Nvidia/Intel/Amd See https://wiki.archlinux.org/title/Hardware_video_acceleration
      printMessage "Installing hardware video acceleration libs"
      pacman -S --noconfirm mesa-{vdpau,demos} libva-{mesa-driver,vdpau-driver,utils} libvdpau-va-gl
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
  printMessage "Gstreamer support"
  
  PS3="Would you install Gstreamer support tools: "
  select opt in yes no ; do
  case $opt in
    yes)
      # GStreamer support See https://wiki.archlinux.org/title/GStreamer
      printMessage "Installing Gstreamer support tools"
      pacman -S --noconfirm gst-{libav,plugins-bad,plugins-base,plugins-good,plugins-ugly} libde265 gstreamer-vaapi gstreamer
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
  printMessage "Audio/Video codec"
  
  PS3="Would you install audio/video codecs: "
  select opt in yes no ; do
  case $opt in
    yes)
      # Audio/Video codec support See: https://wiki.archlinux.org/title/Codecs_and_containers
      printMessage "Installing audio/video codecs"
      pacman -S --noconfirm lib{fdk-aac,mad,mpcdec,vorbis,dca,webp,avif,heif,dv,mpeg2,theora,vpx,dvdread,dvdnav,dvdcss,cdio,isoburn} fdkaac aom dav1d rav1e svt-av1 x264 x265 xvidcore ogmtools ffmpeg faac faad2 lame flac wavpack a52dec opencore-amr opus speex celt
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
  printMessage "Bluetooth support"
  
  PS3="Would you install bluetooth support: "
  select opt in yes no ; do
  case $opt in
    yes)
      # Bluetooth support See: https://wiki.archlinux.org/title/Bluetooth
      printMessage "Installing bluetooth support"
      pacman -S --noconfirm bluez bluez-utils blueman pulseaudio-bluetooth
      systemctl enable bluetooth.service
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
  printMessage "Base fonts"
  
  PS3="Would you install base fonts: "
  select opt in yes no ; do
  case $opt in
    yes)
      # Fonts See: https://wiki.archlinux.org/title/Fonts
      printMessage "Installing base fonts"
      pacman -S --noconfirm noto-fonts ttf-{bitstream-vera,dejavu,droid,font-awesome,freefont,inconsolata,liberation,roboto}
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
  printMessage "Various desktop utilities"
  
  PS3="Would you install desktop utilities: "
  select opt in yes no ; do
  case $opt in
    yes)
      # Audio/Video/Image utilities
      printMessage "Installing desktop utilities"
      pacman -S --noconfirm gvfs gvfs-{gphoto2,afc,goa,google,mtp,nfs,smb} vlc handbrake quodlibet mpv asunder nomacs gptfdisk mtools xfsprogs dosfstools xarchiver zip unzip unrar p7zip llpp shotwell gimp inkscape scour xcompmgr tumbler ffmpegthumbnailer rsync htop gparted f2fs-tools exfatprogs gpart udftools vokoscreen neofetch
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
  printMessage "Xfce desktop and theme"
  
  PS3="Would you install xfce desktop + theme: "
  select opt in yes no ; do
  case $opt in
    yes)
      printMessage "Installing xfce desktop + theme"
      pacman -S --noconfirm xorg xorg-{xinit,twm,apps} xdg-{utils,user-dirs} xbindkeys pavucontrol xfce4 xfce4-goodies numlockx firefox firefox-{i18n-fr,ublock-origin} arc-gtk-theme arc-icon-theme papirus-icon-theme materia-gtk-theme kvantum-theme-materia terminus-font vim xed
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

askAddAppleKeyboardConfig() {
  printMessage "Apple keyboard configuration"

  PS3="Would you add Apple keyboard configuration for Xorg: "
  select opt in yes no ; do
  case $opt in
    yes)
      printMessage "Adding apple keyboard configuration in xorg"
      echo 'Section "InputClass"
        Identifier "system-keyboard"
        MatchIsKeyboard "on"
        Option "XkbLayout" "fr"
        Option "XkbModel" "pc105"
        Option "XkbVariant" "mac"
      EndSection' > /etc/X11/xorg.conf.d/00-keyboard.conf

      printMessage "Adding Apple keyboard module"
      echo "options hid_apple iso_layout = 0
      options hid_apple fnmode = 1" > /etc/modprobe.d/hid_apple.conf
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

askAddCustomXfceTheme() {
  printMessage "Custom Xfce dark theme"
  
  PS3="Would you add custom Xfce dark theme: "
  select opt in yes no ; do
  case $opt in
    yes)
      printMessage "Adding custom Xfce dark theme"
      su - $(logname) -c "git clone https://github.com/TituxMetal/xfce-dotfiles.git /tmp/dotfiles"
      su - $(logname) -c "rsync -rltv --stats --progress --exclude=.git /tmp/dotfiles/ ~/"
      su - $(logname) -c "rm -rf /tmp/dotfiles"
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
  askUpdateMirrorList
  askInstallVideoDrivers
  askInstallHdwVideoAccLib
  askInstallGstreamerSupport
  askInstallAudioVideoCodec
  askInstallBluetoothSupport
  askInstallBaseFonts
  askInstallDesktopUtils
  askInstallDesktopManager
  askAddAppleKeyboardConfig
  askAddCustomXfceTheme
}

time main

exit 0
