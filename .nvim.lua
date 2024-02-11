local neorg = require("neorg.core")
local tangle_module = neorg.modules.loaded_modules["core.tangle"]
local tangle_handle = tangle_module.on_event
tangle_module.on_event = function(event)
  tangle_handle(event)
  vim.loop.sleep(1)
  for _, pathname in pairs(vim.split(vim.fn.glob("*.nix"), "\n")) do
    local action_start, action_end = pathname:find("%.move%.")
    if action_start and action_end then
      local dir = pathname:sub(0, action_start - 1):gsub("%.", "/")
      local file = pathname:sub(action_end + 1)
      vim.loop.fs_mkdir(dir, tonumber("755", 8))
      vim.loop.fs_rename(pathname, dir .. "/" .. file)
    end
  end
end