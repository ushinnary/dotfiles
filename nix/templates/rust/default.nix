{ pkgs ? import <nixpkgs> {} }:

pkgs.mkShell {
  # Core Rust toolchain
  packages = with pkgs; [
    # Rust toolchain
    rustup
    cargo
    rustc
    clippy
    rustfmt
    rust-analyzer

    # Build tools
    cargo-watch
    cargo-audit
    cargo-outdated
    cargo-tarpaulin
    bindgen
    pkg-config

    # Additional tools
    rust-src
    rustfmt
    rust-analyzer

    # System dependencies (common for Rust crates)
    openssl
    sqlite
    zlib
    cmake
    ninja

    # Dev tools
    git
    gh
    just
    direnv
  ];

  # Environment variables
  RUST_BACKTRACE = "1";
  RUST_LOG = "debug";

  # Shell hooks
  shellHook = ''
    echo "Rust development environment loaded"
    echo "Useful commands:"
    echo "  cargo build      - Build the project"
    echo "  cargo run        - Run the project"
    echo "  cargo test       - Run tests"
    echo "  cargo clippy     - Lint the code"
    echo "  cargo fmt        - Format the code"
    echo "  cargo watch      - Watch for changes"
  '';
}