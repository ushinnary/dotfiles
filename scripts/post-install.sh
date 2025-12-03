#!/bin/sh

# After installing, use distrobox-export to make needed tools available on host:
if command -v distrobox-export >/dev/null 2>&1; then
  distrobox-export --bin /usr/bin/nvim
  distrobox-export --bin /usr/bin/lazygit
  distrobox-export --app code
  distrobox-export --app antigravity
  sudo ln -s /usr/bin/distrobox-host-exec /usr/local/bin/podman
  sudo ln -s /usr/bin/distrobox-host-exec /usr/local/bin/podman-compose
fi
