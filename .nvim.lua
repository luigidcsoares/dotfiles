vim.api.nvim_create_user_command("NixOS", function()
  vim.cmd("Neorg tangle current-file")
  vim.cmd("Neorg export to-file README.md")
  for _, pathname in pairs(vim.split(vim.fn.glob("*.nix"), "\n")) do
    local action_start, action_end = pathname:find("%.move%.")
    if action_start and action_end then
      local dir = pathname:sub(0, action_start - 1):gsub("%.", "/")
      local file = pathname:sub(action_end + 1)
      vim.loop.fs_mkdir(dir, tonumber("755", 8))
      vim.loop.fs_rename(pathname, dir .. "/" .. file)
    end
  end
end, {})