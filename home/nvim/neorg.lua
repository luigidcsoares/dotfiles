require("neorg").setup({
  load = {
    ["core.defaults"] = {},
    ["core.concealer"] = {},
    ["core.export"] = {},
    ["core.keybinds"] = {
      config = {
        hook = function(keybinds)
          keybinds.remap_event(
            "norg", "n", keybinds.leader .. "o",
            "core.looking-glass.magnify-code-block"
          )
        end
      }
    }
  }
})
