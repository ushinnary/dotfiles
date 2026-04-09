# VM NixOS Installation Guide

This guide helps you install the VM host profile with Niri desktop in VirtualBox.

## VM settings (VirtualBox)

1. Create a VM with type Linux (64-bit)
2. Use at least 4 GB RAM (8 GB recommended)
3. Create a virtual disk >= 40 GB
4. Enable EFI in VM settings (System -> Enable EFI)

## Install

1. Boot NixOS installer ISO in the VM
2. Clone your dotfiles into the installer environment
3. Install with the VM flake target:

```bash
sudo nixos-install --flake .#vm
```

## Notes

- This profile is configured for disko on /dev/sda
- Swap is set to 2G
- Desktop is set to Niri
- Containers and gaming options are disabled
