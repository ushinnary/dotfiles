#!/bin/sh
sudo apt install -y \
	build-essential pkg-config autoconf bison clang cmake stow \
	libssl-dev libreadline-dev zlib1g-dev libyaml-dev libreadline-dev libncurses5-dev libffi-dev libgdbm-dev libjemalloc2 \
	libvips imagemagick libmagickwand-dev mupdf mupdf-tools unzip \
	redis-tools sqlite3 libsqlite3-0 libmysqlclient-dev libpq-dev postgresql-client postgresql-client-common python3-venv \
	liblua5.1-0-dev luarocks
