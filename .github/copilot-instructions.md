# AI Coding Agent Instructions for Dotfiles Repository

## Project Overview
This is a NixOS dotfiles repository using flakes for reproducible system configurations. It manages configurations for multiple hosts (desktop PC and gaming handheld) with modular Nix modules.

## Architecture
- **Flake-based NixOS**: Uses `flake.nix` with inputs for nixpkgs, home-manager, nixvim
- **Modular Structure**: Configurations split into reusable modules in `nix/modules/`
- **Host Configurations**: Machine-specific configs in `nix/hosts/` (e.g., `ryzo` for AMD desktop, `zotac-zone` for NVIDIA handheld)
- **Custom Options**: All features under `ushinnary.*` namespace, defaulting to `false` - must be explicitly enabled

## Key Workflows
### NixOS Builds
```bash
# Build and switch to configuration for specific host
sudo nixos-rebuild switch --flake .#ryzo
sudo nixos-rebuild switch --flake .#zotac-zone
```

### Non-Nix Systems
- Run `./install.sh` to stow dotfiles
- Use distro-specific setup scripts in `scripts/` (e.g., `scripts/fedora/setup-fedora.sh`)

### Development
- Nixvim configuration in `nix/modules/nixvim/` with plugins in subdirectories
- Nixvim documentation for plugins: https://nix-community.github.io/nixvim/plugins
- Formatters/linters configured: `nixfmt`, `stylua`, `csharpier`, `nufmt`

## Conventions & Patterns
### Module Structure
- Options defined in `options.nix` under `ushinnary` namespace
- Modules import options and implement logic conditionally (e.g., `mkIf cfg.enable`)
- Example: Enable AMD GPU with `ushinnary.amd.enable = true;`

### Configuration Examples
```nix
# Host configuration (e.g., hosts/ryzo/configuration.nix)
ushinnary = {
  amd.enable = true;
  desktopEnvironment.gnome = true;
  software.enableDevPackages = true;  # Enables Nixvim
  gaming.enable = true;
};
```

### Dotfiles Linking
- Configs stored in root directories (e.g., `alacritty/`, `nvim/`)
- Linked via `home.file.".config/app".source = ../../../app/.config/app;`

### Plugin Organization
- Nixvim plugins in `nix/modules/nixvim/plugins/` with language-specific in `lang/`
- LSP configs in `lsp/` subdirectory

## Integration Points
- **Home Manager**: Manages user configs and dotfiles
- **GNOME Extensions**: Installed via `home.packages` in `home.nix`
- **Distro Scripts**: Handle package installation for Fedora/Ubuntu/Arch

## Key Files to Reference
- `flake.nix`: Input definitions and host outputs
- `nix/modules/options.nix`: All custom configuration options
- `nix/modules/nixvim/default.nix`: Editor setup and imports
- `scripts/fedora/setup-fedora.sh`: Example distro setup</content>
<parameter name="filePath">/home/ushinnary/dotfiles/.github/copilot-instructions.md