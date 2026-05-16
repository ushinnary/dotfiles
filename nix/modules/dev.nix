{
  pkgs,
  lib,
  config,
  vars,
  ...
}:
let
  cfg = config.ushinnary.dev;

  selectedEditors = cfg.editors;
  selectedServers = cfg.servers;
  hasEditor = editor: builtins.elem editor selectedEditors;
  hasServer = server: builtins.elem server selectedServers;

  # ── Dotfile helpers ─────────────────────────────────────────────
  # Relative paths inside ~/dotfiles for out-of-store Home Manager symlinks.
  nuRelativeRoot = "nushell/.config/nushell";

  zedLspPackages = with pkgs; [
    nodejs_24
    nil
    nixd
    nushell
    vscode-langservers-extracted
    lua-language-server
    docker-language-server
    powershell
    tree-sitter-grammars.tree-sitter-kdl
  ];
in
{
  imports = [ ./nixvim/default.nix ];

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [
      pkgs.ast-grep

      pkgs.ghostty
      pkgs.vim

      pkgs.yazi
      pkgs.nufmt
      pkgs.kdlfmt
      pkgs.starship
      pkgs.ripgrep
      pkgs.fd
      pkgs.fzf
      pkgs.lazygit
      pkgs.zoxide
      pkgs.zellij
      pkgs.difftastic

      pkgs.git-credential-manager
      pkgs.devenv
      pkgs.nushell
    ]
    ++ lib.optionals cfg.aiAgents [
      pkgs.opencode
      pkgs.pi-coding-agent
    ]
    ++ lib.optional (hasEditor "vscode") pkgs.vscode;

    environment.variables = {
      TERMINAL = "ghostty";
    };

    programs.nix-ld = {
      enable = true;
    };

    # programs.bash.interactiveShellInit = ''
    #   if ! [ "$TERM" = "dumb" ] && [ -z "$BASH_EXECUTION_STRING" ]; then
    #     exec nu
    #   fi
    # '';

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
        programs.zed-editor = lib.mkIf (hasEditor "zed") {
          enable = true;
          extraPackages = zedLspPackages;
          installRemoteServer = true;
        };

        programs = {
          carapace = {
            enable = true;
            enableNushellIntegration = true;
          };
        };

        xdg.configFile = {
          # ── Nushell ──────────────────────────────────────────
          "nushell" = {
            source = mkDotfileSymlink "${nuRelativeRoot}";
            recursive = true;
          };

          # ── Lazygit ──────────────────────────────────────────
          "lazygit/config.yml".source = mkDotfileSymlink "lazygit/.config/lazygit/config.yml";

          # ── Starship ─────────────────────────────────────────
          "starship.toml".source = mkDotfileSymlink "starship/.config/starship.toml";

          # ── Zellij ───────────────────────────────────────────
          "zellij/config.kdl".source = mkDotfileSymlink "zellij/.config/zellij/config.kdl";

          # ── Zed ──────────────────────────────────────────────
          "zed" = {
            source = mkDotfileSymlink "zed/.config/zed";
            recursive = true;
          };

          # Ghostty
          "ghostty" = {
            source = mkDotfileSymlink "ghostty/.config/ghostty";
            recursive = true;
          };

          # ── Kitty ─────────────────────────────────────────────
          "kitty/kitty.conf".source = mkDotfileSymlink "kitty/.config/kitty/kitty.conf";

          # # ── Pipewire ─────────────────────────────────────────
          # "pipewire/pipewire.conf.d/hesuvi.conf".source =
          #   mkDotfileSymlink "pipewire/.config/pipewire/pipewire.conf.d/hesuvi.conf";
        };
        # Nushell completion scripts — one entry per tool

        # ── Files that live in $HOME directly ──────────────────────
        home.file = {
          ".alacritty.toml".source = mkDotfileSymlink "alacritty/.alacritty.toml";
          ".wezterm.lua".source = mkDotfileSymlink "wezterm/.wezterm.lua";

          # Agent PI
          ".pi" = lib.mkIf cfg.aiAgents {
            source = mkDotfileSymlink "pi/.pi";
            recursive = true;
          };

          # Zed server
          ".zed_server" = lib.mkIf (!hasEditor "zed" && hasServer "zed") {
            source = "${pkgs.zed-editor.remote_server}/bin";
            recursive = true;
          };
        };

      };
  };
}
