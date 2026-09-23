-- Light/dark colorscheme, driven by the mode file the `theme` script writes.
-- The state dir is watched, so running nvim instances switch live.
local M = {}

local dir = vim.fn.expand '~/.local/state/theme'

local colorschemes = {
  dark = 'moonfly',
  light = 'github_light',
}

local function read_mode()
  local f = io.open(dir .. '/mode', 'r')
  if not f then
    return 'dark'
  end
  local mode = vim.trim(f:read '*a')
  f:close()
  return colorschemes[mode] and mode or 'dark'
end

function M.apply()
  local colorscheme = colorschemes[read_mode()]
  if vim.g.colors_name ~= colorscheme then
    vim.cmd.colorscheme(colorscheme)
  end
end

function M.setup()
  M.apply()
  vim.fn.mkdir(dir, 'p')
  vim.uv.new_fs_event():start(dir, {}, vim.schedule_wrap(M.apply))
end

return M
