{ pkgs, ... }: {
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  programs.fzf.enable = true;
  programs.ripgrep.enable = true;

  programs.zathura = {
    enable = true;
    options = {
      recolor-keephue = "true";
      synctex = "true";
      synctex-editor-command = "texlab inverse-search -i %{input} -l %{line}";
    };
  };
  catppuccin.zathura = {
    enable = true;
    flavor = "frappe";
  };

  programs.sioyek = {
    enable = true;
    bindings = {
      "next_page" = "J";
      "previous_page" = "K";
    };
    config = {
      "linear_filter" = "1";
      "startup_commands" = "toggle_custom_color toggle_synctex"; 
    };
  };

  catppuccin.sioyek = {
    enable = true;
    flavor = "frappe";
  };

  programs.git = {
    enable = true;
    settings = {
      alias = {
        cm = "commit";
        cmsg = "commit -m";
        cma = "commit --amend";
        cman = "commit --amend --no-edit";
        cmsga = "commit --amend -m";
        last = "log -1 HEAD";
        st = "status";
      };
      credential.helper = "${pkgs.pass-git-helper}/bin/pass-git-helper";
      init.defaultBranch = "main";
      pull.rebase = true;
      user.name = "Luigi D. C. Soares";
      user.email = "dev@luigidcsoares.com";
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
