#!/bin/sh

set -e

usage() {
  echo "Usage: $0 {rpmfusion|docker|flatpak-icons|nvidia}"
  exit 1
}

add_rpmfusion() {
  if ! rpm-ostree status | grep -q rpmfusion; then
    echo "Enabling RPM Fusion repositories..."
    sudo rpm-ostree install https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm
    sudo reboot
  else
    echo "RPM Fusion already enabled."
  fi
}

add_docker() {
  if ! rpm-ostree status | grep -q docker; then
    echo "Layering Docker..."
    curl -s -L https://download.docker.com/linux/fedora/docker-ce.repo | sudo tee /etc/yum.repos.d/docker-ce.repo
    sudo rpm-ostree install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin --reboot
    echo "Docker layered. Please reboot."
  else
    echo "Docker already layered."
    sudo systemctl enable --now docker
    systemctl --user enable --now podman.socket
    sudo groupadd docker
    sudo usermod -aG docker $USER

    local line='export DOCKER_HOST=unix:///run/user/1000/podman/podman.sock'

    if ! grep -Fxq "$line" ~/.bashrc; then
      echo "$line" >>~/.bashrc
      echo "Added DOCKER_HOST to ~/.bashrc"
    else
      echo "DOCKER_HOST already present in ~/.bashrc"
    fi
  fi
}

add_nvidia() {
  if ! rpm-ostree status | grep -q nvidia; then
    echo "Layering NVIDIA drivers..."
    curl -s -L https://nvidia.github.io/libnvidia-container/stable/rpm/nvidia-container-toolkit.repo | sudo tee /etc/yum.repos.d/nvidia-container-toolkit.repo
    export NVIDIA_CONTAINER_TOOLKIT_VERSION=1.17.8-1
    sudo rpm-ostree install akmod-nvidia xorg-x11-drv-nvidia \
      xorg-x11-drv-nvidia-cuda \
      xorg-x11-drv-nvidia-power \
      xorg-x11-drv-nvidia-cuda-libs \
      nvidia-vaapi-driver \
      libva-utils \
      vdpauinfo \
      nvidia-container-toolkit-${NVIDIA_CONTAINER_TOOLKIT_VERSION} \
      nvidia-container-toolkit-base-${NVIDIA_CONTAINER_TOOLKIT_VERSION} \
      libnvidia-container-tools-${NVIDIA_CONTAINER_TOOLKIT_VERSION} \
      libnvidia-container1-${NVIDIA_CONTAINER_TOOLKIT_VERSION}
    sudo rpm-ostree kargs --append=rd.driver.blacklist=nouveau,nova_core --append=modprobe.blacklist=nouveau,nova_core
    systemctl reboot
  else
    echo "NVIDIA drivers already layered."
  fi
}

flatpak_icons() {
  flatpak --user override --filesystem=/home/"$USER"/.icons/:ro
  flatpak --user override --filesystem=/usr/share/icons/:ro
  echo "Flatpak icon overrides applied."
}

if [ $# -lt 1 ]; then
  usage
fi

case "$1" in
rpmfusion)
  add_rpmfusion
  ;;
docker)
  add_docker
  ;;
nvidia)
  add_nvidia
  ;;
flatpak-icons)
  flatpak_icons
  ;;
*)
  usage
  ;;
esac
