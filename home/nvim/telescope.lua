-- home/nvim/telescope.lua
local telescope = require("telescope")
local builtin = require("telescope.builtin")

telescope.setup({
  extensions = {
    file_browser = {
      hijack_netrw = true,
      hidden = true
    }
  }
})

-- Telescope mappings
vim.keymap.set("n", "<Leader>ff", builtin.find_files, {})
vim.keymap.set("n", "<leader>lg", builtin.live_grep, {})
vim.keymap.set("n", "<Leader>bf", builtin.buffers, {})
vim.keymap.set("n", "<Leader>ht", builtin.help_tags, {})

-- Telescope extensions
telescope.load_extension("file_browser")
vim.keymap.set(
  "n",
  "<Leader>fb", -- As in emacs "dired"
  ":Telescope file_browser path=%:p:h select_buffer=true<CR>",
  {}
)