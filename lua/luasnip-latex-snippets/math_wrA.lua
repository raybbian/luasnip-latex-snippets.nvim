local M = {}

local ls = require("luasnip")
local f = ls.function_node
local i = ls.insert_node
local t = ls.text_node

local frac_no_parens = {
  f(function(_, snip)
    return string.format("\\frac{%s}", snip.captures[1])
  end, {}),
  t("{"),
  i(1),
  t("}"),
  i(0),
}

local cmb_no_parens = {
  f(function(_, snip)
    return string.format("\\binom{%s}", snip.captures[1])
  end, {}),
  t("{"),
  i(1),
  t("}"),
  i(0),
}

local frac_node = {
  f(function(_, snip)
    local match = snip.trigger
    local stripped = match:sub(1, #match - 1)

    i = #stripped
    local depth = 0
    while true do
      if stripped:sub(i, i) == ")" then
        depth = depth + 1
      end
      if stripped:sub(i, i) == "(" then
        depth = depth - 1
      end
      if depth == 0 then
        break
      end
      i = i - 1
    end

    local rv =
      string.format("%s\\frac{%s}", stripped:sub(1, i - 1), stripped:sub(i + 1, #stripped - 1))

    return rv
  end, {}),
  t("{"),
  i(1),
  t("}"),
  i(0),
}

local cmb_node = {
  f(function(_, snip)
    local match = snip.trigger
    local stripped = match:sub(1, #match - 3)

    i = #stripped
    local depth = 0
    while true do
      if stripped:sub(i, i) == ")" then
        depth = depth + 1
      end
      if stripped:sub(i, i) == "(" then
        depth = depth - 1
      end
      if depth == 0 then
        break
      end
      i = i - 1
    end

    local rv =
      string.format("%s\\binom{%s}", stripped:sub(1, i - 1), stripped:sub(i + 1, #stripped - 1))

    return rv
  end, {}),
  t("{"),
  i(1),
  t("}"),
  i(0),
}

local subscript_node = {
  f(function(_, snip)
    return string.format("%s_{%s}", snip.captures[1], snip.captures[2])
  end, {}),
  i(0),
}

local frac_no_parens_triggers = {
  "(\\?[%w]+\\?^%w)/",
  "(\\?[%w]+\\?_%w)/",
  "(\\?[%w]+\\?^{%w*})/",
  "(\\?[%w]+\\?_{%w*})/",
  "(\\?%w+)/",
}

local cmb_no_parens_triggers = {
  "(\\?[%w]+\\?^%w)cmb",
  "(\\?[%w]+\\?_%w)cmb",
  "(\\?[%w]+\\?^{%w*})cmb",
  "(\\?[%w]+\\?_{%w*})cmb",
  "(\\?%w+)cmb",
}

function M.retrieve(is_math)
  local utils = require("luasnip-latex-snippets.util.utils")
  local pipe = utils.pipe

  local s = ls.extend_decorator.apply(ls.snippet, {
    wordTrig = false,
    trigEngine = "pattern",
    condition = pipe({ is_math }),
  }) --[[@as function]]

  local snippets = {
    s({
      trig = "([%a])(%d)",
      name = "auto subscript",
    }, vim.deepcopy(subscript_node)),

    s({
      trig = "([%a])_(%d%d)",
      name = "auto subscript 2",
    }, vim.deepcopy(subscript_node)),

    s({
      priority = 1000,
      trig = ".*%)/",
      name = "() frac",
      wordTrig = true,
    }, vim.deepcopy(frac_node)),

    s({
      priority = 1000,
      trig = ".*%)cmb",
      name = "() cmb",
      wordTrig = true,
    }, vim.deepcopy(cmb_node)),
  }

  for _, trig in pairs(frac_no_parens_triggers) do
    snippets[#snippets + 1] = s({
      name = "Fraction no ()",
      trig = trig,
    }, vim.deepcopy(frac_no_parens))
  end

  for _, trig in pairs(cmb_no_parens_triggers) do
    snippets[#snippets + 1] = s({
      name = "Fraction no ()",
      trig = trig,
    }, vim.deepcopy(cmb_no_parens))
  end

  return snippets
end

return M
