{ pkgs, ... }: {
  programs.zsh = {
    enable = true;
    autosuggestion.enable = true;
    enableCompletion = true;
    oh-my-zsh = {
      enable = true;
      plugins = [ "git" "fzf" ];
    };
    plugins = [
      {
        name = "powerlevel10k";
        file = "powerlevel10k.zsh-theme";
        src = "${pkgs.zsh-powerlevel10k}/share/zsh-powerlevel10k";
      }
      {
        name = "powerlevel10k-config";
        file = "p10k.zsh";
        src = ./zsh;
      }
    ];
    initExtra = ''
        nixos-update() {
          cd ~/workspace/dotfiles;
          nix shell nixpkgs#emacs -c emacs --script tangle-all.el;
          sudo nixos-rebuild switch --flake ./#nixos "$@";
        }
    '';
    shellAliases = {
      rm = "rm -i"; 
      rmr = "rm -ir";
      rmrf = "rm -irf";
    };
  };
}
