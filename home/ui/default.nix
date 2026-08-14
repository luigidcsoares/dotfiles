{ config, pkgs, ... }: {
  home.packages = [
    (pkgs.iosevka-bin.override { variant = "Aile"; })
    (pkgs.iosevka-bin.override { variant = "Etoile"; })
    pkgs.nerd-fonts.iosevka
    pkgs.nerd-fonts.symbols-only
  ];

  home.sessionVariables = {
    GDK_SCALE = "1.5";
    GDK_DPI_SCALE = "1.5";
    GTK_SCALE = "1.5";
    QT_SCALE_FACTOR = "1.5";
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

  catppuccin = {
    enable = true;
    flavor = "latte";
  };
  
  gtk = {
    enable = true;
    theme = {
      package = pkgs.magnetic-catppuccin-gtk.override {
        tweaks = [ "frappe" ];
      };
      name = "Catppuccin-GTK-Dark-Frappe";
    };
  };
  
  qt = {
    enable = true;
    platformTheme.name = "kvantum";
    style.name = "kvantum";
  };

}
