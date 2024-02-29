-- home/nvim/options.lua
-- Enable project local configuration
vim.opt.exrc = true

-- Default indentation options
vim.opt.expandtab = true
vim.opt.tabstop = 2
vim.opt.softtabstop = 2
vim.opt.shiftwidth = 2

-- Default keymap options
vim.g.mapleader = " "
vim.g.maplocalleader = ","

-- Default UI options
vim.opt.number = true
vim.opt.splitbelow = true
vim.opt.splitright = true
vim.opt.textwidth = 73
vim.opt.termguicolors = true
vim.opt.concealcursor = ""
vim.opt.conceallevel = 2
vim.opt.foldlevel = 99

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