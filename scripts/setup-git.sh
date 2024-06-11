#!/bin/bash

FILE_PATH="$HOME/.gitconfig"
SEARCH_TEXT="difftastic"

if [ -f "$FILE_PATH" ]; then
	if grep -q "$SEARCH_TEXT" "$FILE_PATH"; then
		echo "Difftastic already in use"
	else
		cat <<EOL >>"$HOME/.gitconfig"

[diff]
  tool = difftastic
  external = difft

[difftool]
  prompt = false

[difftool "difftastic"]
  cmd = difft "\$LOCAL" "\$REMOTE"

[pager]
  difftool = true

[alias]
  dft = difftool
  dlog = "-c diff.external=difft log -p --ext-diff"

EOL
	fi
fi
