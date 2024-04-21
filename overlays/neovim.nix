# overlays/neovim.nix
final: prev:
let
  neovimDefaultPlugins = let vimPlugins = final.vimPlugins;
  in [
    # Dependency for neorg and telescope
    vimPlugins.plenary-nvim

    # Dependencies for neorg
    vimPlugins.nvim-nio
    vimPlugins.nui-nvim

    vimPlugins.catppuccin-nvim
    vimPlugins.nvim-web-devicons
    vimPlugins.lualine-nvim

    vimPlugins.telescope-nvim
    vimPlugins.telescope-file-browser-nvim
    vimPlugins.toggleterm-nvim

    vimPlugins.nvim-lspconfig
    vimPlugins.nvim-treesitter.withAllGrammars

    vimPlugins.molten-nvim
    vimPlugins.neorg
    vimPlugins.vimtex
  ];

  neovimWithPlugins = extraPlugins:
    let
      normalizePlugin = plugin: { inherit plugin; };
      plugins = neovimDefaultPlugins ++ extraPlugins;
      config = prev.neovimUtils.makeNeovimConfig {
        plugins = map normalizePlugin plugins;
        extraLuaPackages = luaPkgs: [
          # Dependencies for neorg
          luaPkgs.lua-utils-nvim
          luaPkgs.pathlib-nvim
        ];
      };
    in prev.wrapNeovimUnstable prev.neovim-unwrapped
    (config // { wrapRc = false; });
in {
  inherit neovimDefaultPlugins neovimWithPlugins;
  neovim = neovimWithPlugins [ ];
}