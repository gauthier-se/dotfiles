-- Unused providers: disabled to avoid checkhealth warnings
vim.g.loaded_node_provider = 0
vim.g.loaded_perl_provider = 0
vim.g.loaded_ruby_provider = 0
vim.g.loaded_python3_provider = 0

vim.o.termguicolors = true
vim.o.number = true
vim.o.relativenumber = true
vim.o.mouse = 'a'
vim.o.showmode = false

-- Indentation defaults (guess-indent.nvim overrides per-file when it can)
vim.o.tabstop = 4
vim.o.shiftwidth = 4
vim.o.expandtab = true
vim.o.smartindent = true

-- Don't soft-wrap long lines; scroll horizontally instead
vim.o.wrap = false

-- Sync clipboard with the OS (scheduled: can increase startup time)
vim.schedule(function()
  vim.o.clipboard = 'unnamedplus'
end)

vim.o.breakindent = true
vim.o.undofile = true
vim.o.autoread = true

-- undofile keeps history; swap/backup files are just clutter
vim.o.swapfile = false
vim.o.backup = false

-- Case-insensitive search unless \C or capitals in the term
vim.o.ignorecase = true
vim.o.smartcase = true

vim.o.signcolumn = 'yes'
vim.o.updatetime = 250
vim.o.timeoutlen = 300

vim.o.splitright = true
vim.o.splitbelow = true

vim.o.list = true
vim.opt.listchars = { tab = '» ', trail = '·', nbsp = '␣' }

-- Live preview of substitutions
vim.o.inccommand = 'split'

vim.o.cursorline = true
vim.o.colorcolumn = '80'
vim.o.scrolloff = 10
vim.o.sidescrolloff = 8

-- Rounded borders on floating windows (LSP hover, diagnostics, etc.)
vim.o.winborder = 'rounded'

-- Ask to save instead of failing on :q with unsaved changes
vim.o.confirm = true
