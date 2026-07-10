-- neotest: run & debug tests from inside the editor (Go adapter)
-- Reuses leoluz/nvim-dap-go already configured in kickstart/plugins/debug.lua
return {
  'nvim-neotest/neotest',
  dependencies = {
    'nvim-neotest/nvim-nio',
    'nvim-lua/plenary.nvim',
    'antoinemadec/FixCursorHold.nvim',
    'nvim-treesitter/nvim-treesitter',
    'fredrikaverpil/neotest-golang',
  },
  ft = { 'go' },
  config = function()
    require('neotest').setup {
      adapters = {
        require('neotest-golang')({
          dap_go_enabled = true, -- use nvim-dap-go for debugging tests
        }),
      },
    }
  end,
  keys = {
    {
      '<leader>tt',
      function()
        require('neotest').run.run()
      end,
      desc = '[T]est nearest',
    },
    {
      '<leader>tf',
      function()
        require('neotest').run.run(vim.fn.expand '%')
      end,
      desc = '[T]est [F]ile',
    },
    {
      '<leader>td',
      function()
        require('neotest').run.run { strategy = 'dap' }
      end,
      desc = '[T]est [D]ebug nearest',
    },
    {
      '<leader>ts',
      function()
        require('neotest').summary.toggle()
      end,
      desc = '[T]est [S]ummary',
    },
    {
      '<leader>to',
      function()
        require('neotest').output.open { enter = true }
      end,
      desc = '[T]est [O]utput',
    },
    {
      '<leader>tO',
      function()
        require('neotest').output_panel.toggle()
      end,
      desc = '[T]est [O]utput panel',
    },
  },
}
