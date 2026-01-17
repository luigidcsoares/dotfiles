{ ...  }: {
  programs.helix = {
    enable = true;
    languages = builtins.fromTOML (builtins.readFile ./languages/latex.toml); 
    settings = builtins.fromTOML (builtins.readFile ./config.toml);
  };

  catppuccin.helix = {
    enable = true;
    flavor = "frappe";
  };
}
