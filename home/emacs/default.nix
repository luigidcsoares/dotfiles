{ emacs-overlay, ... }:
{ pkgs, ... }:
let
  earlyInitText = builtins.readFile ./early-init.el;
  initText = builtins.readFile ./init.el;
  parse = pkgs.callPackage "${emacs-overlay}/parse.nix" { };
  mkPackageError =
    name:
    throw "Emacs package ${name}, declare wanted with use-package, not found";
  packages = parse.parsePackagesFromUsePackage {
    configText = initText;
    isOrgModeFile = false;
    alwaysTangle = false;
    alwaysEnsure = false;
  };
in
{
  # services.emacs.enable = true;
  programs.emacs = {
    enable = true;
    package = pkgs.emacs-pgtk;
    extraPackages =
      epkgs: map (name: epkgs.${name} or (mkPackageError name)) packages;
  };

  home = {
    file = {
      ".config/emacs/early-init.el".text = earlyInitText;
      ".config/emacs/init.el".text = initText;
    };
    sessionVariables.EDITOR = "emacs";
  };
}
