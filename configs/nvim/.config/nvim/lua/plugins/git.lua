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
      on_attach = function(bufnr)
        local gitsigns = require 'gitsigns'
        local function map(mode, l, r, desc)
          vim.keymap.set(mode, l, r, { buffer = bufnr, desc = desc })
        end

        map('n', ']h', function() gitsigns.nav_hunk 'next' end, 'Next git [H]unk')
        map('n', '[h', function() gitsigns.nav_hunk 'prev' end, 'Previous git [H]unk')

        map('n', '<leader>hs', gitsigns.stage_hunk, '[H]unk [S]tage')
        map('n', '<leader>hr', gitsigns.reset_hunk, '[H]unk [R]eset')
        map('v', '<leader>hs', function() gitsigns.stage_hunk { vim.fn.line '.', vim.fn.line 'v' } end, '[H]unk [S]tage lines')
        map('v', '<leader>hr', function() gitsigns.reset_hunk { vim.fn.line '.', vim.fn.line 'v' } end, '[H]unk [R]eset lines')
        map('n', '<leader>hp', gitsigns.preview_hunk, '[H]unk [P]review')
      end,
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
