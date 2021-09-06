#!/bin/bash

# Video drivers Nvidia See https://wiki.archlinux.org/title/NVIDIA
# Video drivers Nouveau See https://wiki.archlinux.org/title/Nouveau
# Video drivers Intel See https://wiki.archlinux.org/title/Intel_graphics
# Video drivers Amd See https://wiki.archlinux.org/title/AMDGPU
# Video drivers OpenGL See https://wiki.archlinux.org/title/OpenGL
videoDriverPackages=""

audioVideoImagePackages=""

desktopEnvPackages=""

customDarkThemeRepo=""

appleKeyboardConfig=""

aurPackages=""

# Hardware Video accel. Nvidia/Intel/Amd See https://wiki.archlinux.org/title/Hardware_video_acceleration
hdwVideoAccelPackages="mesa-vdpau mesa-demos libva-mesa-driver libva-vdpau-driver libva-utils libvdpau-va-gl"

# Audio/Video codec and GStreamer support
# https://wiki.archlinux.org/title/Codecs_and_containers
# https://wiki.archlinux.org/title/GStreamer
audioVideoCodecGst="gst-libav gst-plugins-bad gst-plugins-base gst-plugins-good gst-plugins-ugly libde265 gstreamer-vaapi gstreamer libfdk-aac libmad libmpcdec libvorbis libdca libwebp libavif libheif libdv libmpeg2 libtheora libvpx libdvdread libdvdnav libdvdcss libcdio libisoburn fdkaac aom dav1d rav1e svt-av1 x264 x265 xvidcore ogmtools ffmpeg ffmpegthumbnailer faac faad2 lame flac wavpack a52dec opencore-amr opus speex celt pavucontrol pulseaudio pulseaudio-alsa alsa-utils alsa-plugins"

# Fonts See: https://wiki.archlinux.org/title/Fonts
commonFontPackages="terminus-font noto-fonts ttf-bitstream-vera ttf-dejavu ttf-droid ttf-font-awesome ttf-freefont ttf-inconsolata ttf-liberation ttf-roboto"

# Web browser and common extensions
webBrowserPackages="firefox firefox-i18n-fr firefox-ublock-origin firefox-dark-reader firefox-extension-passff firefox-extension-privacybadger torbrowser-launcher"

# System Utilities
commonSystemUtilsPackages="gvfs gvfs-gphoto2 gvfs-afc gvfs-goa gvfs-google gvfs-mtp gvfs-nfs gvfs-smb vim rsync htop neofetch xed alacritty chezmoi"

# Archive utilities
archiveUtilsPackages="xarchiver zip unzip unrar p7zip"

# File system utilities
fileSystemUtilsPackages="gptfdisk mtools xfsprogs dosfstools gparted f2fs-tools exfatprogs gpart udftools"

# Xorg
xorgPackages="xorg xorg-xinit xorg-server xdg-utils xdg-user-dirs xbindkeys xcompmgr numlockx tumbler"

# Icon and dark themes
darkThemesPackages="arc-gtk-theme arc-icon-theme papirus-icon-theme materia-gtk-theme gtk-engine-murrine kvantum-theme-materia"

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
  select opt in nvidia nouveau intel amd default ; do
  case $opt in
    nvidia)
      videoDriverPackages="nvidia-utils nvidia-dkms nvtop"
      printMessage "Nvidia (official) video drivers: ${videoDriverPackages}"
      break
      ;;
    nouveau)
      videoDriverPackages="xf86-video-nouveau"
      printMessage "Nouveau (open source Nvidia) video drivers: ${videoDriverPackages}"
      break
      ;;
    intel)
      videoDriverPackages="libva-intel-driver intel-media-driver xf86-video-intel"
      printMessage "Intel video drivers: ${videoDriverPackages}"
      break
      ;;
    amd)
      videoDriverPackages="xf86-video-amdgpu xf86-video-ati radeontop vulkan-radeon amdvlk"
      printMessage "Amd video drivers: ${videoDriverPackages}"
      break
      ;;
    default)
      videoDriverPackages="mesa mesa-demos xf86-video-vesa"
      printMessage "Default generic video drivers: ${videoDriverPackages}"
      break
      ;;
    *) 
      echo "Invalid option $REPLY"
      ;;
    esac
  done
}

askInstallAudioVideoImageUtils() {
  printMessage "Audio/Video/Image utilities"
  
  PS3="Would you install Audio/Video/Image utilities: "
  select opt in yes no ; do
  case $opt in
    yes)
      audioVideoImagePackages="asunder vlc handbrake quodlibet mpv nomacs llpp shotwell gimp inkscape scour vokoscreen"
      printMessage "Audio/Video/Image utilities packages: ${audioVideoImagePackages}"
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

