return {
  { -- Highlight, edit, and navigate code
    -- nvim-treesitter v1.0: highlighting is native in neovim 0.11+.
    -- To install extra parsers: :TSInstall <lang> (requires tree-sitter CLI)
    'nvim-treesitter/nvim-treesitter',
    branch = 'main',
    build = ':TSUpdate',
  },
}
