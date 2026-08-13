nixos-update() {
    cd ~/workspace/dotfiles || return
    nix shell nixpkgs#emacs -c emacs --script tangle-all.el
    sudo nixos-rebuild switch --flake ./#nixos "$@"
    cp home/wezterm/wezterm.lua $(wslpath "$(wslvar USERPROFILE)")/.config/wezterm/
    cd -
}
