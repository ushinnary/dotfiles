#!/bin/bash
ln -sd ../nvim ~/.config &&
\ ln -s ../.zshrc ~/ &&
\ flatpak --user override --filesystem=/home/$USER/.icons/:ro &&
\ flatpak --user override --filesystem=/usr/share/icons/:ro