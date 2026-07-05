-- snacks.nvim: collection utilitaire de folke (ici pour le terminal)
return {
  'folke/snacks.nvim',
  priority = 1000,
  lazy = false,
  ---@type snacks.Config
  opts = {
    terminal = {},
  },
  keys = {
    {
      '<leader>tt',
      function()
        Snacks.terminal.toggle()
      end,
      mode = { 'n', 't' },
      desc = '[T]oggle [T]erminal',
    },
  },
}
