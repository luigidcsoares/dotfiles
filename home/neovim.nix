# home/neovim.nix
{ pkgs, ... }: {
  home = {
    sessionVariables.EDITOR = "nvim";
    packages = [ pkgs.neovim ];
    file = {
      ".config/nvim/after".source = ./nvim/after;
      ".config/nvim/init.lua".text = ''
        ${builtins.readFile ./nvim/options.lua}
        ${builtins.readFile ./nvim/catppuccin.lua}
        ${builtins.readFile ./nvim/lualine.lua}
        ${builtins.readFile ./nvim/telescope.lua}
        ${builtins.readFile ./nvim/treesitter.lua}
        ${builtins.readFile ./nvim/lspconfig.lua}
        ${builtins.readFile ./nvim/term.lua}
        ${builtins.readFile ./nvim/neorg.lua}
        ${builtins.readFile ./nvim/vimtex.lua}
      '';
    };
  };
}