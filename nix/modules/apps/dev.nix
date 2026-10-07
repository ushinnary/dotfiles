{
  pkgs,
  lib,
  config,
  vars,
  ...
}: let
  cfg = config.ushinnary.dev;

  selectedEditors = cfg.editors;
  selectedServers = cfg.servers;
  hasEditor = editor: builtins.elem editor selectedEditors;
  hasServer = server: builtins.elem server selectedServers;
  hasDesktop =
    config.ushinnary.desktop.gnome
    || config.ushinnary.desktop.cosmic
    || config.ushinnary.desktop.plasma
    || config.ushinnary.desktop.niri;

  # ── Dotfile helpers ─────────────────────────────────────────────
  # Relative paths inside ~/dotfiles for out-of-store Home Manager symlinks.
  nuRelativeRoot = "nushell/.config/nushell";

  # Shell init generated at build time so it tracks package upgrades instead
  # of going stale in ~/.cache. Nushell sources every
  # share/nushell/vendor/autoload/*.nu after config.nu. The *-init names
  # avoid clashing with the completion-only starship.nu/zoxide.nu those
  # packages ship in the same directory.
  nushellAutoload = pkgs.runCommand "nushell-autoload" {} ''
    dir=$out/share/nushell/vendor/autoload
    mkdir -p $dir
    ${lib.getExe pkgs.starship} init nu > $dir/starship-init.nu
    ${lib.getExe pkgs.zoxide} init nushell > $dir/zoxide-init.nu
    ${lib.getExe pkgs.devenv} hook nu > $dir/devenv-hook.nu
  '';
in {
  options.ushinnary.dev = {
    enable = lib.mkEnableOption "development tools and Nixvim editor";
    editors = lib.mkOption {
      type = lib.types.listOf (
        lib.types.enum [
          "nixvim"
          "vscode"
          "zed"
        ]
      );
      default = [
        "nixvim"
        "vscode"
        "zed"
      ];
      description = "Select which development editors to install";
    };
    servers = lib.mkOption {
      type = lib.types.listOf (lib.types.enum ["zed"]);
      default = [];
      description = "Select which development servers to install";
    };
    aiAgents = lib.mkEnableOption "AI agent CLI tools (Claude Code, OpenCode, and Pi)";
  };

  imports = [./nixvim/default.nix];

  config = lib.mkIf cfg.enable {
    environment.systemPackages =
      [
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

        pkgs.devenv
        pkgs.nushell
        nushellAutoload

        # LSPs & Formatters
        pkgs.nil
        pkgs.alejandra
        pkgs.lua-language-server
        pkgs.stylua
        pkgs.vscode-langservers-extracted
        pkgs.prettier
        pkgs.markdown-oxide
      ]
      ++ lib.optionals hasDesktop [
        pkgs.git-credential-manager
      ]
      ++ lib.optionals cfg.aiAgents [
        pkgs.claude-code
        pkgs.opencode
        pkgs.pi-coding-agent
      ]
      ++ lib.optional (hasEditor "vscode") pkgs.vscode;

    # Links nushellAutoload (and packages' own completions) into
    # /run/current-system/sw/share/nushell/vendor/autoload.
    environment.pathsToLink = ["/share/nushell"];

    environment.variables = {
      TERMINAL = "ghostty";
      RIPGREP_CONFIG_PATH = "$HOME/.ripgreprc";
      CARAPACE_BRIDGES = "zsh,fish,bash,inshellisense";
    };

    # devenv's binary cache, added system-wide so it works without making
    # the user a trusted-user (which is root-equivalent).
    nix.settings = {
      extra-substituters = ["https://devenv.cachix.org"];
      extra-trusted-public-keys = [
        "devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw="
      ];
    };

    # Difftastic as git's preferred diff tool (`git difftool`), plus
    # dft/dlog/dshow aliases. Plain `git diff` stays a unified patch:
    # `git apply`, scripts and AI agents parse it.
    programs.git.config = let
      difft = lib.getExe pkgs.difftastic;
    in {
      diff.tool = "difftastic";
      difftool = {
        prompt = false;
        difftastic.cmd = ''${difft} "$LOCAL" "$REMOTE"'';
      };
      pager.difftool = true;
      alias = {
        dft = "-c diff.external=${difft} diff";
        dlog = "-c diff.external=${difft} log -p --ext-diff";
        dshow = "-c diff.external=${difft} show --ext-diff";
      };
    };

    programs.nix-ld = {
      enable = true;
    };

    # programs.bash.interactiveShellInit = ''
    #   if ! [ "$TERM" = "dumb" ] && [ -z "$BASH_EXECUTION_STRING" ]; then
    #     exec nu
    #   fi
    # '';

    # No direnv: `devenv hook` (bash: core/default.nix, nushell:
    # nushellAutoload) auto-activates devenv projects on cd.

    # ── Home-manager: map existing dotfiles into place ─────────────
    # Files are linked out-of-store to ~/dotfiles, so edits are picked up
    # immediately (stow-like) without rebuilding.
    home-manager.users."${vars.userName}" = {mkDotfileSymlink, ...}: {
      programs.zed-editor = lib.mkIf (hasEditor "zed") {
        enable = true;
        installRemoteServer = true;
      };

      programs = {
        carapace = {
          enable = true;
          enableNushellIntegration = true;
          enableBashIntegration = true;
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
        ".ripgreprc".source = mkDotfileSymlink "ripgrep/.ripgreprc";

        # Claude: keep runtime state and newly created skills local to Claude.
        ".claude/CLAUDE.md" = lib.mkIf cfg.aiAgents {
          source = mkDotfileSymlink "claude/.claude/CLAUDE.md";
        };
        # Store-backed snapshots prevent writes through these links from changing Pi.
        ".claude/skills" = lib.mkIf cfg.aiAgents {
          source = ../../../pi/.pi/agent/skills;
          recursive = true;
        };
        ".claude/checklists" = lib.mkIf cfg.aiAgents {
          source = ../../../pi/.pi/agent/checklists;
          recursive = true;
        };
        ".claude/PERFORMANCE_GUIDELINES.md" = lib.mkIf cfg.aiAgents {
          source = ../../../pi/.pi/agent/PERFORMANCE_GUIDELINES.md;
        };

        # Agent PI
        ".pi" = lib.mkIf cfg.aiAgents {
          source = mkDotfileSymlink "pi/.pi";
          recursive = true;
        };

        # ── Agents (shared agent configs) ────────────────────
        ".agents" = lib.mkIf cfg.aiAgents {
          source = mkDotfileSymlink "pi/.pi/agent";
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
