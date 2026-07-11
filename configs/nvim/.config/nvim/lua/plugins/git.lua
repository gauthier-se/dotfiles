return {
  { -- Git signs in the gutter
    'lewis6991/gitsigns.nvim',
    opts = {
      signs = {
        add = { text = '+' },
        change = { text = '~' },
        delete = { text = '_' },
        topdelete = { text = '‾' },
        changedelete = { text = '~' },
      },
    },
  },

  { -- The premier git wrapper for vim (tpope)
    'tpope/vim-fugitive',
    cmd = { 'Git', 'G', 'Gdiffsplit', 'Gvdiffsplit', 'Gread', 'Gwrite', 'Gclog' },
    keys = {
      { '<leader>gs', '<cmd>Git<cr>', desc = '[G]it [S]tatus' },
      { '<leader>gb', '<cmd>Git blame<cr>', desc = '[G]it [B]lame' },
      { '<leader>gd', '<cmd>Gvdiffsplit<cr>', desc = '[G]it [D]iff split' },
      { '<leader>gl', '<cmd>Gclog<cr>', desc = '[G]it [L]og (current file)' },
    },
  },
}
