#!/bin/sh
sudo ln -s /home/"$(whoami)"/dotfiles/nix/modules /etc/nixos/
sudo nix-channel --add https://nixos.org/channels/nixos-unstable nixos
