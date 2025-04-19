{ rootPath, ... }:
{ pkgs, ... }: {
  programs.zsh = {
    enable = true;
    autosuggestion.enable = true;
    enableCompletion = true;
    oh-my-zsh = {
      enable = true;
      plugins = [ "fzf" ];
    };
    initExtra = ''
        ${builtins.readFile (rootPath + "/scripts/nixos.sh")}
        ${builtins.readFile (rootPath + "/scripts/wsl.sh")}
    '';
    shellAliases = {
      g = "git";
      rm = "rm -i"; 
      rmr = "rm -ir";
      rmrf = "rm -irf";
    };
  };

  programs.starship = {
    enable = true;
    enableZshIntegration = true;
  };
}
