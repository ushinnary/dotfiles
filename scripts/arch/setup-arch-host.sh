#!/bin/bash
sudo pacman -S --needed git avahi \
  gstreamer gst-plugins-good gst-plugins-bad \
  openssh vi \
  terminus-font ttf-dejavu ttf-liberation otf-font-awesome ttf-nerd-fonts-symbols \
  wpa_supplicant ufw podman podman-compose \
  networkmanager pipewire pipewire-pulse bluez bluez-utils bluez-libs distrobox \
  wget curl unzip wl-clipboard tailscale ttf-nerd-fonts-symbols-mono

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
#   # Turn on Docker protections
sudo ufw reload

# Enable essential services
sudo systemctl enable NetworkManager
sudo systemctl enable bluetooth
sudo systemctl enable avahi-daemon
sudo systemctl enable --now tailscaled
systemctl --user enable podman.socket

# Detect if running on a laptop (battery present)
if ls /sys/class/power_supply/BAT* 1>/dev/null 2>&1; then
  sudo pacman -S --needed tlp
  sudo systemctl enable tlp
else
  sudo pacman -S --needed power-profiles-daemon
  sudo systemctl enable power-profiles-daemon
fi
