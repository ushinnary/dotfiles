# AI Coding Agent Instructions for Dotfiles Repository

## Project Overview
Flake-based NixOS dotfiles managing three hosts with modular, opt-in feature modules. All custom options live under the \`ushinnary.*\` namespace and default to \`false\`/disabled.

## Hosts
| Hostname | Directory | Notes |
|---|---|---|
| \`ryzo\` | \`nix/hosts/ryzo/\` | AMD desktop, GNOME, dev workstation |
| \`zotac-zone\` | \`nix/hosts/zotac-zone/\` | Handheld, Jovian-NixOS, Steam auto-start |
| \`asus-vivobook-s14\` | \`nix/hosts/asus-vivobook-s14/\` | Laptop, Niri WM, OLED, battery |

## Key Flake Inputs
- \`nixpkgs\` → \`nixos-unstable\`; \`home-manager\`, \`nixvim\`, \`nixos-hardware\`
- \`jovian-nixos\` — SteamOS-like experience for zotac-zone
- \`quickshell\` (git, outfoxxed.me) — QML-based status bar for Niri
- \`system76-scheduler-niri\` — CPU scheduler tuned for Niri WM

## Build Workflow
\`\`\`bash
# flake.nix lives in nix/ — run commands from there
cd ~/dotfiles/nix
sudo nixos-rebuild switch --flake .#ryzo
sudo nixos-rebuild switch --flake .#asus-vivobook-s14
sudo nixos-rebuild switch --flake .#zotac-zone
\`\`\`

## Custom Options (\`nix/modules/options.nix\`)
All options use \`mkEnableOption\`/\`mkOption\` and are consumed via \`mkIf\`. Correct namespace:
\`\`\`nix
ushinnary = {
  gpu.amd.enable = true;                          # not ushinnary.amd.enable
  gpu.nvidia = { enable = true; openDriver = true; powerLimit = 150; };
  hardware.amdCpu = true;
  hardware.hasBattery = true;                     # enables BatteryWidget in bar
  desktop.gnome = true;                           # or .niri / .cosmic
  display = { refreshRate = 90; gamingRefreshRate = 144; oled = true; };
  dev.enable = true;                              # enables Nixvim + dev packages
  gaming.enable = true;
  power = { enable = true; profile = \"balanced\"; }; # balanced|performance|powersave
  security.howdy.enable = true;
  apps.davinciResolve = true;
  containers.enable = true;                       # Podman, defaults to true
};
\`\`\`

## Dotfiles Linking — Two Patterns
1. **Static copy** (rebuild needed on edit): \`xdg.configFile.\"app\".source = ../../../app/.config/app;\`
2. **Live symlink** (edits apply immediately, preferred for Quickshell/Niri):
\`\`\`nix
let mkDotfileSymlink = relativePath:
  config.lib.file.mkOutOfStoreSymlink
    \"\${config.home.homeDirectory}/dotfiles/\${relativePath}\";
in xdg.configFile.\"niri/outputs.kdl\".source =
  mkDotfileSymlink \"niri/.config/niri/hosts/asus-vivobook-s14/outputs.kdl\";
\`\`\`
Prefer \`mkDotfileSymlink\` for frequently-edited configs (bar widgets, compositor rules).

## Desktop Environments
- **GNOME** (\`desktop.gnome\`): Extensions in \`home.nix\`; dconf managed by Home Manager; login via GDM
- **Niri** (\`desktop.niri\`): Modules in \`nix/modules/DE/niri/\` (\`compositor.nix\`, \`bar.nix\`, \`terminal.nix\`); login via \`greetd\` + \`tuigreet\`
- **COSMIC** (\`desktop.cosmic\`): \`nix/modules/DE/cosmic.nix\`

## Quickshell Bar (Niri only)
- Package from \`inputs.quickshell.packages.\${pkgs.system}.default\`
- QML source in \`quickshell/.config/quickshell/\` — symlinked live via \`mkDotfileSymlink\`
- Widgets: \`Bar.qml\`, \`Dock.qml\`, \`Workspaces.qml\`, \`VolumeWidget.qml\`, \`BatteryWidget.qml\`, \`BrightnessWidget.qml\`, \`SysTray*.qml\`
- \`BatteryWidget\` visibility conditioned on \`ushinnary.hardware.hasBattery\`
- Doc links:
- - https://quickshell.org/
- - https://quickshell.org/docs/v0.2.1/types/
- - https://git.outfoxxed.me/quickshell/quickshell-examples

## Nixvim (\`dev.enable = true\`)
- Entry point: \`nix/modules/nixvim/default.nix\`
- Plugins: \`plugins/\` (UI/tools), \`plugins/lang/\` (language), \`plugins/lsp/\` (LSP)
- Plugin docs: https://nix-community.github.io/nixvim/plugins
- Formatters via conform.nvim: \`nixfmt\`, \`stylua\`, \`csharpier\`, \`nufmt\`

## Zotac Zone Specifics
- \`jovian.steam.autoStart = true\` boots directly into Steam Gaming Mode
- Extra \`boot.initrd.kernelModules\` required for touchscreen/gamepad/TDP control (\`msr\` for ryzenadj)

## Non-NixOS Systems
- \`./install.sh\` — GNU Stow-based dotfile linking
- \`scripts/fedora/\`, \`scripts/arch/\`, \`scripts/ubuntu/\` — distro-specific setup scripts
