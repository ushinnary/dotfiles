#!/bin/bash
(curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh) &&
  source ~/.bashrc &&
  cargo install cargo-update &&
  cargo install cargo-binstall &&
  cargo binstall ripgrep &&
  cargo binstall starship &&
  cargo binstall stylua &&
  cargo binstall dioxus-cli &&
  cargo binstall fd-find &&
  #cargo binstall sqlx-cli --no-default-features --features postgres &&
  #cargo binstall wasm-pack &&
  cargo binstall bottom &&
  cargo binstall difftastic &&
  cargo binstall nu &&
  cargo binstall zellij &&
  cargo binstall fnm &&
  cargo binstall zoxide --locked &&
  cargo binstall surrealdb-migrations &&
  cargo binstall --locked yazi-fm yazi-cli
