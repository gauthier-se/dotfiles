return {
  { -- Fast file marks / jump list (ThePrimeagen)
    'ThePrimeagen/harpoon',
    branch = 'harpoon2',
    dependencies = { 'nvim-lua/plenary.nvim' },
    config = function()
      require('harpoon'):setup()
    end,
    keys = {
      { '<leader>a', function() require('harpoon'):list():add() end, desc = 'Harpoon [A]dd file' },
      {
        '<C-e>',
        function()
          local harpoon = require 'harpoon'
          harpoon.ui:toggle_quick_menu(harpoon:list())
        end,
        desc = 'Harpoon menu',
      },
      -- AZERTY: unshifted chars on the 1/2/3/4 keys (no Shift needed)
      { '<leader>&', function() require('harpoon'):list():select(1) end, desc = 'Harpoon file 1' },
      { '<leader>é', function() require('harpoon'):list():select(2) end, desc = 'Harpoon file 2' },
      { '<leader>"', function() require('harpoon'):list():select(3) end, desc = 'Harpoon file 3' },
      { "<leader>'", function() require('harpoon'):list():select(4) end, desc = 'Harpoon file 4' },
      { '<C-S-p>', function() require('harpoon'):list():prev() end, desc = 'Harpoon previous' },
      { '<C-S-n>', function() require('harpoon'):list():next() end, desc = 'Harpoon next' },
    },
  },
}
