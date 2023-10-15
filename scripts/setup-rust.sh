#!/bin/bash
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh &&
	cargo install cargo-update &&
	cargo install ripgrep &&
	cargo install fd-find &&
	cargo install starship &&
	cargo install exa &&
	cargo install bat &&
	cargo install tokei --features all &&
	cargo install stylua &&
	cargo install sqlx-cli --no-default-features --features postgres &&
	cargo install wasm-pack &&
	cargo install bottom
