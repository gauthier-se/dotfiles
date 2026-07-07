-- Support notebooks Jupyter : molten (exécution via kernel) + jupytext (.ipynb <-> py)
-- + image.nvim pour afficher les sorties (plots) inline dans Ghostty
return {
  {
    -- Affichage des images inline (backend kitty, compatible Ghostty)
    '3rd/image.nvim',
    opts = {
      backend = 'kitty',
      max_width = 100,
      max_height = 12,
      max_height_window_percentage = math.huge,
      max_width_window_percentage = math.huge,
      window_overlap_clear_enabled = true,
      window_overlap_clear_ft_ignore = { 'cmp_menu', 'cmp_docs', '' },
    },
  },
  {
    -- Édition transparente des .ipynb : convertit en # %% cellules à l'ouverture
    'GCBallesteros/jupytext.nvim',
    lazy = false,
    opts = {
      style = 'markdown',
      output_extension = 'md',
      force_ft = 'markdown',
    },
  },
  {
    -- Le moteur : exécution des cellules via le protocole Jupyter
    'benlubas/molten-nvim',
    version = '^1.0.0',
    dependencies = { '3rd/image.nvim' },
    build = ':UpdateRemotePlugins',
    init = function()
      -- Host Python dédié (venv isolé d'anaconda) : voir ~/.venvs/neovim
      vim.g.python3_host_prog = vim.fn.expand '~/.venvs/neovim/bin/python'
      vim.g.molten_image_provider = 'image.nvim'
      vim.g.molten_output_win_max_height = 20
      vim.g.molten_auto_open_output = false
      vim.g.molten_virt_text_output = true -- sortie en virtual text sous la cellule
      vim.g.molten_virt_lines_off_by_1 = true
    end,
    keys = {
      { '<leader>mi', ':MoltenInit<CR>', desc = '[M]olten [I]nit kernel' },
      { '<leader>me', ':MoltenEvaluateOperator<CR>', desc = '[M]olten [E]valuate operator' },
      { '<leader>ml', ':MoltenEvaluateLine<CR>', desc = '[M]olten evaluate [L]ine' },
      { '<leader>mr', ':MoltenReevaluateCell<CR>', desc = '[M]olten [R]e-eval cell' },
      { '<leader>mv', ':<C-u>MoltenEvaluateVisual<CR>gv', mode = 'v', desc = '[M]olten eval [V]isual' },
      { '<leader>mo', ':MoltenShowOutput<CR>', desc = '[M]olten show [O]utput' },
      { '<leader>md', ':MoltenDelete<CR>', desc = '[M]olten [D]elete cell' },
    },
  },
}
