#!/bin/bash
distrobox create --image archlinux:latest --name archlinux --additional-packages "systemd" --init --nvidia
# ln -s /usr/bin/distrobox-host-exec /usr/local/bin/podman
# ln -s /usr/bin/distrobox-host-exec /usr/local/bin/docker
