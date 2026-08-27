-- Highlight when yanking text
vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking (copying) text',
  group = vim.api.nvim_create_augroup('highlight-yank', { clear = true }),
  callback = function()
    vim.hl.on_yank()
  end,
})

-- Reload files when they change on disk
local autoread = vim.api.nvim_create_augroup('autoread', { clear = true })

vim.api.nvim_create_autocmd({
  'BufEnter',
  'CursorHold',
  'CursorHoldI',
  'FocusGained',
  'TermClose',
  'TermLeave',
}, {
  desc = 'Reload file when changed on disk',
  group = autoread,
  callback = function()
    if vim.fn.mode() ~= 'c' and vim.fn.getcmdwintype() == '' then
      vim.cmd 'checktime'
    end
  end,
})

vim.api.nvim_create_autocmd('FileChangedShellPost', {
  desc = 'Tell me when a buffer was reloaded from disk',
  group = autoread,
  callback = function()
    vim.notify('Buffer reloaded from disk', vim.log.levels.WARN)
  end,
})
