#!/bin/bash
sudo dnf install openssl-devel cmake libxcb libX11-devel fontconfig-devel perl &&
  sudo dnf copr enable atim/lazygit -y &&
  sudo dnf install lazygit &&
  sudo dnf install fzf &&
  sudo dnf install dotnet-sdk-9.0 &&
  sudo dnf group install "C Development Tools and Libraries" "Development Tools"
