#!/bin/sh
sudo ln -s /home/ushinnary/dotfiles/nix/modules /etc/nixos/
sudo nix-channel --add https://nixos.org/channels/nixos-unstable nixos
