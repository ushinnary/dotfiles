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
  hasDesktop =
    config.ushinnary.desktop.gnome
    || config.ushinnary.desktop.cosmic
    || config.ushinnary.desktop.plasma
    || config.ushinnary.desktop.niri;

  # ── Dotfile helpers ─────────────────────────────────────────────
  # Relative paths inside ~/dotfiles for out-of-store Home Manager symlinks.
  nuRelativeRoot = "nushell/.config/nushell";

  zedLspPackages = with pkgs; [
    nil
    nixd
    lua-language-server
    vscode-langservers-extracted
  ];
in
{
  options.ushinnary.dev = {
    enable = lib.mkEnableOption "development tools and Helix editor";
    editors = lib.mkOption {
      type = lib.types.listOf (lib.types.enum [ "helix" "vscode" "zed" ]);
      default = [ "helix" "vscode" "zed" ];
      description = "Select which development editors to install";
    };
    servers = lib.mkOption {
      type = lib.types.listOf (lib.types.enum [ "vscode" "zed" ]);
      default = [ ];
      description = "Select which development servers to install";
    };
    aiAgents = lib.mkEnableOption "AI agent CLI tools (kilocode-cli)";
  };

  imports = [ ];

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
      pkgs.gh

      pkgs.devenv
      pkgs.nushell

      # IDE-style autocomplete wrapping bash/nushell — launched on shell
      # start, see core/default.nix bashrcExtra and nushell/env.nu.
      pkgs.inshellisense

      # LSPs & Formatters
      pkgs.nixd
      pkgs.nixfmt
      pkgs.lua-language-server
      pkgs.stylua
      pkgs.vscode-langservers-extracted
      pkgs.typescript-language-server
      pkgs.prettier
      pkgs.marksman
    ]
    ++ lib.optionals hasDesktop [
      pkgs.git-credential-manager
    ]
    ++ lib.optionals cfg.aiAgents [
      pkgs.opencode
      pkgs.pi-coding-agent
    ]
    ++ lib.optional (hasEditor "vscode") pkgs.vscode;

    environment.variables = {
      TERMINAL = "ghostty";
      RIPGREP_CONFIG_PATH = "$HOME/.ripgreprc";
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
      { mkDotfileSymlink, ... }:
      {
        programs.zed-editor = lib.mkIf (hasEditor "zed") {
          enable = true;
          extraPackages = zedLspPackages;
          installRemoteServer = true;
        };

        programs.helix = lib.mkIf (hasEditor "helix") {
          enable = true;
          settings = {
            theme = "autumn_night_transparent";
            editor = {
              line-number = "relative";
              cursor-shape = {
                normal = "block";
                insert = "bar";
                select = "underline";
              };
              lsp = {
                display-messages = true;
                display-inlay-hints = true;
              };
            };
            keys.normal = {
              # Vim-like keybindings
              d = {
                d = [ "extend_to_line_bounds" "delete_selection" ];
                i = {
                  w = [ "select_textobject_inner_word" "delete_selection" ];
                };
                a = {
                  w = [ "select_textobject_around_word" "delete_selection" ];
                };
              };
              y = {
                y = [ "extend_to_line_bounds" "yank" ];
                i = {
                  w = [ "select_textobject_inner_word" "yank" ];
                };
                a = {
                  w = [ "select_textobject_around_word" "yank" ];
                };
              };
              c = {
                c = [ "extend_to_line_bounds" "change_selection" ];
                i = {
                  w = [ "select_textobject_inner_word" "change_selection" ];
                };
                a = {
                  w = [ "select_textobject_around_word" "change_selection" ];
                };
              };

              # Window navigation
              "C-h" = "jump_view_left";
              "C-j" = "jump_view_down";
              "C-k" = "jump_view_up";
              "C-l" = "jump_view_right";

              # Buffer navigation
              "H" = ":bp";
              "L" = ":bn";

              # Save & Quit
              "C-s" = ":w";
              
              # Leader maps
              "space" = {
                "q" = {
                  "q" = ":qa";
                };
                "f" = {
                  "n" = ":new";
                };
                "c" = {
                  "f" = ":format";
                };
                "-" = "hsplit";
                "|" = "vsplit";
                "w" = {
                  "d" = "wclose";
                };
              };
            };
            keys.insert = {
              "C-s" = [ ":w" "normal_mode" ];
            };
            keys.select = {
              "C-s" = ":w";
            };
          };
          
          languages = {
            language = [
              {
                name = "nix";
                auto-format = true;
                formatter.command = "${pkgs.nixfmt}/bin/nixfmt";
              }
              {
                name = "lua";
                auto-format = true;
                formatter.command = "${pkgs.stylua}/bin/stylua";
              }
              {
                name = "nushell";
                auto-format = true;
                formatter.command = "${pkgs.nufmt}/bin/nufmt";
              }
              {
                name = "markdown";
                auto-format = true;
              }
              {
                name = "html";
                auto-format = true;
              }
              {
                name = "css";
                auto-format = true;
              }
              {
                name = "json";
                auto-format = true;
              }
              {
                name = "javascript";
                auto-format = true;
              }
              {
                name = "typescript";
                auto-format = true;
              }
            ];
          };

          themes = {
            autumn_night_transparent = {
              "inherits" = "autumn_night";
              "ui.background" = { };
            };
          };
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
