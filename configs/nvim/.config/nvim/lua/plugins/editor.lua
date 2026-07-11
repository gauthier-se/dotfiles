return {
  -- Detect tabstop and shiftwidth automatically
  'NMAC427/guess-indent.nvim',

  { -- Collection of small independent modules
    'echasnovski/mini.nvim',
    config = function()
      -- Better around/inside textobjects (va), yinq, ci'…)
      require('mini.ai').setup { n_lines = 500 }
      -- Add/delete/replace surroundings (saiw), sd', sr)'…)
      require('mini.surround').setup()
    end,
  },

  {
    'windwp/nvim-autopairs',
    event = 'InsertEnter',
    opts = {},
  },

  { -- Visualize the undo history tree
    'mbbill/undotree',
    cmd = { 'UndotreeToggle', 'UndotreeShow', 'UndotreeFocus' },
    keys = {
      { '<leader>u', '<cmd>UndotreeToggle<cr>', desc = '[U]ndotree toggle' },
    },
  },

  {
    'MeanderingProgrammer/render-markdown.nvim',
    dependencies = { 'nvim-treesitter/nvim-treesitter', 'nvim-tree/nvim-web-devicons' },
    ft = { 'markdown' },
    opts = {},
    keys = {
      { '<leader>tm', '<cmd>RenderMarkdown toggle<CR>', desc = '[T]oggle [M]arkdown rendering' },
    },
  },
}
