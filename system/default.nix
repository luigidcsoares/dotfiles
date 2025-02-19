{ username, ... }:
{ pkgs, ... }: { 
  imports = [ 
    ./dev
    ./docker
    ./shell
    ./ui
    (import ./wsl { inherit username; })
  ]; 

  nix.package = pkgs.nixVersions.stable;
  nix.extraOptions = ''
    experimental-features = nix-command flakes
  '';

  # Enable nix-ld for third party binaries.
  # WARNING: use this as a last resort, prefer to rely on nix.
  programs.nix-ld.enable = true;

  # time.timeZone = "America/Sao_Paulo";
  time.timeZone = "Australia/Sydney";

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database
  # versions on your system were taken. It's perfectly fine and
  # recommended to leave this value at the release version of the
  # first install of this system.  Before changing this value read the
  # documentation for this option (e.g. man configuration.nix or on
  # https://nixos.org/nixos/options.html).
  system.stateVersion = "23.11";
}
