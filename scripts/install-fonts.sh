#!/bin/bash

install_font() {
	local fontname="$1"
	local url="$2"

	echo -e "==> Downloading font ${RED}$fontname${NC} from $url"
	filename="${fontname}_tmp"

	# Download the font file, add user-agent for Google Fonts
	if [[ "$url" == *fonts.google.com* ]]; then
		echo "Error: Direct downloads from fonts.google.com are not supported in scripts."
		echo "Please use the Google Fonts GitHub repo for programmatic downloads: https://github.com/google/fonts"
		return 1
	else
		wget -O "$filename" "$url"
	fi

	# Detect file type
	filetype=$(file -b --mime-type "$filename")
	case "$filetype" in
	application/zip)
		echo "==> Extracting $filename to ~/.local/share/fonts"
		mkdir -p ~/.local/share/fonts
		unzip -o "$filename" -d ~/.local/share/fonts
		fc-cache -fv
		;;
	application/x-xz | application/x-tar)
		echo "==> Extracting $filename to ~/.local/share/fonts"
		mkdir -p ~/.local/share/fonts
		tar -xf "$filename" -C ~/.local/share/fonts
		fc-cache -fv
		;;
	application/octet-stream)
		# Try to unzip, fallback to tar, else fail
		if unzip -t "$filename" >/dev/null 2>&1; then
			echo "==> Extracting (detected zip) $filename to ~/.local/share/fonts"
			mkdir -p ~/.local/share/fonts
			unzip -o "$filename" -d ~/.local/share/fonts
			fc-cache -fv
		elif tar -tf "$filename" >/dev/null 2>&1; then
			echo "==> Extracting (detected tar) $filename to ~/.local/share/fonts"
			mkdir -p ~/.local/share/fonts
			tar -xf "$filename" -C ~/.local/share/fonts
			fc-cache -fv
		else
			echo "Unsupported or unknown file type for $filename (octet-stream)"
			rm "$filename"
			return 1
		fi
		;;
	*)
		echo "Unsupported file type: $filetype"
		rm "$filename"
		return 1
		;;
	esac

	echo "==> Cleaning up"
	rm "$filename"
	echo "==> Installation of $fontname done!"
}
