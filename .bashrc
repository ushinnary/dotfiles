# .bashrc

# Source global definitions
if [ -f /etc/bashrc ]; then
	. /etc/bashrc
fi

# User specific environment
if ! [[ "$PATH" =~ "$HOME/.local/bin:$HOME/bin:" ]]; then
	PATH="$HOME/.local/bin:$HOME/bin:$PATH"
fi
export PATH="$PATH:$HOME/nvim-linux64/bin/"
export PATH="$PATH:$HOME/RustUtils/"
export PATH="$PATH:$HOME/.local/bin"
export PATH="$PATH:$HOME/lua-lsp/bin/"
export PATH

# Aliases
alias nvimconfig="nvim ~/.config/nvim"
alias ubuntu="distrobox enter ubuntu_lts"
alias docker="podman"
# Uncomment the following line if you don't like systemctl's auto-paging feature:
# export SYSTEMD_PAGER=

# User specific aliases and functions
if [ -d ~/.bashrc.d ]; then
	for rc in ~/.bashrc.d/*; do
		if [ -f "$rc" ]; then
			. "$rc"
		fi
	done
fi

unset rc

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"                   # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion" # This loads nvm bash_completion

#if command -v starship -v &>/dev/null; then
#	eval "$(starship init bash)"
#	exit
#fi

#if command -v zsh &>/dev/null; then
#	exec zsh
#	exit
#fi
#
