{ pkgs ? import <nixpkgs> {} }:

pkgs.mkShell {
  packages = with pkgs; [
    # Compilers
    gcc
    clang
    gdb
    lldb

    # Build systems
    cmake
    meson
    ninja
    make
    autoconf
    automake
    libtool

    # Package managers
    vcpkg
    conan

    # Libraries (uncomment as needed)
    # boost
    # fmt
    # spdlog
    # nlohmann_json
    # sqlite
    # openssl

    # Linting & formatting
    clang-format
    clang-tidy
    cppcheck

    # Dev tools
    git
    gh
    direnv
    just
    valgrind

    # Additional
    pkg-config
  ];

  # Environment variables
  # CC = "clang";
  # CXX = "clang++";
  # CMAKE_BUILD_TYPE = "Debug";

  shellHook = ''
    echo "C/C++ development environment loaded"
    echo "Useful commands:"
    echo "  cmake -B build   - Configure with cmake"
    echo "  cmake --build build - Build"
    echo "  make            - Build with make"
    echo "  make test       - Run tests"
    echo "  clang-format   - Format code"
    echo "  clang-tidy      - Lint code"
  '';
}