# Ryzo NixOS Installation Guide

This guide will help you install NixOS on your Ryzo desktop PC with AMD hardware, GNOME desktop environment, and gaming optimizations.

## 📋 Hardware Specifications

- **CPU**: AMD Ryzen (with microcode updates enabled)
- **GPU**: AMD Radeon GPU (with Vulkan/OpenGL support)
- **Storage**: NVMe SSD + additional SSD storage
- **Display**: High refresh rate monitor (144Hz gaming, 90Hz normal use)
- **Desktop Environment**: GNOME with custom extensions

## 🔧 Pre-Installation Requirements

1. USB flash drive (8GB minimum)
2. USB keyboard and mouse (for installation)
3. Internet connection (Ethernet recommended)
4. Backup any existing data

## 📥 Step 1: Create NixOS Installation Media

### Download NixOS ISO

```bash
# Download the latest NixOS Minimal ISO (recommended for desktop PCs)
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

1. Insert USB into Ryzo
2. Power on and enter BIOS (usually Del, F2, or F10)
3. Disable Secure Boot (if enabled)
4. Set USB as first boot device
5. Save and exit BIOS

## 💾 Step 3: Partition Your Drive

Once booted into the NixOS installer:

```bash
# Connect to WiFi or Ethernet
sudo nmtui

# Identify your drives (usually nvme0n1 for primary, nvme1n1 for secondary)
lsblk

# Partition the primary drive (adjust sizes as needed)
sudo parted /dev/nvme0n1 -- mklabel gpt
sudo parted /dev/nvme0n1 -- mkpart primary 512MB -8GB   # Root partition
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

# If you have a secondary SSD, mount it (adjust UUID as needed)
sudo mkdir -p /mnt/home/ushinnary/SSD
sudo mount /dev/disk/by-uuid/YOUR-SSD-UUID /mnt/home/ushinnary/SSD
```

## 📝 Step 4: Generate Hardware Configuration

```bash
# Generate the hardware configuration
sudo nixos-generate-config --root /mnt

# View the generated config to copy UUIDs
cat /mnt/etc/nixos/hardware-configuration.nix
```

**Important**: Edit the `hardware-configuration.nix` in your dotfiles to use the correct UUIDs from the generated file.

## 📦 Step 5: Clone Your Dotfiles

```bash
# Install git
nix-env -iA nixos.git

# Clone dotfiles repository
sudo git clone https://github.com/YOUR_USERNAME/dotfiles.git /mnt/home/ushinnary/dotfiles

# Copy the generated hardware-configuration.nix
sudo cp /mnt/etc/nixos/hardware-configuration.nix /mnt/home/ushinnary/dotfiles/nix/hosts/ryzo/
```

## 🛠️ Step 6: Install NixOS

```bash
# Navigate to the dotfiles directory
cd /mnt/home/ushinnary/dotfiles/nix

# Install NixOS with the ryzo configuration
sudo nixos-install --flake .#ryzo --no-root-passwd

# Set the user password when prompted
# The system will reboot automatically
```

## 🎨 Post-Installation Configuration

### First Boot

1. Log in with your user account
2. GNOME will start automatically
3. Connect to WiFi using Settings → Wi-Fi

### Update the System

```bash
cd ~/dotfiles/nix

# Update flake inputs (nixpkgs, home-manager, etc.)
nix flake update

# Apply updates
sudo nixos-rebuild switch --flake .#ryzo
```

### GNOME Desktop Setup

The configuration includes several GNOME extensions and optimizations:

- **Blur My Shell**: Adds blur effects to GNOME
- **Just Perfection**: Removes window buttons and other UI elements
- **AppIndicator**: System tray support
- **Night Theme Switcher**: Automatic dark/light theme switching
- **Dash to Dock**: Enhanced dock functionality

#### GNOME Tweaks Applied

- **Experimental Features**: Fractional scaling, VRR, XWayland scaling
- **Keybindings**: Alt+F4 and Super+Q for closing windows
- **Mouse**: Natural (inverted) scrolling enabled

### Configure Display Settings

In GNOME Settings → Displays:

1. Set refresh rate to **90Hz** for normal use
2. Enable **Fractional Scaling** if needed (125%, 150%, 175%)
3. Configure multiple monitors if applicable

### Gaming Setup

The system is optimized for gaming with:

- **Steam**: Pre-installed with Proton support
- **Gamescope**: For optimal gaming performance
- **MangoHud**: Performance monitoring overlay
- **Gamemode**: CPU/GPU performance optimizations

#### Launch Games

```bash
# Launch Steam in gaming mode
steam

