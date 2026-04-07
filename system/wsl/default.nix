{ username, ... }:
{ pkgs, ... }: {
  wsl = {
    enable = true;
    defaultUser = username;
    startMenuLaunchers = true;

    wslConf.boot = {
      systemd = true;
      initTimeout = 30000; # Increase to 30s
    };
  };

  environment.systemPackages = [ pkgs.wslu pkgs.wl-clipboard ];
}
