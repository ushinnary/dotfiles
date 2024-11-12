#!/bin/bash

# Function to check and update package manager
update_func() {
  local app=$1
  local update_cmd=$2

  if command -v "$app" >/dev/null; then
    echo "$update_cmd is installed. Running update..."
    eval "$update_cmd"
  else
    echo "$app is not installed on this system."
  fi
}

# Update apt if installed
update_func "apt" "sudo apt update && sudo apt upgrade -y"

# Update dnf if installed
update_func "dnf" "sudo dnf upgrade -y"

# Update rust if installed
update_func "rustup" "rustup update"

# Update all cargo installed packages
update_func "cargo" "cargo-install-update install-update --all"

# Update ollama if installed
update_func "ollama" "curl -fsSL https://ollama.com/install.sh | sh"