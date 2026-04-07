{ lib, ...  }: {
  programs.helix = {
    enable = true;
    languages = builtins.fromTOML (
      lib.strings.concatStringsSep "\n\n" [
        (builtins.readFile ./languages/harper.toml)
        (builtins.readFile ./languages/latex.toml)
      ]
    );
    settings = builtins.fromTOML (builtins.readFile ./config.toml);
  };

  catppuccin.helix = {
    enable = true;
    flavor = "frappe";
  };
}
