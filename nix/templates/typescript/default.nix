{ pkgs ? import <nixpkgs> {} }:

pkgs.mkShell {
  packages = with pkgs; [
    # Node.js ecosystem
    nodejs_22
    nodejs_22.pnpm
    nodejs_22.yarn
    npm
    bun
    deno

    # TypeScript
    typescript
    tsserver

    # Frontend frameworks CLI
    # (uncomment as needed)
    # @angular/cli
    # vue
    # svelte

    # Build tools
    esbuild
    vite
    webpack
    parcel

    # Linting & formatting
    prettier
    eslint
    biome

    # Testing
    playwright
    vitest
    jest

    # Dev tools
    git
    gh
    direnv
    just

    # Browser tools
    google-chrome
    firefox

    # Additional utilities
    curl
    wget
    jq
  ];

  # Environment variables
  # NODE_ENV = "development";
  # Enable corepack for pnpm/yarn
  COREPACK_ENABLE_AUTO_PIN = "0";

  shellHook = ''
    echo "TypeScript/Frontend development environment loaded"
    echo "Useful commands:"
    echo "  pnpm install     - Install dependencies"
    echo "  pnpm dev         - Start dev server"
    echo "  pnpm build       - Build for production"
    echo "  pnpm lint        - Lint code"
    echo "  pnpm format      - Format code"
    echo "  pnpm test        - Run tests"
  '';
}