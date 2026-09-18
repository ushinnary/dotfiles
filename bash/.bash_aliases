# Bash aliases and shell helpers for working with this dotfiles repo.
# Source this file from your ~/.bashrc if you want Bash to use these commands.

alias nvimconfig='nvim ~/.config/nvim'
alias nfc='(cd ~/dotfiles/nix && nix flake check)'
alias nfu='(cd ~/dotfiles/nix && nix flake update)'
alias ncg='nh clean all'
alias subup='(cd ~/dotfiles && git submodule update --init --remote --merge)'
alias wtls='git worktree list'
alias wtprune='git worktree prune'

# Usage:
#   wtnew feature/login
#   wtnew fix/payment-bug
#
# Equivalent to:
#   git worktree add -b feature/login feature/login main
#
wtnew() {
	local branch="$1"
    local base="${2:-main}"

    if [ -z "$branch" ]; then
        echo "Usage: wtnew <branch> [base]"
        return 1
    fi

	git fetch origin --prune || return 1

    git worktree add "$branch" -b "$branch" "origin/$base" && cd "$branch"
}

# Checkout an EXISTING branch as a worktree
#
# Usage:
#   wtadd feature/login
#
wtadd() {
    local branch="$1"

    if [ -z "$branch" ]; then
        echo "Usage: wtadd <branch>"
        return 1
    fi

    git worktree add "$branch" "$branch" && cd "$branch"
}


# Remove a worktree after PR is merged
#
# Usage:
#   wtdone feature/login
#
wtdone() {
    local branch="$1"

    if [ -z "$branch" ]; then
        echo "Usage: wtdone <branch>"
        return 1
    fi

    git worktree remove "$branch" || return 1
    git branch -d "$branch"
    git fetch --prune
}

nrfs() {
	if [ "$#" -ne 1 ]; then
		echo "Usage: nrfs <flake>"
		return 1
	fi

	nh os switch "$1"
}
