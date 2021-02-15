!/bin/sh

# Installation process for Arch system.
# Should only be run to install a new system, after disk formatting

# lsblk - look for drive
# dd if=/dev/zero of=/dev/DRIVE_HERE status=progress
# fdisk > g > n +512M (BIOS part) > t 4 (BIOS) > n > accept defaults (full disk) > w
# mkfs.ext4 /dev/DRIVE_1
# mount /dev/DRIVE_1 /mnt
# pacstrap /mnt base base-devel linux linux-firmware
# genfstab -U /mnt >> /mnt/etc/fstab

# arch-chroot /mnt archinstall.sh

echo "archbox" > /etc/hostname
sudo pacman -Syu --noconfirm

hwclock --systohc
timedatectl set-ntp true
timedatectl set-timezone "America/New_York"

echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen
locale-gen
echo "LANG=en_US.UTF-8" > /etc/locale.conf

echo "%wheel ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

# Install and autostart NetworkManager
sudo pacman -S --noconfirm networkmanager
sudo systemctl enable NetworkManager.service

# Enable AUR through yay
if [ ! -d "$HOME/yay" ]; then
  OLD_DIR=$(pwd)
  git clone https://aur.archlinux.org/yay.git $HOME/yay
  cd $HOME/yay
  makepkg -s
  ls | grep yay*.zst | xargs sudo pacman -U
  cd $OLD_DIR
fi

# neovim
sudo pacman -S --noconfirm neovim
mkdir -p $CONFIG_DIR/nvim
mkdir -p $CONFIG_DIR/nvim/undo
ln -sf $DOTFILES_DIR/nvim/init.vim $CONFIG_DIR/nvim

# Xorg
sudo pacman -S --noconfirm xorg xorg-xinit
rm -rf $CONFIG_DIR/X11
ln -s $DOTFILES_DIR/X11 $CONFIG_DIR

# i3
sudo pacman -S --noconfirm i3-wm i3status dmenu
rm -rf $CONFIG_DIR/i3
ln -s $DOTFILES_DIR/i3 $CONFIG_DIR

# Terminal, clipboard sharing with vim, and font of choice
sudo pacman -S --noconfirm rxvt-unicode xsel xclip ttf-fira-code

# Firefox
sudo pacman -S --noconfirm firefox

# Misc. utilities

sudo pacman -S --noconfirm htop

## Radeon Drivers
sudo pacman -S --noconfirm mesa libva-mesa-driver vulkan-radeon

# Audo fix
#install_pulse

# Configuring default microphone
#echo "Grab microphone device id:"
#sudo pacmd list-sources | grep -e device.string -e 'name:'
#echo "Now paste this at the bottom of /etc/pulse/default.pa:"
#echo "set-default-source DEVICE-ID-HERE"

# Screen capture
sudo pacman -S --noconfirm ffmpeg
