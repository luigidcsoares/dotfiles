{ catppuccin, ... }:
{ config, pkgs, ... }: {
  imports = [ catppuccin.homeManagerModules.catppuccin ];
  catppuccin = {
    enable = true;
    flavor = "mocha";
  };

  gtk = {
    enable = true;
    # catppuccin.enable = true;
  };

  fonts.fontconfig = {
    enable = true;
    defaultFonts = {
      emoji = [ "Symbols Nerd Font Mono" ];
      monospace = [ "Iosevka Nerd Font" ];
      serif = [ "Iosevka Etoile" ];
      sansSerif = [ "Iosevka Aile" ];
    };
  };

  home.packages = [
    (pkgs.iosevka-bin.override { variant = "Aile"; })
    (pkgs.iosevka-bin.override { variant = "Etoile"; })
    (pkgs.nerdfonts.override { 
      fonts = [ "Iosevka" "NerdFontsSymbolsOnly" ]; 
    })
  ];

  # home.sessionVariables = {
  #   GDK_SCALE = "1.5";
  #   GDK_DPI_SCALE = "1.5";
  #   GTK_SCALE = "1.5";
  #   QT_SCALE_FACTOR = "1.5";
  # };
}
