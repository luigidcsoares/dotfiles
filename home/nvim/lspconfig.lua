-- home/nvim/lspconfig.lua
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