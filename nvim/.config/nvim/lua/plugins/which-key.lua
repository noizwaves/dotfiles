return {
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = {
      preset = "modern",
      delay = 300,
      spec = {
        { "<leader>o", group = "open/files" },
        { "<leader>f", group = "find/search" },
        { "<leader>g", group = "git" },
        { "<leader>c", group = "copy" },
        { "<leader>n", group = "nvim-tree" },
        { "<leader>a", group = "AI/Claude" },
      },
    },
  },
}
