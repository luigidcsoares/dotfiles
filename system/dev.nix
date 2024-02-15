# system/dev.nix
{ pkgs, ... }: {
  environment.systemPackages = [ pkgs.nixd pkgs.nixfmt ];
}