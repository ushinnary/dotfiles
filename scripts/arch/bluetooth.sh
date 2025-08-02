#!/bin/bash

# Install bluetooth controls
sudo pacman -S blueberry

# Turn on bluetooth by default
sudo systemctl enable --now bluetooth.service
