#!/bin/bash
set_nvim() {
	cp ./nvim/init.lua ~/.config/nvim/
	cp ./nvim ~/.config/nvim/lua/ -r
}

set_zsh() {
	cp ./home/.zshrc ~/
}
if [[ " $@ " =~ " --nvim " ]]; then
	set_nvim
fi

if [[ " $@ " =~ " --zsh " ]]; then
	set_zsh
fi


if [[ " $@ " =~ " --all " ]]; then
	set_nvim
	set_zsh
fi
