#!/bin/bash
sudo pacman -S --needed git avahi \
  gstreamer gst-plugins-good gst-plugins-bad \
  openssh vi \
  terminus-font ttf-dejavu ttf-liberation otf-font-awesome ttf-nerd-fonts-symbols \
  wpa_supplicant ufw podman podman-compose \
  networkmanager pipewire pipewire-pulse bluez bluez-utils bluez-libs distrobox \
  wget curl unzip wl-clipboard tailscale ttf-nerd-fonts-symbols-mono \
  rustup zoxide yazi starship nushell stow neovim lazygit fd ripgrep fzf difftastic \
  snapper

sudo snapper -c root create-config /
sudo snapper -c root create --description "initial snapshot"

sudo pacman -S --needed snap-pac

sudo chsh -s /usr/bin/nu
#   # Allow nothing in, everything out
sudo ufw default deny incoming
sudo ufw default allow outgoing
#
#   # Allow ports for LocalSend
sudo ufw allow 53317/udp
sudo ufw allow 53317/tcp
#
#   # Allow SSH in
sudo ufw allow 22/tcp
#
#   # Turn on the firewall
sudo ufw enable
#
#   # Use latest configuration for firewall
sudo ufw reload

# Enable essential services
sudo systemctl enable NetworkManager
sudo systemctl enable bluetooth
sudo systemctl enable avahi-daemon
sudo systemctl enable --now sshd
sudo systemctl enable --now tailscaled

# User services
systemctl --user enable --now podman.socket

# Detect if running on a laptop (battery present)
if ls /sys/class/power_supply/BAT* 1>/dev/null 2>&1; then
  sudo pacman -S --needed tlp
  sudo systemctl enable tlp
else
  sudo pacman -S --needed power-profiles-daemon
  sudo systemctl enable power-profiles-daemon
fi
