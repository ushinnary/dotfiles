#!/bin/bash

sudo pacman -S \
  brightnessctl playerctl wireplumber \
  wl-clip-persist \
  nautilus sushi ffmpegthumbnailer

# Add screen recorder based on GPU
if lspci | grep -qi 'nvidia'; then
  sudo pacman -S wf-recorder
else
  sudo pacman -S wl-screenrec
fi
