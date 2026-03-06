return {
  "sindrets/diffview.nvim",
  dependencies = "nvim-lua/plenary.nvim",
  cmd = { "DiffviewOpen", "DiffviewClose" },
  keys = {
    { "<leader>gd", "<cmd>DiffviewOpen<CR>", desc = "Open Git Diffview" },
    { "<leader>gx", "<cmd>DiffviewClose<CR>", desc = "Close Git Diffview" },
  }
}
