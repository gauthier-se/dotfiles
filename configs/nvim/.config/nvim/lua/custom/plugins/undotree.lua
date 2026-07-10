-- undotree: visualize and navigate the undo history tree (mbbill)
return {
  'mbbill/undotree',
  cmd = { 'UndotreeToggle', 'UndotreeShow', 'UndotreeFocus' },
  keys = {
    { '<leader>u', '<cmd>UndotreeToggle<cr>', desc = '[U]ndotree toggle' },
  },
}
