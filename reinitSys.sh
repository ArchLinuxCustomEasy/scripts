# Mark all packages as dependencies
pacman -D --asdeps $(pacman -Qqe)

# Mark base packages as explicit
pacman -D --asexplicit base linux linux-firmware vim nano intel-ucode bash-completion git openssh rsync linux-headers efibootmgr dhcpcd ntp modemmanager iwd inetutils bind nss-mdns reflector avahi sudo xf86-video-vesa

# Remove all non explicit packages
pacman -Qttdq | pacman -Rns -