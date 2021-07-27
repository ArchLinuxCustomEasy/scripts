#!/bin/bash

sudo reflector --country France --protocol https --age 6 --sort rate --verbose --save /etc/pacman.d/mirrorlist

# Video drivers Amd See https://wiki.archlinux.org/title/AMDGPU
# sudo pacman -Sy xf86-video-{amdgpu,ati} radeontop vulkan-radeon amdvlk

# Video drivers intel See https://wiki.archlinux.org/title/Intel_graphics
# sudo pacman -Sy libva-intel-driver intel-media-driver xf86-video-intel

# Video drivers Nvidia See https://wiki.archlinux.org/title/Nouveau
# sudo pacman -Sy xf86-video-nouveau OR nvidia-utils nvidia-dkms

# Graphics accel. Nvidia/Intel/Amd See https://wiki.archlinux.org/title/Hardware_video_acceleration
sudo pacman -Sy mesa-{vdpau,demos} libva-{mesa-driver,vdpau-driver,utils} libvdpau-va-gl

# GStreamer support See https://wiki.archlinux.org/title/GStreamer
sudo pacman -Sy gst-{libav,plugins-bad,plugins-base,plugins-good,plugins-ugly} libde265 gstreamer-vaapi gstreamer

# Audio/Video codec support
sudo pacman -Sy lib{fdk-aac,mad,mpcdec,vorbis,dca,webp,avif,heif,dv,mpeg2,theora,vpx,dvdread,dvdnav,dvdcss,cdio,isoburn} fdkaac aom dav1d rav1e svt-av1 x264 x265 xvidcore ogmtools ffmpeg faac faad2 lame flac wavpack a52dec opencore-amr opus speex celt

# Bluetooth
# sudo pacman -Sy bluez bluez-utils blueman pulseaudio-bluetooth

# Fonts
sudo pacman -Sy noto-fonts ttf-{bitstream-vera,dejavu,droid,font-awesome,freefont,inconsolata,liberation,roboto}

# Xfce and themes
sudo pacman -S --noconfirm xorg xorg-{xinit,twm,apps} xdg-{utils,user-dirs} xbindkeys pavucontrol xfce4 xfce4-goodies numlockx firefox firefox-{i18n-fr,ublock-origin} arc-gtk-theme arc-icon-theme papirus-icon-theme materia-gtk-theme kvantum-theme-materia terminus-font vim xed code

# Login manager: lightdm lightdm-gtk-greeter lightdm-gtk-greeter-settings 

# Audio/Video/Image utilities
sudo pacman -S gvfs gvfs-{gphoto2,afc,goa,google,mtp,nfs,smb} vlc handbrake quodlibet mpv asunder nomacs gptfdisk mtools xfsprogs dosfstools xarchiver zip unzip unrar p7zip llpp shotwell gimp inkscape scour xcompmgr tumbler ffmpegthumbnailer rsync htop gparted f2fs-tools exfatprogs gpart udftools vokoscreen neofetch

# Start xfce
echo "numlockx on &
xset -dpms s off &
xbindkeys &
exec startxfce4" > $HOME/.xinitrc