askDesktopEnvironmentInstall() {
  printMessage "Choose desktop environment to install"

  PS3="Select which desktop environment to install: "
  select opt in xfce i3wm openbox dwm ; do
  case $opt in
    xfce)
      desktopEnvPackages="xfce4 xfce4-goodies"
      printMessage "Xfce packages: ${desktopEnvPackages}"
      break
      ;;
    i3wm)
      desktopEnvPackages="i3wm"
      printMessage "I3 window manager packages (not implemented): ${desktopEnvPackages}"
      break
      ;;
    openbox)
      desktopEnvPackages="openbox"
      printMessage "Openbox packages (not implemented): ${desktopEnvPackages}"
      break
      ;;
    dwm)
      desktopEnvPackages="dwm"
      printMessage "Dwm packages (not implemented): ${desktopEnvPackages}"
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
      appleKeyboardConfig="yes"
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

askAddAurPackages() {
  printMessage "Install a login manager, package manager GUI and Visual studio code"

  PS3="Would you add Aur packages: "
  select opt in yes no ; do
  case $opt in
    yes)
      aurPackages="ly visual-studio-code-bin pamac-aur downgrade"
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

askAddCustomDarkTheme() {
  printMessage "Custom dark theme"
  
  PS3="Would you add custom dark theme: "
  select opt in yes no ; do
  case $opt in
    yes)
      customDarkThemeRepo="https://github.com/TituxMetal/xfce-dotfiles.git"
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

installAurPackageManager() {
  if ! (yay --version &> /dev/null); then
    printMessage "Installing yay package manager"
    su - $(logname) -c "git clone https://aur.archlinux.org/yay-bin.git /tmp/yay"
    su - $(logname) -c "cd /tmp/yay && makepkg -sri --noconfirm"
    rm -rf /tmp/yay
  fi
}

installAurPackages() {
  if ! [ -z "${aurPackages}" ]; then
    installAurPackageManager

    printMessage "Installing aur packages: ${aurPackages}"
    su - $(logname) -c "yay -Sy --nodiffmenu --removemake --noconfirm ${aurPackages}"
    systemctl enable ly
  fi
}

installBluetoothSupport() {
  # Bluetooth support See: https://wiki.archlinux.org/title/Bluetooth
  if ( dmesg | grep Bluetooth > /dev/null ); then
    bluetoothPakages="bluez bluez-utils blueman pulseaudio-bluetooth"
    printMessage "Installing bluetooth support: ${bluetoothPakages}"
    pacman -S --noconfirm --needed bluez bluez-utils blueman pulseaudio-bluetooth
    systemctl enable bluetooth.service
  fi
}

installPackages() {
  declare -a packages
  packages=("${videoDriverPackages}" "${audioVideoImagePackages}" "${desktopEnvPackages}" "${hdwVideoAccelPackages}" "${audioVideoCodecGst}" "${commonFontPackages}" "${webBrowserPackages}" "${commonSystemUtilsPackages}" "${archiveUtilsPackages}" "${fileSystemUtilsPackages}" "${xorgPackages}" "${darkThemesPackages}")

  printMessage "Clear Pacman cache"
  pacman -Scc --noconfirm

  pacman -Syu --noconfirm

  pacman-key --init && pacman-key --populate archlinux

  printMessage "Packages that would be installed: ${packages[*]}"
  pacman -Sy --noconfirm --needed ${packages[*]}
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
    cat > "/etc/modprobe.d/hid_apple.conf" << EOF
options hid_apple iso_layout=1
options hid_apple fnmode=1
EOF

  fi
}

addCustomDarkTheme() {
  if ! [ -z "$customDarkThemeRepo" ]; then
    printMessage "Adding custom dark theme"
    git clone ${customDarkThemeRepo} /tmp/customDarkTheme
    rsync -rltv --stats --progress --exclude=.git /tmp/customDarkTheme/ /etc/xdg/xfce4/
    rm -rf /tmp/customDarkTheme
  fi  
}

prepare() {
  askUpdateMirrorList
  askInstallVideoDrivers
  askInstallAudioVideoImageUtils
  askDesktopEnvironmentInstall
  askAddAppleKeyboardConfig
  askAddAurPackages
  askAddCustomDarkTheme
}

main() {
  handleError
  isRootUser
  prepare
  installPackages
  installBluetoothSupport
  addAppleKeyboardConfig
  installAurPackages
  addCustomDarkTheme
}

time main

exit 0
