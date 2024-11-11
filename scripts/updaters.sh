#!/bin/bash

# Check if apt is installed
if command -v apt >/dev/null; then
  echo "apt is installed. Running update..."
  sudo apt update
  sudo apt upgrade -y
else
  echo "apt is not installed on this system."
fi

# Check if dnf is installed
if command -v dnf >/dev/null; then
  echo "dnf is installed. Running update..."
  sudo dnf upgrade -y
else
  echo "dnf is not installed on this system."
fi

# Check if cargo is installed
if command -v cargo >/dev/null; then
  cargo-install-update install-update --all
else
  echo "cargo is not installed on this system."
fi

# Check if neovim is installed
if command -v nvim >/dev/null; then
  echo "neovim is installed. Updating lazyvim..."
  nvim --headless +Lazy! sync +qall
else
  echo "neovim is not installed on this system."
fi
