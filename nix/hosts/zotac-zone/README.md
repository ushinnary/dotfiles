# Zotac Zone NixOS Installation Guide

This guide will help you install NixOS on your Zotac Zone gaming handheld with a minimal, performance-oriented setup similar to CachyOS.

## 📋 Hardware Specifications

- **CPU**: AMD Ryzen 7 8840U (Hawk Point)
- **GPU**: AMD Radeon 780M (RDNA3 integrated)
- **Display**: 7" OLED, 1920x1080, 120Hz
- **RAM**: 16GB LPDDR5X
- **Storage**: NVMe SSD + MicroSD card slot
- **Kernel**: Linux Zen (performance-oriented)

## 🔧 Pre-Installation Requirements

1. USB flash drive (8GB minimum)
2. USB-C hub (for keyboard/mouse during installation)
3. Internet connection (WiFi or Ethernet via hub)
4. Backup any existing data

## 📥 Step 1: Create NixOS Installation Media

```bash
# Download NixOS Minimal ISO
wget https://channels.nixos.org/nixos-unstable/latest-nixos-minimal-x86_64-linux.iso

# Create bootable USB
sudo dd if=latest-nixos-minimal-x86_64-linux.iso of=/dev/sdX bs=4M status=progress conv=fsync
```

## 🚀 Step 2: Boot Into NixOS Installer

1. Insert USB into Zotac Zone
2. Power on while holding **Volume Down** to enter BIOS
3. Disable Secure Boot
4. Set USB as first boot device
5. Save and exit BIOS

## 💾 Step 3: Partition Your Drive

```bash
# Connect to WiFi
sudo nmtui

# Partition the drive
sudo parted /dev/nvme0n1 -- mklabel gpt
sudo parted /dev/nvme0n1 -- mkpart primary 512MB -8GB   # Root
sudo parted /dev/nvme0n1 -- mkpart primary linux-swap -8GB 100%  # Swap
sudo parted /dev/nvme0n1 -- mkpart ESP fat32 1MB 512MB  # EFI

# Format partitions
sudo mkfs.ext4 -L nixos /dev/nvme0n1p1
sudo mkswap -L swap /dev/nvme0n1p2
sudo mkfs.fat -F 32 -n boot /dev/nvme0n1p3

# Mount partitions
sudo mount /dev/disk/by-label/nixos /mnt
sudo mkdir -p /mnt/boot
sudo mount /dev/disk/by-label/boot /mnt/boot
sudo swapon /dev/disk/by-label/swap
```

## 📝 Step 4: Generate Hardware Configuration

```bash
# Generate hardware config
sudo nixos-generate-config --root /mnt

# Copy the generated config
sudo cp /mnt/etc/nixos/hardware-configuration.nix /mnt/home/ushinnary/dotfiles/nix/hosts/zotac-zone/
```

## 📦 Step 5: Install NixOS

```bash
# Clone dotfiles
sudo git clone https://github.com/YOUR_USERNAME/dotfiles.git /mnt/home/ushinnary/dotfiles

# Install NixOS
cd /mnt/home/ushinnary/dotfiles/nix
sudo nixos-install --flake .#zotac-zone --no-root-passwd

# Set user password when prompted
```

## 🎮 Post-Installation Setup

### First Boot

1. Log in as ushinnary
2. Connect to WiFi using `nmtui`

### Install Decky Loader

```bash
# Install Decky Loader
curl -L https://github.com/SteamDeckHomebrew/decky-installer/releases/latest/download/install_release.sh | sh
```

### Install SimpleTDP Plugin

1. Open Steam → Power button → Decky Loader
2. Go to **Store** tab
3. Search for **SimpleTDP**
4. Install and configure TDP limits

### Configure Steam Game Mode

In Steam settings:
- Set refresh rate to **120Hz**
- Enable **Variable Refresh Rate**
- Enable **HDR** for OLED display

### MicroSD Card Setup

The system automatically detects and mounts microSD cards. Insert a microSD card and it will be available at `/run/media/ushinnary/` or through the file manager.

## ⚙️ Performance Configuration

### SimpleTDP Settings (via Decky Loader)

Recommended TDP profiles:
- **Performance Mode**: 25-28W
- **Balanced Mode**: 15-20W  
- **Power Saving**: 8-12W

### GameMode Integration

GameMode automatically activates when launching games through Steam, providing CPU/GPU performance optimizations.

### MangoHud

Press **Shift+F2** in games to toggle performance overlay showing FPS, temperatures, and usage.

## 🔄 Updating

```bash
cd ~/dotfiles/nix
nix flake update
sudo nixos-rebuild switch --flake .#zotac-zone
```

## 🐛 Troubleshooting

### Decky Loader Issues

```bash
# Restart Decky Loader
systemctl --user restart plugin_loader

# Reinstall if needed
curl -L https://github.com/SteamDeckHomebrew/decky-installer/releases/latest/download/install_release.sh | sh
```

### MicroSD Not Detected

```bash
# Check card detection
lsblk

# Remount manually
sudo mount /dev/mmcblk0p1 /mnt/microsd
```

### Performance Issues

- Ensure SimpleTDP is properly configured
- Check that GameMode is activating (run `gamemoded -t`)
- Verify Vulkan drivers: `vulkaninfo | head -20`

## 📁 File Locations

- **NixOS Config**: `~/dotfiles/nix/hosts/zotac-zone/`
- **Decky Plugins**: `~/homebrew/plugins/`
- **Steam Games**: `~/.steam/steam/steamapps/`
- **MicroSD**: `/run/media/ushinnary/` (auto-mounted)

## 🎯 Key Differences from CachyOS

- **Zen Kernel**: Performance-oriented like CachyOS but from NixOS repos
- **Minimal Services**: Only essential services, no TLP/power-profiles-daemon
- **SimpleTDP**: Decky plugin handles all power management
- **Immutable**: NixOS atomic updates and rollbacks
- **Declarative**: All configuration managed through Nix files

---

**Enjoy your minimal, high-performance Zotac Zone setup!** 🎮
