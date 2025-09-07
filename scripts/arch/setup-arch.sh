#!/bin/bash
sudo pacman -S --needed git base-devel \
  neovim fzf python go \
  ttf-nerd-fonts-symbols-mono lazygit wget curl unzip \
  inetutils man dotnet-sdk stow wl-clipboard gnome-keyring

# After installing, use distrobox-export to make needed tools available on host:
if command -v distrobox-export >/dev/null 2>&1; then
  distrobox-export --bin /usr/bin/nvim
  distrobox-export --bin /usr/bin/lazygit
  sudo ln -s /usr/bin/distrobox-host-exec /usr/local/bin/podman
  sudo ln -s /usr/bin/distrobox-host-exec /usr/local/bin/podman-compose
fi

mkdir ~/builds

# Builded apps
# https://aur.archlinux.org/visual-studio-code-bin.git
# https://aur.archlinux.org/packages/wezterm-git/
