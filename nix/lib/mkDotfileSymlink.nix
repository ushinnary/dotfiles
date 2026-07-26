# Out-of-store symlink into ~/dotfiles, so edits there apply immediately
# without a home-manager rebuild (mirrors how `stow` links the same files
# on non-NixOS hosts). Injected as a module arg via `_module.args` in
# modules/core/default.nix — home-manager modules can just take
# `mkDotfileSymlink` as an argument instead of redefining this.
config: relativePath:
config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dotfiles/${relativePath}"
