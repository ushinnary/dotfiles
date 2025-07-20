#!/bin/bash
sudo dnf update -y &&
  sudo dnf install openssl-devel cmake libxcb libX11-devel fontconfig-devel perl -y &&
  sudo dnf copr enable atim/lazygit -y &&
  sudo dnf install lazygit -y &&
  sudo dnf install fzf -y &&
  sudo dnf install dotnet-sdk-8.0 -y &&
  sudo dnf install @development-tools -y &&
  sudo dnf install luarocks -y &&
  # Install vs code so it could get updates
  sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc &&
  echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\nautorefresh=1\ntype=rpm-md\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" | sudo tee /etc/yum.repos.d/vscode.repo >/dev/null &&
  dnf check-update &&
  sudo dnf install code -y &&
  sudo dnf install neovim -y &&
  sudo dnf install https://github.com/wezterm/wezterm/releases/download/nightly/wezterm-nightly-fedora40.rpm -y &&
  sudo dnf install btop -y &&
  sudo dnf install fuse-libs -y &&
  sudo dnf install libappindicator-gtk3 -y &&
  sudo dnf install stow -y &&
  sudo dnf install wget -y
