#!/bin/bash
flatpak --user override --filesystem=/home/$USER/.icons/:ro && \
flatpak --user override --filesystem=/usr/share/icons/:ro && \
sudo dnf install openssl-devel cmake && \
sudo dnf group install "C Development Tools and Libraries" "Development Tools"