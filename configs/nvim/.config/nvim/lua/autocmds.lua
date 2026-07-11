-- Highlight when yanking text
vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking (copying) text',
  group = vim.api.nvim_create_augroup('highlight-yank', { clear = true }),
  callback = function()
    vim.hl.on_yank()
  end,
})

-- Reload files when they change on disk
vim.api.nvim_create_autocmd({ 'BufEnter', 'CursorHold', 'FocusGained', 'TermClose', 'TermLeave' }, {
  desc = 'Reload file when changed on disk',
  group = vim.api.nvim_create_augroup('autoread', { clear = true }),
  callback = function()
    if vim.fn.mode() ~= 'c' then
      vim.cmd 'checktime'
    end
  end,
})
