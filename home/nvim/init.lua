-- Enable project local configuration
vim.opt.exrc = true

-- Default indentation options
vim.opt.expandtab = true
vim.opt.tabstop = 2
vim.opt.softtabstop = 2
vim.opt.shiftwidth = 2

-- Map both leader and localleader to space
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Sets up clipboard
vim.opt.clipboard = "unnamedplus"
vim.g.clipboard = {
  name = "WSLClipboard",
  copy = {
    ["+"] = "clip.exe",
    ["*"] = "clip.exe"
  },
  paste = {
    ["+"] = 'powershell.exe -c [Console]::Out.Write($(Get-Clipboard -Raw).tostring().replace("`r", ""))',
    ["*"] = 'powershell.exe -c [Console]::Out.Write($(Get-Clipboard -Raw).tostring().replace("`r", ""))',
  },
  cache_enabled = 0
}

-- Show replace result in split window
vim.opt.inccommand = "split"

-- Default UI options
vim.opt.number = true
vim.opt.splitbelow = true
vim.opt.splitright = true
vim.opt.textwidth = 72
vim.opt.termguicolors = true
vim.opt.concealcursor = ""
vim.opt.conceallevel = 2
vim.opt.foldlevel = 99

require("catppuccin").setup({ flavour = "frappe" })

require("lualine").setup({ options = { theme = "catppuccin" } })

local telescope = require("telescope")
local telescope_builtin = require("telescope.builtin")

telescope.setup({
  extensions = {
    file_browser = {
      hijack_netrw = true,
      hidden = true
    }
  },
  pickers = {
    buffers = {
      sort_lastused = true,
      sort_mru = true
    }
  }
})

-- Telescope mappings
vim.keymap.set("n", "<Leader>ff", telescope_builtin.find_files, {})
vim.keymap.set("n", "<leader>lg", telescope_builtin.live_grep, {})
vim.keymap.set("n", "<Leader>bf", telescope_builtin.buffers, {})
vim.keymap.set("n", "<Leader>ht", telescope_builtin.help_tags, {})

-- Telescope extensions
telescope.load_extension('fzf')
telescope.load_extension("file_browser")
vim.keymap.set(
 "n",
 "<Leader>fb", -- As in emacs "dired"
 ":Telescope file_browser path=%:p:h select_buffer=true<CR>",
 {}
)

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

local lspconfig = require("lspconfig")

lspconfig.lua_ls.setup({})
lspconfig.nixd.setup({})
lspconfig.pyright.setup({})

vim.api.nvim_create_autocmd("LspAttach", {
 group = vim.api.nvim_create_augroup("UserLspConfig", {}),
 callback = function(ev)
   local opts = { buffer = ev.buf }
   vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
   vim.keymap.set("n", "<Leader>fmt", vim.lsp.buf.format, opts)
 end
})

luasnip = require("luasnip")
luasnip.setup({
  enable_autosnippets = true,
  store_selection_keys = "<Tab>"
})

require("luasnip.loaders.from_lua").load({
  paths = "~/.config/nvim/snippets"
})

local has_words_before = function()
  unpack = unpack or table.unpack
  local line, col = unpack(vim.api.nvim_win_get_cursor(0))
  return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
end

local cmp = require("cmp")
cmp.setup({
  snippets = {
    expand = function(args) luasnip.lsp_expand(args.body) end
  },
  mapping = {
    ["<Tab>"] = cmp.mapping(function(fallback)
      if cmp.visible() then
        if #cmp.get_entries() == 1 then
          cmp.confirm({ select = true })
        else
          cmp.select_next_item()
        end
      elseif luasnip.locally_jumpable(1) then
        luasnip.jump(1)
      elseif has_words_before() then
        cmp.complete()
        if #cmp.get_entries() == 1 then
          cmp.confirm({ select = true })
        end
      else
        fallback()
      end
    end, { "i", "s" }),
  },
  sources = {
    { name = "buffer" },
  },
})

cmp.setup.filetype("tex", {
  sources = { 
    { name = "buffer" },
    { name = "vimtex" },
  },
})

require("toggleterm").setup({
 open_mapping = "<Leader>tt",
 insert_mappings = false,
 terminal_mappings = false,
 start_in_insert = true,
 hide_numbers = true,
 direction = "float"
})

_G.set_terminal_keymaps = function()
 local opts = { buffer = 0 }
 vim.keymap.set("t", "<ESC>", [[<C-\><C-n>]], opts)
 vim.keymap.set("t", "<C-w>", [[<C-\><C-n><C-w>]], opts)
end

vim.cmd("autocmd! TermOpen term://* lua set_terminal_keymaps()")

require("orgmode").setup({})

vim.g.vimtex_callback_progpath = vim.fn.system("which nvim")
vim.g.vimtex_view_method = "sioyek"
