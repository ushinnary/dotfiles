alias nvimconfig = nvim ~/.config/nvim
alias fg = job unfreeze
alias ?? = gh copilot suggest
alias nfc = nix flake check
alias nfu = nix flake update

def nrfs [flake: string] {
    sudo nixos-rebuild switch --flake $flake
}
