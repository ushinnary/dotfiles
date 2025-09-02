#!/bin/bash
sudo pacman -S --needed git base-devel otf-font-awesome ttf-nerd-fonts-symbols

# Omarchy

if ! command -v ufw &>/dev/null; then
  yay -S --noconfirm --needed ufw ufw-docker

  # Allow nothing in, everything out
  sudo ufw default deny incoming
  sudo ufw default allow outgoing

  # Allow ports for LocalSend
  sudo ufw allow 53317/udp
  sudo ufw allow 53317/tcp

  # Allow SSH in
  sudo ufw allow 22/tcp

  # Allow Docker containers to use DNS on host
  sudo ufw allow in on docker0 to any port 53

  # Turn on the firewall
  sudo ufw enable

  # Turn on Docker protections
  sudo ufw-docker install
  sudo ufw reload
fi

# docker

yay -S --noconfirm --needed docker docker-compose docker-buildx

# Limit log size to avoid running out of disk
sudo mkdir -p /etc/docker
echo '{"log-driver":"json-file","log-opts":{"max-size":"10m","max-file":"5"}}' | sudo tee /etc/docker/daemon.json

# Start Docker automatically
sudo systemctl enable docker

# Give this user privileged Docker access
sudo usermod -aG docker ${USER}

# Prevent Docker from preventing boot for network-online.target
sudo mkdir -p /etc/systemd/system/docker.service.d
sudo tee /etc/systemd/system/docker.service.d/no-block-boot.conf <<'EOF'
[Unit]
DefaultDependencies=no
EOF

sudo systemctl daemon-reload
