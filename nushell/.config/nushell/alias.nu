alias nvimconfig = nvim ~/.config/nvim
alias fg = job unfreeze
alias nfc = nix flake check
alias nfu = nix flake update
alias ncg = sudo nix-collect-garbage -d

def nrfs [flake: string] {
    sudo nixos-rebuild switch --flake $flake
}
