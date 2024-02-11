{ pkgs, ... }: {
  environment.systemPackages = [ pkgs.nixd pkgs.nixfmt ];
}