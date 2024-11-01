-- home/nvim/molten.lua
vim.g.molten_auto_open_output = false
vim.g.molten_image_provider = "wezterm"
vim.g.molten_virt_text_output = true

vim.keymap.set(
  "n", "<localleader>mi", ":MoltenInit<CR>",
  { silent = true, desc = "Initialize the plugin" }
)

vim.keymap.set(
  "n", "<localleader>meo", ":MoltenEvaluateOperator<CR>",
  { silent = true, desc = "Run operator selection" }
)

vim.keymap.set(
  "n", "<localleader>mel", ":MoltenEvaluateLine<CR>",
  { silent = true, desc = "Evaluate line" }
)

vim.keymap.set(
  "n", "<localleader>mrc", ":MoltenReevaluateCell<CR>",
  { silent = true, desc = "Re-evaluate cell" }
)

vim.keymap.set(
  "v", "<localleader>mev", ":<C-u>MoltenEvaluateVisual<CR>gv",
  { silent = true, desc = "Evaluate visual selection" }
)

vim.keymap.set(
  "n", "<localleader>mo", ":noautocmd MoltenEnterOutput<CR>",
  { silent = true, desc = "Show/Enter output" }
)