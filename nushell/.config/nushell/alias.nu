alias nvimconfig = nvim ~/.config/nvim
alias fg = job unfreeze
# Keep in sync with the bash aliases in nix/modules/core/default.nix.
# `cd` inside a plain `def` doesn't leak to the caller, and a failing
# external stops the block — like the `( … && … )` subshells there.
def nfc [] { cd ~/dotfiles/nix; ./fmt.sh --check; nix flake check }
def nfu [] { cd ~/dotfiles/nix; nix flake update }
alias ncg = nh clean all
alias fd = fd --hidden
def subup [] { cd ~/dotfiles; git submodule update --init --remote --merge }
# nh reads NH_FLAKE (set in nix/modules/system/packages.nix).
alias nrfs = nh os switch
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
