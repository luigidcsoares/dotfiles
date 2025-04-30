local luasnip = require("luasnip")
local luasnip_fmt = require("luasnip.extras.fmt")

local in_mathzone = function()
  return vim.fn["vimtex#syntax#in_mathzone"]() == 1
end

local snippets = {}
local autosnippets = {
  luasnip.s({
      name = "subscript",
      trig = "__",
      condition = in_mathzone,
    },
    luasnip_fmt.fmta("_{<>}", { luasnip.i(1) })
  ),
  luasnip.s({
      name = "superscript",
      trig = "^^",
      condition = in_mathzone,
    },
    luasnip_fmt.fmta("^{<>}", { luasnip.i(1) })
  ),
}

return snippets, autosnippets
