# dotfiles

My config for Rust/JS/TS development and NixOS systems.

## NixOS

This repo uses a flake in `nix/`.

### Hosts

- `ryzo`: Desktop (AMD GPU)
- `zotac-zone`: Handheld (Jovian-NixOS)
- `asus-vivobook-s14`: Laptop (AMD APU, OLED)

### Normal Rebuild Commands

From repository root:

```bash
sudo nixos-rebuild switch --flake ./nix#ryzo
sudo nixos-rebuild switch --flake ./nix#zotac-zone
sudo nixos-rebuild switch --flake ./nix#asus-vivobook-s14
```

## First Install (ASUS, Disk Reinstall)

The ASUS host now uses a declarative `disko` layout:

- disk device: `/dev/nvme0n1`
- partitioning: GPT
- encryption: LUKS on the main system partition
- filesystem: btrfs subvolumes (`/`, `/home`, `/nix`, `/.swapvol`)
- swap: 16G swapfile on `/.swapvol`

By default, this setup prompts for your LUKS passphrase at boot.

### 1. Boot the NixOS ISO

Use the official NixOS installer ISO and boot in UEFI mode.

### 2. Prepare network and clone this repo

```bash
# set temporary password if you want SSH into the installer
passwd

# optional: connect wifi from TTY if needed
nmtui

git clone https://github.com/ushinnary/dotfiles.git
cd dotfiles

sudo nixos-generate-config --no-filesystems && cat /etc/nixos/hardware-configuration.nix
```

### 3. Partition + format + mount using disko

WARNING: This erases `/dev/nvme0n1`.

```bash
sudo nix --experimental-features "nix-command flakes" run github:nix-community/disko/latest -- --mode destroy,format,mount --flake ./nix#asus-vivobook-s14
```

### 4. Install NixOS from the flake

```bash
sudo nixos-install --flake ./nix#asus-vivobook-s14
reboot
```

On first boot, enter the LUKS passphrase you set during formatting.

## Optional: Enable Secure Boot (Lanzaboote)

A reusable module exists at `nix/modules/secure-boot.nix`.

It is intentionally not enabled by default on ASUS to keep first install simple and passphrase-based.

### 1. Enable module import on ASUS host

In `nix/hosts/asus-vivobook-s14/configuration.nix`, uncomment:

```nix
# ../../modules/secure-boot.nix
```

to:

```nix
../../modules/secure-boot.nix
```

### 2. Rebuild

```bash
sudo nixos-rebuild switch --flake ./nix#asus-vivobook-s14
```

### 3. Create and enroll Secure Boot keys

```bash
sudo sbctl create-keys
sudo sbctl verify
```

Reboot to firmware settings and set Secure Boot to Setup Mode, then boot back into NixOS and run:

```bash
sudo sbctl enroll-keys --microsoft
sudo sbctl status
bootctl status
```

Then enable Secure Boot in firmware.

### 4. Optional TPM2 LUKS auto-unlock

If you later want TPM2 auto-unlock, enroll TPM2 for the LUKS device (example command):

```bash
sudo systemd-cryptenroll --tpm2-device=auto --wipe-slot=tpm2 /dev/nvme0n1p2
```

This is optional. Keeping TPM2 enrollment disabled means you will continue to type your LUKS passphrase on each boot.

## References

- https://github.com/nix-community/disko
- https://nix-community.github.io/lanzaboote/
- https://wiki.nixos.org/wiki/Full_Disk_Encryption
- https://wiki.nixos.org/wiki/Secure_Boot

## Other Setup Notes

### Fedora packages

`./scripts/setup-fedora.sh`

### Rust

`./setup-rust.sh`

`cargo-binstall`: https://github.com/cargo-bins/cargo-binstall

### Fonts

https://github.com/ryanoasis/nerd-fonts/releases/

### Cursors

https://github.com/ful1e5/Bibata_Cursor/releases
