{ pkgs, ... }: {
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  programs.fzf.enable = true;
  programs.ripgrep.enable = true;

  programs.git = {
    enable = true;
    userName = "Luigi D. C. Soares";
    userEmail = "dev@luigidcsoares.com";
    extraConfig = {
      credential.helper = "${pkgs.pass-git-helper}/bin/pass-git-helper";
      init.defaultBranch = "main";
    };
  };
  
  home.file.".config/pass-git-helper/git-pass-mapping.ini".text = ''
    [git.overleaf.com*]
    target=dev/overleaf
  '';
}
