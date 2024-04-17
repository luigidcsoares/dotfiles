-- home/nvim/term.lua
require("toggleterm").setup({
  open_mapping = "<Leader>tt",
  insert_mappings = false,
  terminal_mappings = false,
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