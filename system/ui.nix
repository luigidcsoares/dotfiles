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

    packages = with pkgs; [
      (iosevka-bin.override { variant = "Aile"; })
      (iosevka-bin.override { variant = "Etoile"; })
      (nerdfonts.override { fonts = [ "Iosevka" ]; })
    ];
  };
}