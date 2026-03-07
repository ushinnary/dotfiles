{
  pkgs,
  lib,
  config,
  dotfiles,
  ...
}:
let
  cfg = config.ushinnary.dev;

  # ── Dotfile helpers ─────────────────────────────────────────────
  # `dotfiles` is the flake input (path:.. pointing to ~/dotfiles).
  # Shortcuts for each stow package's config root.
  nu     = "${dotfiles}/nushell/.config/nushell";
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

  zedExtensions = [
    "nix"
    "toml"
    "rust"
    "nu"
    "html"
    "catppuccin"
    "catppuccin-blur"
    "catppuccin-icons"
    "surrealql"
    "dockerfile"
    "sql"
    "vue"
    "scss"
    "lua"
    "xml"
    "csharp"
    "svelte"
    "emmet"
    "nix"
    "biome"
    "csv"
    "docker-compose"
    "powershell"
    "ini"
    "nu"
  ];
in
{
  imports = [ ./nixvim/default.nix ];

  config = lib.mkIf cfg.enable {
    users.users.ushinnary.shell = pkgs.nushell;

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

      pkgs.stow
      pkgs.git-credential-manager

      pkgs.vscode
      # pkgs.antigravity
    ];

    environment.variables = {
      TERMINAL = "ghostty";
      QT_SCALE_FACTOR = "1.33";
    };

    programs.nix-ld = {
      enable = true;
      # libraries = [ pkgs.zlib pkgs.openssl ];
    };

    programs.direnv = {
      enable = true;
      nix-direnv.enable = true;
    };

    # ── Home-manager: map existing dotfiles into place ─────────────
    # Files come from the `dotfiles` flake input (path:..) so editing
    # the source files and rebuilding is all that's needed — no stow.
    home-manager.users.ushinnary =
      { ... }:
      {
        programs.zed-editor = {
          enable = true;
          extensions = zedExtensions;
          installRemoteServer = true;
        };

        xdg.configFile =
          {
            # ── Nushell ──────────────────────────────────────────
            "nushell/config.nu".source = "${nu}/config.nu";
            "nushell/env.nu".source    = "${nu}/env.nu";
            "nushell/alias.nu".source  = "${nu}/alias.nu";

            # ── Lazygit ──────────────────────────────────────────
            "lazygit/config.yml".source =
              "${dotfiles}/lazygit/.config/lazygit/config.yml";

            # ── Starship ─────────────────────────────────────────
            "starship.toml".source =
              "${dotfiles}/starship/.config/starship.toml";

            # ── Zellij ───────────────────────────────────────────
            "zellij/config.kdl".source =
              "${dotfiles}/zellij/.config/zellij/config.kdl";

            # # ── Zed ──────────────────────────────────────────────
            # "zed/settings.json".source =
            #   "${dotfiles}/zed/.config/zed/settings.json";
            # "zed/keymap.json".source =
            #   "${dotfiles}/zed/.config/zed/keymap.json";

            # ── Electron flags ────────────────────────────────────
            "electron-flags.conf".source =
              "${dotfiles}/electron/.config/electron-flags.conf";

            # ── Kitty ─────────────────────────────────────────────
            "kitty/kitty.conf".source =
              "${dotfiles}/kitty/.config/kitty/kitty.conf";

            # ── Pipewire ─────────────────────────────────────────
            "pipewire/pipewire.conf.d/hesuvi.conf".source =
              "${dotfiles}/pipewire/.config/pipewire/pipewire.conf.d/hesuvi.conf";
          }
          # Nushell completion scripts — one entry per tool
          // builtins.listToAttrs (
            map (tool: {
              name  = "nushell/${tool}-completions.nu";
              value = { source = "${nu}/${tool}-completions.nu"; };
            }) nuCompletions
          );

        # ── Files that live in $HOME directly ──────────────────────
        home.file = {
          ".alacritty.toml".source =
            "${dotfiles}/alacritty/.alacritty.toml";
          ".wezterm.lua".source =
            "${dotfiles}/wezterm/.wezterm.lua";
        };
      };
  };
}
