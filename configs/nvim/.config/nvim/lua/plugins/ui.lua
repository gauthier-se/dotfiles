return {
  { -- Colorscheme
    'bluz71/vim-moonfly-colors',
    name = 'moonfly',
    priority = 1000,
    config = function()
      vim.g.moonflyWinSeparator = 2 -- thin line separators instead of blocks
      vim.cmd.colorscheme 'moonfly'
    end,
  },

  { -- Statusline
    'nvim-lualine/lualine.nvim',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    opts = {
      options = {
        theme = 'moonfly',
        component_separators = { left = '', right = '' },
        section_separators = { left = '', right = '' },
      },
      sections = {
        lualine_a = { { 'mode', right_padding = 2 } },
        lualine_b = { 'filename', 'branch' },
        lualine_c = { 'fileformat' },
        lualine_x = {},
        lualine_y = { 'filetype', 'progress' },
        lualine_z = {
          { 'location', left_padding = 2 },
        },
      },
      inactive_sections = {
        lualine_a = { 'filename' },
        lualine_b = {},
        lualine_c = {},
        lualine_x = {},
        lualine_y = {},
        lualine_z = { 'location' },
      },
    },
  },

  { -- Pending keybind hints
    'folke/which-key.nvim',
    event = 'VimEnter',
    opts = {
      delay = 0,
      icons = { mappings = vim.g.have_nerd_font },
      spec = {
        { '<leader>s', group = '[S]earch' },
        { '<leader>t', group = '[T]est' },
        { '<leader>h', group = 'Git [H]unk', mode = { 'n', 'v' } },
        { '<leader>g', group = '[G]it (fugitive)' },
      },
    },
  },

  { -- Highlight todo, notes, etc. in comments
    'folke/todo-comments.nvim',
    event = 'VimEnter',
    dependencies = { 'nvim-lua/plenary.nvim' },
    opts = { signs = false },
  },

  { -- Indentation guides
    'lukas-reineke/indent-blankline.nvim',
    main = 'ibl',
    opts = {},
  },
}
