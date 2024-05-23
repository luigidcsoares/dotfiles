# system/ui.nix
{ pkgs, ... }: {
  programs.dconf.enable = true;
  fonts = {
    fontconfig = {
      enable = true;
      defaultFonts = {
        monospace = [ "Iosevka Nerd Font" ];
        serif = [ "Iosevka Etoile" ];
        sansSerif = [ "Iosevka Aile" ];
      };
    };

    packages = [
      (pkgs.iosevka-bin.override { variant = "Aile"; })
      (pkgs.iosevka-bin.override { variant = "Etoile"; })
      (pkgs.nerdfonts.override { fonts = [ "Iosevka" ]; })
    ];
  };
}