#!/bin/bash
sudo dnf install openssl-devel cmake libxcb libX11-devel fontconfig-devel perl &&
	sudo dnf group install "C Development Tools and Libraries" "Development Tools" &&
	sudo dnf copr enable atim/lazygit -y &&
	sudo dnf install lazygit
