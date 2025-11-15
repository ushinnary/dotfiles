#!/bin/sh
(curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh) &&
  source ~/.bashrc &&
  cargo install cargo-update &&
  cargo install cargo-binstall &&
  cargo binstall ripgrep starship \
    stylua fd-find bottom \
    difftastic nu zellij fnm

cargo binstall zoxide --locked &&
  cargo binstall surrealdb-migrations &&
  cargo binstall --locked yazi-fm yazi-cli
