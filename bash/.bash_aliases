# Bash aliases and shell helpers for working with this dotfiles repo.
# Source this file from your ~/.bashrc if you want Bash to use these commands.

alias nvimconfig='nvim ~/.config/nvim'
alias nfc='(cd ~/dotfiles/nix && nix flake check)'
alias nfu='(cd ~/dotfiles/nix && nix flake update)'
alias ncg='sudo nix-collect-garbage -d'
alias subup='(cd ~/dotfiles && git submodule update --init --remote --merge)'

nrfs() {
	if [ "$#" -ne 1 ]; then
		echo "Usage: nrfs <flake>"
		return 1
	fi

	sudo nixos-rebuild switch --flake "$1"
}
