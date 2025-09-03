{ pkgs, ... }: {
  home.file.".config/nvim/snippets".source = ./snippets;
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    extraLuaConfig = builtins.readFile ./init.lua;
    plugins = [
      pkgs.vimPlugins.catppuccin-nvim
      pkgs.vimPlugins.nvim-web-devicons
      pkgs.vimPlugins.lualine-nvim

      pkgs.vimPlugins.direnv-vim
      pkgs.vimPlugins.telescope-nvim
      pkgs.vimPlugins.telescope-file-browser-nvim
      pkgs.vimPlugins.telescope-fzf-native-nvim
      pkgs.vimPlugins.toggleterm-nvim

      pkgs.vimPlugins.orgmode
      pkgs.vimPlugins.vimtex
      
      pkgs.vimPlugins.luasnip
      pkgs.vimPlugins.nvim-cmp
      pkgs.vimPlugins.cmp-buffer
      pkgs.vimPlugins.cmp-vimtex
      pkgs.vimPlugins.cmp_luasnip

      pkgs.vimPlugins.nvim-lspconfig
      pkgs.vimPlugins.nvim-treesitter.withAllGrammars

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

    extraPackages = [ pkgs.harper ];
    extraLuaPackages = luaPkgs: [ ];
    extraPython3Packages = pythonPkgs: [ ];
  };
}
