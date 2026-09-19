# dotfiles

My config for Rust/JS/TS development and NixOS systems.

## NixOS

This repo uses a flake in `nix/`.

### Hosts

- `ryzo`: Desktop (AMD GPU)
- `asus-vivobook-s14`: Laptop (AMD APU, OLED)

### Normal Rebuild Commands

From repository root:

```bash
sudo nixos-rebuild switch --flake ./nix#ryzo
sudo nixos-rebuild switch --flake ./nix#asus-vivobook-s14
```

Format and check the Nix files with:

```bash
./nix/fmt.sh
./nix/fmt.sh --check
```

## First Install (ASUS, Disk Reinstall)

The ASUS host now uses a declarative `disko` layout:

- disk device: `/dev/nvme0n1`
- partitioning: GPT
- encryption: LUKS on the main system partition
- filesystem: btrfs subvolumes (`/`, `/home`, `/nix`, `/.swapvol`)
- swap: 16G swapfile on `/.swapvol`

By default, this setup prompts for your LUKS passphrase at boot.

### One-shot Installer Script (recommended)

Instead of manually running steps 2, 3 and 4, you can use:

./scripts/clone-and-install.sh

The script will:

- clone the repo to /tmp
- display available hosts from nixosConfigurations and prompt selection
- run step 2 hardware scan command
- run disko for the selected host (step 3)
- run nixos-install for the selected host (step 4)
- prompt you to set the main user password before reboot

Default repository is https://github.com/ushinnary/dotfiles.git. You can override it:

./scripts/clone-and-install.sh https://github.com/ushinnary/dotfiles.git

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
sudo env INITIAL_INSTALL=1 nixos-install --impure --flake ./nix#asus-vivobook-s14
reboot
```

On first boot, enter the LUKS passphrase you set during formatting.

## Optional: Enable Secure Boot (Lanzaboote)

A reusable module exists at `nix/modules/hardware/secure-boot.nix` and is imported centrally.
The ASUS host enables it with `ushinnary.hardware.secureBoot = true`.

Fresh installs use `INITIAL_INSTALL=1` with `--impure` so systemd-boot remains active until
Secure Boot keys are created. The installer script already supplies these flags.

### 1. Create Secure Boot keys

On a fresh system, generate keys first so Lanzaboote can find `db.pem`:

```bash
sudo nix shell nixpkgs#sbctl -c sbctl create-keys
sudo ls /var/lib/sbctl/keys/db/db.pem
```

### 3. Rebuild with Lanzaboote

```bash
sudo nixos-rebuild switch --flake ./nix#asus-vivobook-s14
```

### 4. Enroll Secure Boot keys

```bash
sudo sbctl verify
```

Reboot to firmware settings and set Secure Boot to Setup Mode, then boot back into NixOS and run:

```bash
sudo sbctl enroll-keys --microsoft
sudo sbctl status
bootctl status
```

Then enable Secure Boot in firmware.

### 5. Optional TPM2 LUKS auto-unlock

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
