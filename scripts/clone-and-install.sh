#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." >/dev/null 2>&1 && pwd)"
NIX_DIR="$REPO_ROOT/nix"
FLAKE_PATH="$NIX_DIR"
INSTALL_NIX_STORE="/tmp/nix-store"
INSTALL_NIX_STATE="/tmp/nix-state"
INSTALL_TMPDIR="/tmp/nix-tmp"
TMPDIR="${TMPDIR:-$INSTALL_TMPDIR}"
mkdir -p "$TMPDIR"
mkdir -p "$INSTALL_NIX_STORE"
mkdir -p "$INSTALL_NIX_STATE"
mkdir -p "$INSTALL_TMPDIR"
export TMPDIR
export XDG_CACHE_HOME="${XDG_CACHE_HOME:-$TMPDIR/xdg-cache}"
export NIX_STATE_DIR="$INSTALL_NIX_STATE"

require_cmd() {
  local cmd="$1"
  if ! command -v "$cmd" >/dev/null 2>&1; then
    echo "Missing required command: $cmd"
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

require_cmd nix
require_cmd nixos-install
require_cmd nixos-generate-config
require_cmd nixos-enter

if [ "$(id -u)" -eq 0 ]; then
  echo "Run this script as normal user (nixos), not root."
  exit 1
fi

if [ ! -d "$NIX_DIR" ] || [ ! -e "$NIX_DIR/flake.nix" ]; then
  echo "Unable to locate nix flake in $NIX_DIR. Run this script from the cloned dotfiles repository."
  exit 1
fi

cd "$REPO_ROOT"

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

echo "Running disko..."
echo "WARNING: This will erase disks configured by host $HOST_NAME."
read -r -p "Type YES to continue: " confirm
if [ "$confirm" != "YES" ]; then
  echo "Cancelled."
  exit 1
fi

sudo env "PATH=$PATH" "TMPDIR=$TMPDIR" "XDG_CACHE_HOME=$XDG_CACHE_HOME" "NIX_STATE_DIR=$NIX_STATE_DIR" nix --store "$INSTALL_NIX_STORE" --experimental-features "nix-command flakes" \
  run github:nix-community/disko/latest -- \
  --mode destroy,format,mount --flake "$FLAKE_PATH#$HOST_NAME"

echo
sudo mkdir -p /mnt/tmp
sudo mkswap -U clear --size 8G --file /mnt/swapfile
sudo swapon /mnt/swapfile

echo "Running nixos-install (README step 4)..."
sudo env "PATH=$PATH" "TMPDIR=/mnt/tmp" "XDG_CACHE_HOME=$XDG_CACHE_HOME" "NIX_STATE_DIR=$NIX_STATE_DIR" nixos-install --store "$INSTALL_NIX_STORE" --root /mnt --flake "$FLAKE_PATH#$HOST_NAME"

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
