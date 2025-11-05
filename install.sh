#!/bin/bash

set -e

# Setup git
#if command -v git >/dev/null 2>&1; then
#  ./scripts/setup-git.sh
#fi

# Apply config
stow alacritty/
stow ghostty/
stow lazygit/
stow nushell/
stow nvim/
stow starship/
stow wezterm/
stow zed/
stow zellij/
stow kitty/
stow hypr/
stow waybar/

# Install fonts
# install_font Quicksand https://fonts.google.com/download?family=Quicksand
# install_font Sono https://fonts.google.com/download?family=Sono
# install_font SymbolsNerdFont https://github.com/ryanoasis/nerd-fonts/releases/latest/download/NerdFontsSymbolsOnly.tar.xz
