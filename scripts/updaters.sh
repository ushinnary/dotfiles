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

# Check if rust is installed
if command -v rustup >/dev/null; then
  rustup update
else
  echo "rust is not installed on this system."
fi

# Check if cargo is installed
if command -v cargo >/dev/null; then
  cargo-install-update install-update --all
else
  echo "cargo is not installed on this system."
fi

# Check if ollama is installed
if command -v ollama >/dev/null; then
  curl -fsSL https://ollama.com/install.sh | sh
else
  echo "Ollama is not installed"
fi
