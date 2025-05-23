local luasnip = require("luasnip")
local luasnip_fmt = require("luasnip.extras.fmt")

local in_mathzone = function()
  return vim.fn["vimtex#syntax#in_mathzone"]() == 1
end

local snippets = {}
local autosnippets = {
  -- Quotes (TODO: surround text in visual mode)
  luasnip.s({
    name = "quotes",
    trig = [[""]],
  }, luasnip_fmt.fmta(
    "``<>''", {
      luasnip.i(1)
    }
  )),
  -- Sub and superscripts in math mode
  luasnip.s({
    name = "subscript",
    trig = "_(.)",
    condition = in_mathzone,
    trigEngine = "pattern",
    wordTrig = false
  }, luasnip_fmt.fmta(
    "_{<><>}", {
      luasnip.f(function(_, snip) return snip.captures[1] end),
      luasnip.i(1)
    }
  )),
  luasnip.s({
    name = "superscript",
    trig = "%^(.)",
    condition = in_mathzone,
    trigEngine = "pattern",
    wordTrig = false
  }, luasnip_fmt.fmta(
    "^{<><>}", {
      luasnip.f(function(_, snip) return snip.captures[1] end),
      luasnip.i(1)
    }
  ))
}

return snippets, autosnippets
