# home/tools.nix
{ ... }: {
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  programs.fzf.enable = true;
  programs.ripgrep.enable = true;

  services.ssh-agent.enable = true;
  programs.git = {
    enable = true;
    userName = "Luigi D. C. Soares";
    userEmail = "dev@luigidcsoares.com";
  };
}