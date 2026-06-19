-- lazygit.nvim: Open lazygit in a floating window from Neovim
return {
  'kdheepak/lazygit.nvim',
  lazy = true,
  cmd = {
    'LazyGit',
    'LazyGitConfig',
    'LazyGitCurrentFile',
    'LazyGitFilter',
    'LazyGitFilterCurrentFile',
  },
  -- optional for floating window border decoration
  dependencies = {
    'nvim-lua/plenary.nvim',
  },
  keys = {
    { '<leader>lg', '<cmd>LazyGit<cr>', desc = '[L]azy[G]it' },
    { '<leader>lf', '<cmd>LazyGitFilter<cr>', desc = '[L]azyGit [F]ilter (project commits)' },
    { '<leader>lc', '<cmd>LazyGitFilterCurrentFile<cr>', desc = '[L]azyGit filter [C]urrent file commits' },
  },
}
