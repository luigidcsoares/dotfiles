{ pkgs, ... }: {
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  programs.fzf.enable = true;
  programs.ripgrep.enable = true;

  programs.sioyek = {
    enable = true;
    bindings = {
      "next_page" = "J";
      "previous_page" = "K";
    };
    config = {
      "linear_filter" = "1";
      "startup_commands" = ''
        toggle_custom_color
      '';
    };
  };

  programs.git = {
    enable = true;
    userName = "Luigi D. C. Soares";
    userEmail = "dev@luigidcsoares.com";
    aliases = {
      cm = "commit";
      cmsg = "commit -m";
      cma = "commit --amend";
      cman = "commit --amend --no-edit";
      cmsga = "commit --amend -m";
      last = "log -1 HEAD";
      st = "status";
    };
    extraConfig = {
      credential.helper = "${pkgs.pass-git-helper}/bin/pass-git-helper";
      init.defaultBranch = "main";
      pull.rebase = true;
    };
  };
  
  home.file.".config/pass-git-helper/git-pass-mapping.ini".text = ''
    [github.com*]
    target=dev/gpg/ssh
    
    [gitlab.com*]
    target=dev/gpg/ssh

    [git.overleaf.com*]
    target=dev/overleaf
  '';

  # Disable validation check because it is too slow (vpn?)
  home.file.".config/wslu/conf".text = ''
    WSLVIEW_SKIP_VALIDATION_CHECK=0
  '';
}
