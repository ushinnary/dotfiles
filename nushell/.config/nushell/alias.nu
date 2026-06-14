alias nvimconfig = nvim ~/.config/nvim
alias fg = job unfreeze
alias nfc = nix flake check
alias nfu = nix flake update
alias ncg = sudo nix-collect-garbage -d
alias fd = fd --hidden
alias subup = cd ~/dotfiles
git submodule update --init --remote --merge
def nrfs [flake: string] { sudo nixos-rebuild switch --flake $flake }
# Common ls aliases and sort them by type and then name
# Inspired by https://github.com/nushell/nushell/issues/7190
def lla [...args] {
    ls -la ...(if $args == [] { ["."] } else { $args }) | sort-by type name -i
}
def la [...args] {
    ls -a ...(if $args == [] { ["."] } else { $args }) | sort-by type name -i
}
def ll [...args] {
    ls -l ...(if $args == [] { ["."] } else { $args }) | sort-by type name -i
}
def l [...args] {
    ls ...(if $args == [] { ["."] } else { $args }) | sort-by type name -i
}
