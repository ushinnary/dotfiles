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
  # Ghostty
  #sudo dnf copr enable scottames/ghostty && sudo dnf install ghostty &&
  sudo dnf install btop -y &&
  sudo dnf install fuse-libs -y &&
  sudo dnf install libappindicator-gtk3 -y &&
  sudo dnf install stow -y &&
  sudo dnf install wget -y

dotnet tool install -g git-credential-manager
git-credential-manager configure
# Antigravity
sudo tee /etc/yum.repos.d/antigravity.repo <<EOL
[antigravity-rpm]
name=Antigravity RPM Repository
baseurl=https://us-central1-yum.pkg.dev/projects/antigravity-auto-updater-dev/antigravity-rpm
enabled=1
gpgcheck=0
EOL
sudo dnf install antigravity
