# Bash aliases and shell helpers for working with this dotfiles repo.
# Source this file from your ~/.bashrc if you want Bash to use these commands.

alias nvimconfig='nvim ~/.config/nvim'
alias nfc='(cd ~/dotfiles/nix && nix flake check)'
alias nfu='(cd ~/dotfiles/nix && nix flake update)'
alias ncg='nh clean all'
alias subup='(cd ~/dotfiles && git submodule update --init --remote --merge)'

nrfs() {
	if [ "$#" -ne 1 ]; then
		echo "Usage: nrfs <flake>"
		return 1
	fi

	nh os switch "$1"
}

# inshellisense — IDE-style autocomplete wrapping the shell. IS_TERM is
# set by `is` itself in the session it spawns, so this guard stops it
# from re-launching itself recursively. Skips silently if `is` isn't
# installed on this host.
if [ -z "$IS_TERM" ] && command -v is >/dev/null 2>&1; then
	is
fi
