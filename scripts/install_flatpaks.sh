#!/bin/bash

# List your Flatpak application IDs here, one per line
flatpaks=(
  com.discordapp.Discord
  com.github.wwmm.easyeffects
  com.microsoft.Edge
  com.valvesoftware.Steam
  io.bassi.Amberol
  io.podman_desktop.PodmanDesktop
  md.obsidian.Obsidian
  net.nokyan.Resources
  org.gustavoperedo.FontDownloader
  org.gimp.GIMP
  org.telegram.desktop
  com.heroicgameslauncher.hgl
)

for app in "${flatpaks[@]}"; do
  echo "Installing $app..."
  flatpak install -y flathub "$app"
done

# Apply params
flatpak -u override --filesystem=/usr/share/icons/:ro
flatpak -u override --filesystem=/home/$USER/.icons/:ro
flatpak -u override --filesystem=xdg-config/gtk-3.0:ro
flatpak -u override --env=XCURSOR_PATH=~/.icons

echo "All Flatpak applications have been installed."
