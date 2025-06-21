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

FONT_DIR="$HOME/.local/share/fonts"
# Download and install Sono font
SONO_ZIP_URL="https://fonts.google.com/download?family=Sono"
if [ ! -f "$FONT_DIR/Sono-Regular.ttf" ]; then
  echo "Downloading Sono font..."
  wget -qO /tmp/Sono.zip "$SONO_ZIP_URL"
  unzip -o /tmp/Sono.zip -d /tmp/Sono
  cp /tmp/Sono/*.ttf "$FONT_DIR/"
  fc-cache -f
  echo "Sono font installed."
else
  echo "Sono font already installed."
fi

# Download and install Quicksand font
QUICKSAND_ZIP_URL="https://fonts.google.com/download?family=Quicksand"
if [ ! -f "$FONT_DIR/Quicksand-Regular.ttf" ]; then
  echo "Downloading Quicksand font..."
  wget -qO /tmp/Quicksand.zip "$QUICKSAND_ZIP_URL"
  unzip -o /tmp/Quicksand.zip -d /tmp/Quicksand
  cp /tmp/Quicksand/*.ttf "$FONT_DIR/"
  fc-cache -f
  echo "Quicksand font installed."
else
  echo "Quicksand font already installed."
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