# Or use Gamescope directly for specific games
gamescope --steam -- your-game-command
```

#### Performance Monitoring

- Press **Shift+F2** in games to toggle MangoHud
- Monitor FPS, CPU/GPU temps, and usage

### Development Environment

The configuration includes a full development setup:

- **Nixvim**: Pre-configured Neovim with plugins
- **Development Tools**: Git, compilers, debuggers
- **Languages**: Support for multiple programming languages

### Storage Setup

Your system has two storage locations:

- **System Drive**: `/` (NixOS installation)
- **Secondary SSD**: `/home/ushinnary/SSD` (additional storage)

Use the secondary SSD for games, projects, or large files to keep the system drive optimized.

## 🔄 Updating Your System

```bash
cd ~/dotfiles/nix

# Update flake inputs
nix flake update

# Apply updates
sudo nixos-rebuild switch --flake .#ryzo
```

## 🐛 Troubleshooting

### Display Issues

If you experience display problems:

```bash
# Check AMD GPU status
lspci | grep VGA
dmesg | grep amdgpu

# Restart display manager
sudo systemctl restart gdm
```

### GNOME Extensions Not Working

```bash
# Restart GNOME Shell
Alt+F2, then type 'r' and press Enter

# Or from terminal
killall -3 gnome-shell
```

### Gaming Performance Issues

```bash
# Check Vulkan support
vulkaninfo | head -20

# Test GPU acceleration
glxinfo | grep renderer

# Check gamemode
gamemoded -t
```

### Network Issues

```bash
# Restart NetworkManager
sudo systemctl restart NetworkManager

# Check network status
nmcli device status
```

## 🎯 Performance Optimization

### For Daily Use

- **Refresh Rate**: 90Hz provides excellent balance of performance and efficiency
- **GNOME Extensions**: Keep only essential extensions enabled
- **Background Services**: Disable unnecessary services

### For Gaming

- **Refresh Rate**: Automatically switches to 144Hz in games
- **GameMode**: Automatically activates for better performance
- **MangoHud**: Monitor performance metrics
- **Proton**: Use latest Proton-GE for Windows games

### Power Management

The system uses AMD's power management features:

- **CPU**: Ryzen power profiles for efficiency
- **GPU**: AMDGPU power management
- **Display**: VRR support for smooth gaming

## 📁 File Locations

- **NixOS Config**: `~/dotfiles/nix/hosts/ryzo/`
- **GNOME Config**: Managed via dconf (gsettings)
- **Steam Games**: `~/.steam/steam/steamapps/`
- **Development Projects**: `~/SSD/projects/` (recommended)
- **Downloads/Games**: `~/SSD/` (secondary SSD)

## 🔗 Useful Resources

- [NixOS Manual](https://nixos.org/manual/nixos/stable/)
- [GNOME Documentation](https://help.gnome.org/)
- [AMD GPU Wiki](https://wiki.archlinux.org/title/AMDGPU)
- [Steam for Linux](https://wiki.archlinux.org/title/Steam)
- [ProtonDB](https://www.protondb.com/)

## 🆘 Getting Help

If you encounter issues:

1. Check the [NixOS Discourse](https://discourse.nixos.org/)
2. Search [GNOME GitLab Issues](https://gitlab.gnome.org/)
3. Ask on [r/NixOS](https://www.reddit.com/r/NixOS/) or [r/gnome](https://www.reddit.com/r/gnome/)

---

**Enjoy your optimized AMD desktop with GNOME and gaming capabilities!** 🎮🖥️
