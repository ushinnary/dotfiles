#!/bin/bash
sudo dnf install openssl-devel cmake libxcb libX11-devel fontconfig-devel perl &&
  sudo dnf copr enable atim/lazygit -y &&
  sudo dnf install lazygit &&
  sudo dnf install fzf &&
  sudo dnf install dotnet-sdk-9.0 &&
  sudo dnf install @development-tools &&
  sudo dnf install luarocks &&
  # Install vs code so it could get updates
  sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc &&
  echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\nautorefresh=1\ntype=rpm-md\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" | sudo tee /etc/yum.repos.d/vscode.repo >/dev/null &&
  dnf check-update &&
  sudo dnf install code
