{ pkgs, ... }: {
  home.file.".config/nvim/after".source = ./nvim/after;
  programs.neovim = {
    defaultEditor = true;
    enable = true;
    extraLuaConfig = builtins.readFile ./nvim/options.lua;
    plugins = let plugins = pkgs.vimPlugins;
    in [
      {
        plugin = plugins.catppuccin-nvim;
        type = "lua";
        config = builtins.readFile ./nvim/catppuccin.lua;
      }
      { plugin = plugins.nvim-web-devicons; }
      {
        plugin = plugins.lualine-nvim;
        type = "lua";
        config = builtins.readFile ./nvim/lualine.lua;
      }
      { plugin = plugins.plenary-nvim; }
      { plugin = plugins.telescope-file-browser-nvim; }
      {
        plugin = plugins.telescope-nvim;
        type = "lua";
        config = builtins.readFile ./nvim/telescope.lua;
      }
      {
        plugin = (plugins.nvim-treesitter.withPlugins (treesitter: [
          treesitter.elixir
          treesitter.lua
          treesitter.nix
          treesitter.python
          treesitter.vim
          treesitter.vimdoc
        ]));
        type = "lua";
        config = builtins.readFile ./nvim/treesitter.lua;
      }
      {
        plugin = plugins.nvim-lspconfig;
        type = "lua";
        config = builtins.readFile ./nvim/lspconfig.lua;
      }
      {
        plugin = plugins.neorg;
        type = "lua";
        config = builtins.readFile ./nvim/neorg.lua;
      }
      {
        plugin = plugins.vimtex;
        type = "lua";
        config = builtins.readFile ./nvim/vimtex.lua;
      }
    ];
  };
}