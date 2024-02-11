{ pkgs, ... }: {
  programs.zsh = {
    enable = true;
    enableAutosuggestions = true;
    enableCompletion = true;
    initExtra = ''
      # Sets up Windows Terminal to duplicate tab at the same dir
      # See https://learn.microsoft.com/en-us/windows/terminal/tutorials/new-tab-same-directory
      keep_current_path() { 
        printf "\e]9;9;%s\e\\" "$(wslpath -w "$PWD")" 
      }
      precmd_functions+=(keep_current_path)
    '';
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
  };
}