#!/usr/bin/env bash

set -euo pipefail

REPO_URL="${1:-https://github.com/ushinnary/dotfiles.git}"
WORKDIR="$(mktemp -d "${TMPDIR:-/tmp}/dotfiles-install.XXXXXX")"

require_cmd() {
  local cmd="$1"
  if ! command -v "$cmd" >/dev/null 2>&1; then
    echo "Missing required command: $cmd"
    exit 1
  fi
}

ensure_free_space() {
  local path="${1:-/tmp}"
  local min_gb="${2:-10}"
  local avail_kb

  avail_kb=$(df --output=avail -k "$path" | tail -n1 | tr -d '[:space:]')
  if [ -n "$avail_kb" ] && [ "$avail_kb" -lt $((min_gb * 1024 * 1024)) ]; then
    echo "ERROR: Less than ${min_gb}GB free at $(df --output=target "$path" | tail -n1)."
    echo "Please free space or set TMPDIR to a filesystem with more room."
    exit 1
  fi
}

pick_host() {
  local -a hosts
  local index=1
  local selected

  mapfile -t hosts < <(
    nix --extra-experimental-features nix-command \
      --extra-experimental-features flakes \
      eval --impure --raw --expr \
      'let flake = builtins.getFlake (toString ./nix); in builtins.concatStringsSep "\n" (builtins.attrNames flake.nixosConfigurations)'
  )

  if [ "${#hosts[@]}" -eq 0 ]; then
    echo "No nixosConfigurations found in flake."
    exit 1
  fi

  echo
  echo "Available hosts:"
  for host in "${hosts[@]}"; do
    echo "  $index) $host"
    index=$((index + 1))
  done

  while true; do
    echo
    read -r -p "Select host number to install: " selected
    if [[ "$selected" =~ ^[0-9]+$ ]] && [ "$selected" -ge 1 ] && [ "$selected" -le "${#hosts[@]}" ]; then
      HOST_NAME="${hosts[$((selected - 1))]}"
      return
    fi
    echo "Invalid selection."
  done
}

require_cmd git
require_cmd nix
require_cmd nixos-install
require_cmd nixos-generate-config
require_cmd nixos-enter

if [ "$(id -u)" -eq 0 ]; then
  echo "Run this script as normal user (nixos), not root."
  exit 1
fi

echo "Installer workspace: $WORKDIR"
ensure_free_space "$(dirname "$WORKDIR")" 3

echo "Cloning dotfiles repo..."
git clone "$REPO_URL" "$WORKDIR"
cd "$WORKDIR"

pick_host

echo
USERNAME="$(
  nix --extra-experimental-features nix-command \
    --extra-experimental-features flakes \
    eval --impure --raw --expr 'let v = import ./nix/vars.nix; in v.userName'
)"

echo "Selected host: $HOST_NAME"
echo "Configured main user: $USERNAME"

echo
echo "Generating hardware scan (no filesystems), matching README step 2..."
sudo nixos-generate-config --no-filesystems
echo "Current /etc/nixos/hardware-configuration.nix:"
cat /etc/nixos/hardware-configuration.nix

echo
echo "Running disko (README step 3)..."
ensure_free_space "$(dirname "$WORKDIR")" 3
echo "WARNING: This will erase disks configured by host $HOST_NAME."
read -r -p "Type YES to continue: " confirm
if [ "$confirm" != "YES" ]; then
  echo "Cancelled."
  exit 1
fi

sudo nix --experimental-features "nix-command flakes" \
  run github:nix-community/disko/latest -- \
  --mode destroy,format,mount --flake "./nix#$HOST_NAME"

echo
echo "Running nixos-install (README step 4)..."
sudo nixos-install --flake "./nix#$HOST_NAME"

echo
echo "Set password for user '$USERNAME' in the newly installed system:"
sudo nixos-enter --root /mnt -c "passwd $USERNAME"

echo
echo "Installation completed for host '$HOST_NAME'."
read -r -p "Reboot now? (y/N): " reboot_ans
if [[ "$reboot_ans" =~ ^[Yy]$ ]]; then
  sudo reboot
else
  echo "Reboot skipped. Reboot manually when ready."
fi
