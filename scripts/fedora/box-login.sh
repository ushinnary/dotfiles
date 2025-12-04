#!/bin/bash
# /usr/local/bin/box-login.sh

CONTAINER_NAME="${USER}-box"
IMAGE="fedora:rawhide"

# --- Storage Path Definitions ---
INTERNAL_ROOT="/var/lib/user_container_data/${USER}"
INTERNAL_PODMAN="${INTERNAL_ROOT}/podman_storage"
INTERNAL_HOME="${INTERNAL_ROOT}/container_home"

# --- Dynamic Socket Paths ---
# Get the User's UID to find the correct socket path on the host
USER_UID=$(id -u)
# The path to the socket ON THE HOST
HOST_SOCKET="/run/user/${USER_UID}/podman/podman.sock"
# The path where we will mount it INSIDE THE CONTAINER
INT_SOCKET="/run/podman/podman.sock"

# --- Safety Checks ---
if [ ! -d "$INTERNAL_ROOT" ]; then
  echo "CRITICAL ERROR: Internal storage root is missing."
  exit 1
fi

# --- 1. Setup Podman Engine Storage (Host Side) ---
if [ ! -L ~/.local/share/containers ]; then
  mkdir -p ~/.local/share
  mkdir -p "$INTERNAL_PODMAN"
  rm -rf ~/.local/share/containers
  ln -s "$INTERNAL_PODMAN" ~/.local/share/containers
fi

# Ensure host socket is active
systemctl --user enable --now podman.socket || true

# --- 2. Setup Container Home ---
if [ ! -d "$INTERNAL_HOME" ]; then
  mkdir -p "$INTERNAL_HOME"
fi

# --- 3. Create Container (The Fix) ---
if ! distrobox list --no-color | grep -q "$CONTAINER_NAME"; then
  echo "First time setup: Creating Isolated Environment..."

  # 1. Mount the Host Socket to /run/podman/podman.sock inside
  # 2. Set CONTAINER_HOST to point to it
  # 3. Mount SSH Agent Socket

  distrobox create \
    --image "$IMAGE" \
    --name "$CONTAINER_NAME" \
    --home "$INTERNAL_HOME" \
    --additional-flags "--volume $HOST_SOCKET:$INT_SOCKET --env CONTAINER_HOST=unix://$INT_SOCKET --volume $SSH_AUTH_SOCK:$SSH_AUTH_SOCK --env SSH_AUTH_SOCK=$SSH_AUTH_SOCK" \
    --yes \
    --pull

  echo "Installing development tools inside the container..."
  # We install podman INSIDE the container.
  # Because of the CONTAINER_HOST env var, it will talk to the host automatically.
  distrobox enter "$CONTAINER_NAME" -- \
    sudo dnf install -y podman podman-compose git
fi

# Final check for socket
if ! systemctl --user is-active --quiet podman.socket; then
  systemctl --user start podman.socket
fi

# --- 4. Enter the container ---
exec distrobox enter "$CONTAINER_NAME" -- sh -c "cd ~ && exec \$SHELL"
