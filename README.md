# dotfiles

My config for Rust/JS/TS development and NixOS systems
WIP

## NixOS Configuration

This repository contains NixOS configurations using flakes for reproducible builds.

### Hosts

- **ryzo**: Desktop PC with AMD GPU, GNOME desktop, optimized for gaming
- **zotac-zone**: Handheld device using Jovian-NixOS for Steam Deck-like experience

### Jovian-NixOS Setup

The Zotac Zone configuration uses [Jovian-NixOS](https://github.com/Jovian-Experiments/Jovian-NixOS) for official Steam Deck support, providing:

- Steam with Gamescope for gaming
- Decky Loader for plugins
- Steam Deck UI and optimizations
- Proper power management for handheld devices

### Building

```bash
# Build for ryzo desktop
sudo nixos-rebuild switch --flake .#ryzo

# Build for zotac-zone handheld
sudo nixos-rebuild switch --flake .#zotac-zone
```

## Packages to install

### Fedora packages

`./scripts/setup-fedora.sh`

### Rust

`./setup-rust.sh`

Binstall
`https://github.com/cargo-bins/cargo-binstall?tab=readme-ov-file`

### Fonts

`https://github.com/ryanoasis/nerd-fonts/releases/`

### Cursors

`https://github.com/ful1e5/Bibata_Cursor/releases`
