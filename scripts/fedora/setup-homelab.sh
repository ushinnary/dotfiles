#!/bin/bash
sudo curl -fsSL https://pkgs.tailscale.com/stable/fedora/tailscale.repo -o /etc/yum.repos.d/tailscale.repo

sudo rpm-ostree install cockpit \
  cockpit-system \
  cockpit-ostree \
  cockpit-podman \
  cockpit-storaged \
  cockpit-networkmanager \
  cockpit-selinux \
  cockpit-sosreport \
  cockpit-files \
  tailscale \
  distrobox \
  udisks2-btrfs btrfs-progs udisks2 \
  samba samba-common nss-mdns avahi avahi-tools

sudo systemctl enable --now avahi-daemon.service
sudo systemctl enable --now smb nmb

sudo firewall-cmd --add-service=samba --permanent
sudo firewall-cmd --add-service=mdns --permanent
sudo firewall-cmd --reload
