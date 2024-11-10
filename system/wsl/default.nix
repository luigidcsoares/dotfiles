{ username, ... }:
{ pkgs, ... }: {
  wsl = {
    enable = true;
    defaultUser = username;
    startMenuLaunchers = true;
  };

  environment.systemPackages = [ pkgs.wslu pkgs.wl-clipboard ];
}
