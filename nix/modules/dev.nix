{
  pkgs,
  lib,
  config,
  vars,
  ...
}:
let
  cfg = config.ushinnary.dev;

  # ── Dotfile helpers ─────────────────────────────────────────────
  # Relative paths inside ~/dotfiles for out-of-store Home Manager symlinks.
  nuRelativeRoot = "nushell/.config/nushell";
  nuCompletions = [
    "cargo"
    "dotnet"
    "git"
    "npm"
    "rg"
    "rustup"
    "ssh"
    "tar"
    "zellij"
    "zoxide"
  ];

  zedLspPackages = with pkgs; [
    nodejs
    nil
    nixd
    rust-analyzer
    nushell
    vscode-langservers-extracted
    lua-language-server
    biome
    docker-language-server
    powershell
  ];
in
{
  imports = [ ./nixvim/default.nix ];

  config = lib.mkIf cfg.enable {
    users.users."${vars.userName}".shell = pkgs.nushell;

    environment.systemPackages = [
      pkgs.ast-grep

      pkgs.ghostty
      pkgs.vim

      pkgs.yazi
      pkgs.nufmt
      pkgs.starship
      pkgs.ripgrep
      pkgs.fd
      pkgs.fzf
      pkgs.lazygit
      pkgs.zoxide
      pkgs.zellij
      pkgs.difftastic
      pkgs.dust
      pkgs.gh
      pkgs.dotnet-sdk

      pkgs.git-credential-manager

      pkgs.vscode
    ];

    environment.variables = {
      TERMINAL = "ghostty";
    };

    programs.nix-ld = {
      enable = true;
    };

    programs.direnv = {
      enable = true;
      nix-direnv.enable = true;
    };

    # ── Home-manager: map existing dotfiles into place ─────────────
    # Files are linked out-of-store to ~/dotfiles, so edits are picked up
    # immediately (stow-like) without rebuilding.
    home-manager.users."${vars.userName}" =
      { config, ... }:
      let
        mkDotfileSymlink =
          relativePath:
          config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dotfiles/${relativePath}";
      in
      {
        programs.zed-editor = {
          enable = true;
          extraPackages = zedLspPackages;
          installRemoteServer = true;
        };

        xdg.configFile = {
          # ── Nushell ──────────────────────────────────────────
          "nushell/config.nu".source = mkDotfileSymlink "${nuRelativeRoot}/config.nu";
          "nushell/env.nu".source = mkDotfileSymlink "${nuRelativeRoot}/env.nu";
          "nushell/alias.nu".source = mkDotfileSymlink "${nuRelativeRoot}/alias.nu";

          # ── Lazygit ──────────────────────────────────────────
          "lazygit/config.yml".source = mkDotfileSymlink "lazygit/.config/lazygit/config.yml";

          # ── Starship ─────────────────────────────────────────
          "starship.toml".source = mkDotfileSymlink "starship/.config/starship.toml";

          # ── Zellij ───────────────────────────────────────────
          "zellij/config.kdl".source = mkDotfileSymlink "zellij/.config/zellij/config.kdl";

          # ── Zed ──────────────────────────────────────────────
          "zed/settings.json".source = mkDotfileSymlink "zed/.config/zed/settings.json";
          # "zed/keymap.json".source =
          #   mkDotfileSymlink "zed/.config/zed/keymap.json";

          # ── Kitty ─────────────────────────────────────────────
          "kitty/kitty.conf".source = mkDotfileSymlink "kitty/.config/kitty/kitty.conf";

          # # ── Pipewire ─────────────────────────────────────────
          # "pipewire/pipewire.conf.d/hesuvi.conf".source =
          #   mkDotfileSymlink "pipewire/.config/pipewire/pipewire.conf.d/hesuvi.conf";
        }
        # Nushell completion scripts — one entry per tool
        // builtins.listToAttrs (
          map (tool: {
            name = "nushell/${tool}-completions.nu";
            value = {
              source = mkDotfileSymlink "${nuRelativeRoot}/${tool}-completions.nu";
            };
          }) nuCompletions
        );

        # ── Files that live in $HOME directly ──────────────────────
        home.file = {
          ".alacritty.toml".source = mkDotfileSymlink "alacritty/.alacritty.toml";
          ".wezterm.lua".source = mkDotfileSymlink "wezterm/.wezterm.lua";
        };
      };
  };
}
