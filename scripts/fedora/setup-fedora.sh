#!/bin/bash
sudo dnf update -y &&
  sudo dnf install openssl-devel cmake libxcb libX11-devel fontconfig-devel perl -y &&
  sudo dnf copr enable atim/lazygit -y &&
  sudo dnf install lazygit -y &&
  sudo dnf install fzf -y &&
  sudo dnf install dotnet-sdk-8.0 -y &&
  sudo dnf install @development-tools -y &&
  sudo dnf install luarocks -y &&
  sudo dnf install neovim -y &&
  sudo dnf install btop -y &&
  sudo dnf install fuse-libs -y &&
  sudo dnf install libappindicator-gtk3 -y &&
  sudo dnf install stow -y &&
  sudo dnf install wget -y

dotnet tool install -g git-credential-manager
git-credential-manager configure
