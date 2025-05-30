#!/bin/sh

# Check if system is running fedora and install all the packages
if command -v dnf >/dev/null 2>&1; then
  echo "Using fedora system. Starting installation."

  ./scripts/setup-fedora.sh
fi

# Setup rust
if ! command -v cargo >/dev/null 2>&1; then
  echo "Installing rust with dependencies"

  ./scripts/setup-rust.sh
fi

# Install latest stable NodeJS
if command -v fnm >/dev/null 2>&1; then
  fnm install --lts
fi

# Setup git
if command -v git >/dev/null 2>&1; then
  ./scripts/setup-git.sh
fi

# Apply config
stow alacritty/
stow lazygit/
stow nushell/
stow nvim/
stow starship/
stow wezterm/
stow zed/
stow zellij/
