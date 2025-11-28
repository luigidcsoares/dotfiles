{ rootPath, ... }:
{ lib, pkgs, ... }: {
  home.packages = [ pkgs.git-crypt ];
  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
    matchBlocks."*".addKeysToAgent = "yes";
    extraConfig = builtins.readFile "${rootPath}/secrets/ssh_config";
  };

  programs.gpg.enable = true;
  services.ssh-agent.enable = false;
  services.gpg-agent = {
    enable = true;
    enableSshSupport = true;
    sshKeys = builtins.split "\n" (builtins.readFile "${rootPath}/secrets/gpg_keys");
    pinentry.package = pkgs.pinentry-tty;
    # extraConfig = ''
    #   allow-loopback-pinentry
    # '';
  };

  programs.password-store.enable = true;
  services.pass-secret-service.enable = true;
}
