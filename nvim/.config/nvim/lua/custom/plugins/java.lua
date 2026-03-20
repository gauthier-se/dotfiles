return {
  'nvim-java/nvim-java',
  dependencies = {
    'neovim/nvim-lspconfig',
  },
  config = function()
    require('java').setup()
    require('lspconfig').jdtls.setup({
      capabilities = require('blink.cmp').get_lsp_capabilities()
    })
  end,
}
