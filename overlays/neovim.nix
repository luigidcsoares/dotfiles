final: prev:
let
  pluginWithName = plugin: {
    name = plugin.pname;
    value = plugin;
  };

  makePluginAttrSet = plugins:
    builtins.listToAttrs (map pluginWithName plugins);

  normalizePlugin = plugin: { inherit plugin; };
  makeConfig = pluginsAttrSet:
    prev.neovimUtils.makeNeovimConfig {
      plugins =
        map normalizePlugin (builtins.attrValues pluginsAttrSet);
    };

  wrapNeovim = config:
    prev.wrapNeovimUnstable prev.neovim-unwrapped
    (config // { wrapRc = false; });

  plugins = final.vimPlugins;
  defaultPlugins = makePluginAttrSet [
    plugins.catppuccin-nvim
    plugins.nvim-web-devicons
    plugins.lualine-nvim
    plugins.plenary-nvim
    plugins.telescope-nvim
    plugins.telescope-file-browser-nvim
    (plugins.nvim-treesitter.withPlugins (treesitter: [
      treesitter.elixir
      treesitter.lua
      treesitter.nix
      treesitter.python
      treesitter.vim
      treesitter.vimdoc
    ]))
    plugins.nvim-lspconfig
    plugins.neorg
    plugins.vimtex
  ];
in {
  myNeovimUtils = {
    inherit makePluginAttrSet makeConfig wrapNeovim defaultPlugins;
  };
  my-neovim = wrapNeovim (makeConfig defaultPlugins);
}