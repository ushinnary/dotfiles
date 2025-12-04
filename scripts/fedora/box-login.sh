#!/bin/bash
# /usr/local/bin/box-login.sh

CONTAINER_NAME="${USER}-box"
IMAGE="fedora:rawhide"

# --- Storage Path Definitions ---
INTERNAL_ROOT="/var/lib/user_container_data/${USER}"
INTERNAL_PODMAN="${INTERNAL_ROOT}/podman_storage"
INTERNAL_HOME="${INTERNAL_ROOT}/container_home"

# --- Socket Logic (The Fix) ---
# 1. Podman Socket
USER_UID=$(id -u)
HOST_PODMAN_SOCK="/run/user/${USER_UID}/podman/podman.sock"
INT_PODMAN_SOCK="/run/podman/podman.sock"

# 2. SSH Agent Socket (Static Link Strategy)
# We create a stable path in the user's home
STATIC_SSH_SOCK="$HOME/.ssh/agent-forward-sock"
INT_SSH_SOCK="/run/host-ssh-agent"

# --- Pre-Flight Checks ---
if [ ! -d "$INTERNAL_ROOT" ]; then
  echo "CRITICAL ERROR: Internal storage root is missing."
  exit 1
fi

# Update the Static SSH Symlink
# This runs EVERY time you login to update the link to the new /tmp path
if [ -n "$SSH_AUTH_SOCK" ]; then
  # Create/Overwrite the symlink pointing to the current temporary socket
  ln -sf "$SSH_AUTH_SOCK" "$STATIC_SSH_SOCK"
else
  echo "Warning: No SSH Agent forwarding detected (Did you use ssh -A ?)"
  # Create a dummy socket so the mount doesn't fail
  touch "$STATIC_SSH_SOCK"
fi

# --- 1. Setup Podman Engine Storage ---
if [ ! -L ~/.local/share/containers ]; then
  mkdir -p ~/.local/share
  mkdir -p "$INTERNAL_PODMAN"
  rm -rf ~/.local/share/containers
  ln -s "$INTERNAL_PODMAN" ~/.local/share/containers
fi

# Ensure Podman socket is active
systemctl --user enable --now podman.socket || true

# --- 2. Setup Container Home ---
mkdir -p "$INTERNAL_HOME"

# --- 3. Create Container (If missing) ---
if ! distrobox list --no-color | grep -q "$CONTAINER_NAME"; then
  echo "First time setup: Creating Isolated Environment..."

  # We mount the STATIC path ($STATIC_SSH_SOCK), not the dynamic variable
  distrobox create \
    --image "$IMAGE" \
    --name "$CONTAINER_NAME" \
    --home "$INTERNAL_HOME" \
    --additional-flags "--volume $HOST_PODMAN_SOCK:$INT_PODMAN_SOCK --env CONTAINER_HOST=unix://$INT_PODMAN_SOCK --volume $STATIC_SSH_SOCK:$INT_SSH_SOCK --env SSH_AUTH_SOCK=$INT_SSH_SOCK" \
    --yes \
    --pull

  echo "Installing tools..."
  # Install Podman inside
  distrobox enter "$CONTAINER_NAME" -- \
    sudo dnf install -y podman podman-compose git @development-tools openssl-devel cmake fontconfig-devel perl fzf
fi

# Final check for socket
if ! systemctl --user is-active --quiet podman.socket; then
  systemctl --user start podman.socket
fi

# --- 4. Enter the container ---
exec distrobox enter "$CONTAINER_NAME" -- sh -c "cd ~ && exec \$SHELL"
