# overlays/neovim.nix
final: prev:
let
  neovimDefaultPlugins = let plugins = final.vimPlugins;
  in [
    plugins.catppuccin-nvim
    plugins.nvim-web-devicons
    plugins.lualine-nvim
    plugins.plenary-nvim
    plugins.telescope-nvim
    plugins.telescope-file-browser-nvim
    plugins.toggleterm-nvim
    plugins.nvim-treesitter.withAllGrammars
    plugins.nvim-lspconfig
    plugins.neorg
    plugins.vimtex
  ];

  neovimWithPlugins = extraPlugins:
    let
      normalizePlugin = plugin: { inherit plugin; };
      plugins = neovimDefaultPlugins ++ extraPlugins;
      config = prev.neovimUtils.makeNeovimConfig {
        plugins = map normalizePlugin plugins;
      };
    in prev.wrapNeovimUnstable prev.neovim-unwrapped
    (config // { wrapRc = false; });
in {
  inherit neovimDefaultPlugins neovimWithPlugins;
  neovim = neovimWithPlugins [ ];
}