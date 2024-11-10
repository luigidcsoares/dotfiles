{ rootPath, ... }:
{ lib, pkgs, ... }: {
  home.packages = [ pkgs.git-crypt ];
  programs.ssh = {
    enable = true;
    addKeysToAgent = "yes";
    extraConfig = builtins.readFile "${rootPath}/secrets/ssh_config";
  };

  programs.gpg.enable = true;
  services.ssh-agent.enable = false;
  services.gpg-agent = {
    enable = true;
    enableSshSupport = true;
    pinentryPackage = pkgs.pinentry-qt;
  };

  programs.password-store.enable = true;
  services.pass-secret-service.enable = true;
}
