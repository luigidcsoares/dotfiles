# system/wsl.nix
{ pkgs, ... }: {
  wsl = {
    enable = true;
    defaultUser = "luigidcsoares";
    startMenuLaunchers = true;
  };
  environment.systemPackages = [ pkgs.wslu ];
}