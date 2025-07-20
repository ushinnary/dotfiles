#!/bin/bash

set -e

install_font() {
  local fontname="$1"
  local url="$2"

  echo -e "==> Downloading font ${RED}$fontname${NC} from $url"
  filename="${fontname}_tmp"

  # Get the file extension
  ext="${url##*.}"

  # Download the font file
  wget -O "$filename" "$url"

  if [[ "$ext" == "zip" ]]; then
    echo "==> Extracting $filename to ~/.local/share/fonts"
    mkdir -p ~/.local/share/fonts
    unzip -o "$filename" -d ~/.local/share/fonts
    fc-cache -fv
  elif [[ "$ext" == "xz" ]]; then
    echo "==> Extracting $filename to ~/.local/share/fonts"
    mkdir -p ~/.local/share/fonts
    tar -xf "$filename" -C ~/.local/share/fonts
    fc-cache -fv
  else
    echo "Unsupported file extension: $ext"
    rm "$filename"
    return 1
  fi

  echo "==> Cleaning up"
  rm "$filename"
  echo "==> Installation of $fontname done!"
}
