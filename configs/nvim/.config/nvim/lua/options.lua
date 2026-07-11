-- Unused providers: disabled to avoid checkhealth warnings
vim.g.loaded_node_provider = 0
vim.g.loaded_perl_provider = 0
vim.g.loaded_ruby_provider = 0
vim.g.loaded_python3_provider = 0

vim.o.termguicolors = true
vim.o.number = true
vim.o.mouse = 'a'
vim.o.showmode = false

-- Sync clipboard with the OS (scheduled: can increase startup time)
vim.schedule(function()
  vim.o.clipboard = 'unnamedplus'
end)

vim.o.breakindent = true
vim.o.undofile = true
vim.o.autoread = true

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
vim.o.scrolloff = 10

-- Ask to save instead of failing on :q with unsaved changes
vim.o.confirm = true
