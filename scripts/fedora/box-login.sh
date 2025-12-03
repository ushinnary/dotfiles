#!/bin/bash
# /usr/local/bin/box-login.sh

CONTAINER_NAME="${USER}-box"
IMAGE="fedora:rawhide"

# --- Storage Path Definitions ---
# The root of the user's internal storage
INTERNAL_ROOT="/var/lib/user_container_data/${USER}"
# Where Podman stores images (Engine data)
INTERNAL_PODMAN="${INTERNAL_ROOT}/podman_storage"
# Where the User's Home will be INSIDE the container (User data)
INTERNAL_HOME="${INTERNAL_ROOT}/container_home"

# --- Safety Check ---
if [ ! -d "$INTERNAL_ROOT" ]; then
  echo "CRITICAL ERROR: Internal storage root is missing."
  exit 1
fi

# --- 1. Setup Podman Engine Storage (Host Side) ---
# We still need this link on the host so Podman runs fast
if [ ! -L ~/.local/share/containers ]; then
  echo "Configuring Podman engine storage on NVMe..."
  mkdir -p ~/.local/share
  mkdir -p "$INTERNAL_PODMAN"
  rm -rf ~/.local/share/containers
  ln -s "$INTERNAL_PODMAN" ~/.local/share/containers
fi

# Ensure socket is ready
systemctl --user enable --now podman.socket || true

# --- 2. Setup Container Home (Isolated) ---
# Create the directory that will act as Home inside the box
if [ ! -d "$INTERNAL_HOME" ]; then
  echo "Creating isolated NVMe home directory..."
  mkdir -p "$INTERNAL_HOME"
fi

# --- 3. Create/Enter Container ---
if ! distrobox list --no-color | grep -q "$CONTAINER_NAME"; then
  echo "First time setup: Creating Isolated Environment..."

  # We use the --home flag to strict isolate the user
  distrobox create \
    --image "$IMAGE" \
    --name "$CONTAINER_NAME" \
    --home "$INTERNAL_HOME" \
    --yes \
    --pull

  # (Optional) Set specific hostname inside container
  # distrobox enter "$CONTAINER_NAME" -- hostnamectl set-hostname "${USER}-dev"
fi

# Final check for socket
if ! systemctl --user is-active --quiet podman.socket; then
  systemctl --user start podman.socket
fi

# Enter the container
exec distrobox enter "$CONTAINER_NAME" -- sh -c "cd ~ && exec \$SHELL"
