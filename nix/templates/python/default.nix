{ pkgs ? import <nixpkgs> {} }:

pkgs.mkShell {
  packages = with pkgs; [
    # Python interpreters
    python311
    python312
    python313

    # Poetry for dependency management
    poetry
    pip
    pipenv

    # Popular frameworks (uncomment as needed)
    # django
    # flask
    # fastapi
    # pyramid

    # Scientific/data tools (uncomment as needed)
    # numpy
    # scipy
    # pandas
    # matplotlib
    # jupyter
    # ipython

    # Linting & formatting
    ruff
    black
    mypy
    pylint
    pyright

    # Testing
    pytest
    pytest-xdist
    pytest-cov
    coverage
    nox
    tox

    # Dev tools
    git
    gh
    direnv
    just
    uv

    # Database tools
    postgresql
    sqlite

    # Additional utilities
    curl
    wget
    jq
  ];

  # Environment variables
  # PYTHONPATH = "${src}";
  # Enable Python virtualenv
  # VIRTUAL_ENV = "$HOME/.virtualenvs/project";

  shellHook = ''
    echo "Python development environment loaded"
    echo "Useful commands:"
    echo "  poetry install   - Install dependencies"
    echo "  poetry shell     - Activate virtual env"
    echo "  poetry run ...   - Run command in env"
    echo "  ruff check       - Lint code"
    echo "  black .          - Format code"
    echo "  mypy .           - Type check"
    echo "  pytest          - Run tests"
  '';
}