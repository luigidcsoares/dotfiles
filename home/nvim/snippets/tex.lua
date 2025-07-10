local luasnip = require("luasnip")
local luasnip_extras = require("luasnip.extras")
local luasnip_fmt = require("luasnip.extras.fmt")

local in_mathzone = function()
  return vim.fn["vimtex#syntax#in_mathzone"]() == 1
end


-- Summary: When `LS_SELECT_RAW` is populated with a visual selection, the function
-- returns an insert node whose initial text is set to the visual selection.
-- When `LS_SELECT_RAW` is empty, the function simply returns an empty insert node.
local get_visual = function(_, parent)
  if (#parent.snippet.env.LS_SELECT_RAW > 0) then
    return luasnip.sn(nil, luasnip.i(1, parent.snippet.env.LS_SELECT_RAW))
  else -- If LS_SELECT_RAW is empty, return a blank insert node
    return luasnip.sn(nil, luasnip.i(1))
  end
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
  )),
  -- Creating environments (although we can just ]] to close with vimtex)
  luasnip.s({
    name = "environment",
    trig = "\\env",
  }, luasnip_fmt.fmta(
    [[
      \begin{<>}
        <>
      \end{<>}
    ]], {
      luasnip.i(1),
      luasnip.d(2, get_visual),
      luasnip_extras.rep(1),
    }
  )),
  -- Surrounding text selected with visual
  luasnip.s({
    name = "surround",
    -- This is used for:
    -- * () and [], including things like \command(a)
    -- * \command{} or just {}
    -- * $$ and \[\] for math
    trig = "([^%(%[{%$]*([%(%[{%$]))",
    trigEngine = "pattern",
    wordTrig = false
  }, luasnip_fmt.fmta(
    "<><><>", {
      luasnip.f(function(_, snip) return snip.captures[1] end),
      luasnip.d(1, get_visual),
      luasnip.f(function(_, snip)
        local has_backslash = string.sub(snip.captures[1], -2, -1) == "\\["
        local delim_map = {
          ["("] = ")",
          ["["] = has_backslash and "\\]" or "]",
          ["{"] = "}",
          ["$"] = "$"
        }
        return delim_map[snip.captures[2]]
      end),
    }
  )),
}

return snippets, autosnippets
