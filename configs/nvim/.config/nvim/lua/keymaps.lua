-- Clear search highlights
vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')

-- Open netrw in the current file's directory — ThePrimeagen style
vim.keymap.set('n', '<leader>pv', vim.cmd.Ex, { desc = '[P]roject [V]iew (netrw)' })

-- Diagnostics
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostic [Q]uickfix list' })

-- Exit terminal mode
vim.keymap.set('t', '<Esc><Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })

-- Split navigation with CTRL+hjkl
vim.keymap.set('n', '<C-h>', '<C-w><C-h>', { desc = 'Move focus to the left window' })
vim.keymap.set('n', '<C-l>', '<C-w><C-l>', { desc = 'Move focus to the right window' })
vim.keymap.set('n', '<C-j>', '<C-w><C-j>', { desc = 'Move focus to the lower window' })
vim.keymap.set('n', '<C-k>', '<C-w><C-k>', { desc = 'Move focus to the upper window' })

-- AZERTY macOS numbers map
local azerty_opts = { noremap = true, silent = true }
vim.keymap.set({ 'n', 'v', 'o' }, '&', '1', azerty_opts)
vim.keymap.set({ 'n', 'v', 'o' }, 'é', '2', azerty_opts)
vim.keymap.set({ 'n', 'v', 'o' }, '"', '3', azerty_opts)
vim.keymap.set({ 'n', 'v', 'o' }, "'", '4', azerty_opts)
vim.keymap.set({ 'n', 'v', 'o' }, '(', '5', azerty_opts)
vim.keymap.set({ 'n', 'v', 'o' }, '§', '6', azerty_opts)
vim.keymap.set({ 'n', 'v', 'o' }, 'è', '7', azerty_opts)
vim.keymap.set({ 'n', 'v', 'o' }, '!', '8', azerty_opts)
vim.keymap.set({ 'n', 'v', 'o' }, 'ç', '9', azerty_opts)
vim.keymap.set({ 'n', 'v', 'o' }, 'à', '0', azerty_opts)
