require("nvim-treesitter.configs").setup({
  highlight = {
    enable = true,
    disable = { "latex" }
  },
  indent = { enable = true },
  incremental_selection = {
    enable = true,
    keymaps = {
      node_incremental = "v",
      node_decremental = "z",
      scope_incremental = "<Tab>",
    }
  }
})
