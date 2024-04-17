-- home/nvim/term.lua
require("toggleterm").setup({
  open_mapping = "<Leader>tt",
  insert_mappings = false,
  -- Using <Leader> as <space>, there's gonna be a lag when typing 
  -- space followed by a t. We can disable terminal mappings, but 
  -- then we have to exit to normal mode (ESC) every time we want
  -- to quit the terminal, which is a little incovenient.
  -- terminal_mappings = false,
  start_in_insert = true,
  hide_numbers = true,
  direction = "float"
})

function _G.set_terminal_keymaps()
  local opts = { buffer = 0 }
  vim.keymap.set("t", "<ESC>", [[<C-\><C-n>]], opts)
  vim.keymap.set("t", "<C-w>", [[<C-\><C-n><C-w>]], opts)
end

vim.cmd("autocmd! TermOpen term://* lua set_terminal_keymaps()")