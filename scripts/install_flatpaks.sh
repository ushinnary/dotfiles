
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
)

for app in "${flatpaks[@]}"; do
    echo "Installing $app..."
    flatpak install -y flathub "$app"
done

echo "All Flatpak applications have been installed."