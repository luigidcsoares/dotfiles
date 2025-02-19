{ catppuccin, emacs-overlay, username, rootPath, ... }:
{ ... }: {
  imports = [
    (import ./emacs { inherit emacs-overlay; })
    ./nvim
    (import ./security { inherit rootPath; })
    (import ./shell { inherit rootPath; })
    (import ./ui { inherit catppuccin; })
    ./tools
    ./zathura
  ];

  home = {
    inherit username;
    homeDirectory = "/home/${username}";
  };

  # This value determines the Home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new Home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update Home Manager without changing this value. See
  # the Home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "23.11";

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
