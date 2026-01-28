# Zotac Zone NixOS Installation Guide

This guide will help you install NixOS on your Zotac Zone gaming handheld with a Steam Deck-like experience.

## 📋 Hardware Specifications

- **CPU**: AMD Ryzen 7 8840U (Hawk Point)
- **GPU**: AMD Radeon 780M (RDNA3 integrated)
- **Display**: 7" OLED, 1920x1080, 120Hz
- **RAM**: 16GB LPDDR5X

## 🔧 Pre-Installation Requirements

1. USB flash drive (8GB minimum)
2. USB-C hub (for keyboard/mouse during installation)
3. Internet connection (WiFi or Ethernet via hub)
4. Backup any existing data

## 📥 Step 1: Create NixOS Installation Media

### Download NixOS ISO

```bash
# Download the latest NixOS Minimal ISO (recommended for handhelds)
wget https://channels.nixos.org/nixos-unstable/latest-nixos-minimal-x86_64-linux.iso
```

### Create Bootable USB

```bash
# Find your USB device (be careful to identify the correct one!)
lsblk

# Write the ISO to USB (replace /dev/sdX with your USB device)
sudo dd if=latest-nixos-minimal-x86_64-linux.iso of=/dev/sdX bs=4M status=progress conv=fsync
```

## 🚀 Step 2: Boot Into NixOS Installer

1. Insert USB into Zotac Zone
2. Power on while holding **Volume Down** to enter BIOS
3. Disable Secure Boot (if enabled)
4. Set USB as first boot device
5. Save and exit BIOS

## 💾 Step 3: Partition Your Drive

Once booted into the NixOS installer:

```bash
# Connect to WiFi
sudo nmtui

# Identify your drive (usually nvme0n1)
lsblk

# Partition the drive
sudo parted /dev/nvme0n1 -- mklabel gpt
sudo parted /dev/nvme0n1 -- mkpart primary 512MB -8GB   # Root partition
sudo parted /dev/nvme0n1 -- mkpart primary linux-swap -8GB 100%  # Swap
sudo parted /dev/nvme0n1 -- mkpart ESP fat32 1MB 512MB  # EFI
sudo parted /dev/nvme0n1 -- set 3 esp on

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
# Generate the hardware configuration
sudo nixos-generate-config --root /mnt

# View the generated config to copy UUIDs
cat /mnt/etc/nixos/hardware-configuration.nix
```

## 📦 Step 5: Clone Your Dotfiles

```bash
# Install git
nix-env -iA nixos.git

# Clone dotfiles repository
sudo git clone https://github.com/ushinnary/dotfiles.git /mnt/home/ushinnary/dotfiles

# Copy the generated hardware-configuration.nix
sudo cp /mnt/etc/nixos/hardware-configuration.nix /mnt/home/ushinnary/dotfiles/nix/hosts/zotac-zone/
```

**Important**: Edit the `hardware-configuration.nix` in your dotfiles to use the correct UUIDs from the generated file.

## 🛠️ Step 6: Install NixOS

```bash
# Navigate to the dotfiles directory
cd /mnt/home/ushinnary/dotfiles/nix

# Install NixOS with the zotac-zone configuration
sudo nixos-install --flake .#zotac-zone --no-root-passwd

# Set the user password when prompted
# The system will reboot automatically
```

## 🎮 Post-Installation Configuration

### First Boot

1. Log in with your user account
2. Connect to WiFi using `nmtui` or your desktop environment

### Update the System

```bash
cd ~/dotfiles/nix
sudo nixos-rebuild switch --flake .#zotac-zone
```

### Install Decky Loader

Decky Loader provides plugins for Steam's Game Mode (like PowerTools, vibrantDeck, etc.):

```bash
# Run the official Decky Loader installer
curl -L https://github.com/SteamDeckHomebrew/decky-installer/releases/latest/download/install_release.sh | sh

# Or for the prerelease version with latest features:
curl -L https://github.com/SteamDeckHomebrew/decky-installer/releases/latest/download/install_prerelease.sh | sh
```

After installation, access Decky by pressing the **Quick Access** button (...) in Steam Game Mode.

#### Recommended Decky Plugins

- **PowerTools** - CPU/GPU power management
- **vibrantDeck** - Screen saturation control (great for OLED)
- **ProtonDB Badges** - See game compatibility ratings
- **SteamGridDB** - Custom game artwork
- **AutoFlatpaks** - Manage Flatpak apps in Game Mode
- **Battery Tracker** - Detailed battery stats

