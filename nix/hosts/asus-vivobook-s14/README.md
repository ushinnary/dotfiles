# Asus Vivobook S14 NixOS Installation Guide

This guide will help you install NixOS on your Asus Vivobook S14 laptop with AMD Ryzen 5 7535HS APU, GNOME desktop environment, and OLED display optimizations.

## 📋 Hardware Specifications

- **CPU**: AMD Ryzen 5 7535HS APU (with microcode updates enabled)
- **GPU**: Integrated AMD Radeon Graphics
- **Display**: 60Hz OLED screen
- **Desktop Environment**: GNOME
- **Virtualization**: Disabled (not needed for this laptop)

## 🔧 Pre-Installation Requirements

1. USB flash drive (8GB minimum)
2. USB keyboard and mouse (for installation)
3. Internet connection (Wi-Fi or Ethernet)
4. Backup any existing data

## 📥 Step 1: Create NixOS Installation Media

Follow the same steps as in the main README.md for creating installation media.

## 🛠️ Step 2: Boot into NixOS Live Environment

1. Insert the USB drive and boot from it
2. Select "NixOS Live CD" from the boot menu
3. Wait for the system to load

## ⚙️ Step 3: Partitioning and Installation

### Partitioning (UEFI with GPT)

For a laptop installation, you'll typically have:

```bash
# Example partitioning (adjust sizes as needed)
sudo parted /dev/nvme0n1 -- mklabel gpt
sudo parted /dev/nvme0n1 -- mkpart ESP fat32 1MiB 512MiB
sudo parted /dev/nvme0n1 -- set 1 esp on
sudo parted /dev/nvme0n1 -- mkpart primary 512MiB 100%

# Format partitions
sudo mkfs.fat -F 32 -n boot /dev/nvme0n1p1
sudo mkfs.ext4 -L nixos /dev/nvme0n1p2
```

### Mount and Install

```bash
# Mount partitions
sudo mount /dev/disk/by-label/nixos /mnt
sudo mkdir -p /mnt/boot
sudo mount /dev/disk/by-label/boot /mnt/boot

# Generate hardware configuration
sudo nixos-generate-config --root /mnt

# Copy the generated hardware-configuration.nix to replace the placeholder
sudo cp /mnt/etc/nixos/hardware-configuration.nix /path/to/your/dotfiles/nix/hosts/asus-vivobook-s14/
```

## 📝 Step 4: Configure NixOS

1. Copy your dotfiles to `/mnt/etc/nixos/` or use git to clone them
2. Update the flake.nix to include the new host
3. Install NixOS:

```bash
sudo nixos-install --flake .#asus-vivobook-s14
```

## 🔄 Step 5: Post-Installation

1. Reboot into your new NixOS installation
2. Login with your user account
3. Run the post-install script if available

## 🎯 Usage

To rebuild your system after changes:

```bash
sudo nixos-rebuild switch --flake .#asus-vivobook-s14
```

## 📞 Troubleshooting

- If you encounter issues with AMD graphics, ensure `ushinnary.amd.enable = true` is set
- For OLED display optimizations, `screen.isOled = true` is already configured
- Virtualization is disabled by default for this laptop configuration

## 🔗 Additional Resources

- [NixOS Manual](https://nixos.org/manual/nixos/stable/)
- [AMD GPU Wiki](https://wiki.nixos.org/wiki/AMD_GPU)