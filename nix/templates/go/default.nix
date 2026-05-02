{ pkgs ? import <nixpkgs> {} }:

pkgs.mkShell {
  packages = with pkgs; [
    # Go toolchain
    go_1_23
    go_1_22
    gopls
    gofmt
    goimports

    # Build tools
    goreleaser
    buildkit

    # Linting & formatting
    golangci-lint
    staticcheck

    # Testing
    gotestsum
    ginkgo
    testify

    # Dev tools
    git
    gh
    direnv
    just

    # Additional tools
    golang
    protobuf
    protoc-gen-go
    protoc-gen-go-grpc

    # System dependencies
    gcc
    make
  ];

  # Environment variables
  GO111MODULE = "on";
  GOPROXY = "https://proxy.golang.org,direct";
  # CGO_ENABLED = "1";

  shellHook = ''
    echo "Go development environment loaded"
    echo "Useful commands:"
    echo "  go mod init      - Initialize module"
    echo "  go mod tidy      - Tidy dependencies"
    echo "  go build        - Build binary"
    echo "  go run .        - Run program"
    echo "  go test ./...   - Run tests"
    echo "  go vet          - Vet code"
    echo "  golangci-lint run - Run linters"
  '';
}