### Configure Steam Game Mode

For the best handheld experience, set Steam to launch in Game Mode:

```bash
# Edit your session to auto-start Steam Big Picture
# This is optional - you can also start it manually

# To manually start Gamescope session:
gamescope --steam -f -r 120 -- steam -gamepadui
```

### Set Optimal Display Settings

In Steam Game Mode Settings:
1. Go to **Display** → Set refresh rate to **120Hz**
2. Enable **Variable Refresh Rate**
3. For OLED: Enable **HDR** if supported by games
4. Set **Resolution** to **1920x1080** (native)

### Configure MangoHud

The configuration includes MangoHud for performance monitoring. Toggle it with **Shift+F2**.

Default display includes:
- FPS and frametime
- CPU/GPU temperatures
- Battery level and remaining time
- RAM/VRAM usage

### Power Management Tips

The configuration includes TLP for power management:

- **On Battery**: Conservative power saving, CPU boost disabled
- **On AC**: Full performance mode

To check power status:
```bash
sudo tlp-stat -s
```

## 🔄 Updating Your System

```bash
cd ~/dotfiles/nix

# Update flake inputs (nixpkgs, home-manager, etc.)
nix flake update

# Apply updates
sudo nixos-rebuild switch --flake .#zotac-zone
```

## 🐛 Troubleshooting

### Display Issues

If you experience screen flickering or issues:

```bash
# Check if amdgpu is loaded correctly
lsmod | grep amdgpu

# Check for GPU errors
dmesg | grep amdgpu
```

### Controller Not Detected

```bash
# Check if the controller is recognized
cat /proc/bus/input/devices

# Verify udev rules are applied
sudo udevadm control --reload-rules
sudo udevadm trigger
```

### Audio Problems

```bash
# Restart PipeWire
systemctl --user restart pipewire pipewire-pulse wireplumber

# Check audio devices
wpctl status
```

### WiFi Issues

```bash
# Restart NetworkManager
sudo systemctl restart NetworkManager

# Check WiFi status
nmcli device wifi list
```

### Decky Loader Not Working

```bash
# Reinstall Decky Loader
curl -L https://github.com/SteamDeckHomebrew/decky-installer/releases/latest/download/install_release.sh | sh

# Check the service status
systemctl --user status plugin_loader
```

## 📊 Performance Optimization

### For Maximum Performance

- Use **Game Mode** in TLP (when plugged in)
- Enable **MangoHud** to monitor FPS
- Use **GameScope** for optimal frame pacing
- Set frame limit to **120** or **60** FPS in games

### For Maximum Battery Life

- Set refresh rate to **60Hz** in Steam settings
- Enable **TDP limit** via PowerTools (Decky plugin)
- Lower screen brightness
- Use **WiFi Power Saving** mode

## 🎯 Recommended Settings Per Game

| Game Type | Refresh Rate | TDP | Notes |
|-----------|-------------|-----|-------|
| Indie/2D | 60-120Hz | 8-12W | Full battery life |
| AAA (older) | 60Hz | 15-20W | Stable performance |
| AAA (new) | 40-60Hz | 25-28W | Lower settings |
| Emulation | 60Hz | 8-15W | Depends on system |

## 📁 File Locations

- **NixOS Config**: `~/dotfiles/nix/hosts/zotac-zone/`
- **Decky Plugins**: `~/homebrew/plugins/`
- **Steam Games**: `~/.steam/steam/steamapps/`
- **Proton Prefixes**: `~/.steam/steam/steamapps/compatdata/`

## 🔗 Useful Resources

- [NixOS Manual](https://nixos.org/manual/nixos/stable/)
- [NixOS Hardware](https://github.com/NixOS/nixos-hardware)
- [Decky Loader](https://decky.xyz/)
- [ProtonDB](https://www.protondb.com/)
- [r/ZotacGaming](https://www.reddit.com/r/ZotacGaming/)
- [r/SteamDeck](https://www.reddit.com/r/SteamDeck/) (Many tips apply)

## 🆘 Getting Help

If you encounter issues:

1. Check the [NixOS Discourse](https://discourse.nixos.org/)
2. Search the [NixOS GitHub Issues](https://github.com/NixOS/nixpkgs/issues)
3. Ask on the [NixOS Matrix/Discord](https://nixos.org/community/)

---

**Enjoy your Steam Deck-like experience on Zotac Zone!** 🎮
