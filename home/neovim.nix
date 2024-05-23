# home/neovim.nix
{ pkgs, ... }: {
  home.file = {
    # ".config/nvim/after".source = ./nvim/after;
    ".config/nvim/init.lua".text = ''
      ${builtins.readFile ./nvim/options.lua}
      ${builtins.readFile ./nvim/catppuccin.lua}
      ${builtins.readFile ./nvim/lualine.lua}
      ${builtins.readFile ./nvim/telescope.lua}
      ${builtins.readFile ./nvim/treesitter.lua}
      ${builtins.readFile ./nvim/lspconfig.lua}
      ${builtins.readFile ./nvim/term.lua}
      ${builtins.readFile ./nvim/molten.lua}
      ${builtins.readFile ./nvim/neorg.lua}
      ${builtins.readFile ./nvim/vimtex.lua}
    '';
  };

  programs.neovim = {
    enable = true;
    defaultEditor = true;
    plugins = [
      # Dependency for neorg and telescope
      pkgs.vimPlugins.plenary-nvim

      # Dependencies for neorg
      pkgs.vimPlugins.nvim-nio
      pkgs.vimPlugins.nui-nvim

      pkgs.vimPlugins.catppuccin-nvim
      pkgs.vimPlugins.nvim-web-devicons
      pkgs.vimPlugins.lualine-nvim

      pkgs.vimPlugins.direnv-vim
      pkgs.vimPlugins.telescope-nvim
      pkgs.vimPlugins.telescope-file-browser-nvim
      pkgs.vimPlugins.toggleterm-nvim

      pkgs.vimPlugins.nvim-lspconfig
      pkgs.vimPlugins.nvim-treesitter.withAllGrammars

      pkgs.vimPlugins.molten-nvim
      pkgs.vimPlugins.neorg
      pkgs.vimPlugins.vimtex
      
      (pkgs.vimUtils.buildVimPlugin {
        name = "wezterm";
        src = pkgs.fetchFromGitHub {
          owner = "willothy";
          repo = "wezterm.nvim";
          rev = "v0.4.0";
          hash = "sha256-HBwmBlvlw1bZNSSOVpy7iuPpGSMpHRra3Ych2PH+aWY=";
        };
      })
    ];

    extraLuaPackages = luaPkgs: [
      # Dependencies for neorg
      luaPkgs.lua-utils-nvim
      luaPkgs.pathlib-nvim
    ];

    extraPython3Packages = pythonPkgs: [
      # Dependencies for molten
      pythonPkgs.jupyter-client
      pythonPkgs.pynvim
    ];
  };
}