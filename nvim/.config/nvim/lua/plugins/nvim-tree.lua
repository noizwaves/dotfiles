return {
  { "kyazdani42/nvim-web-devicons" },
  {
    "kyazdani42/nvim-tree.lua",
    dependencies = { "kyazdani42/nvim-web-devicons" },
    cmd = { "NvimTreeToggle", "NvimTreeFindFile" },
    keys = {
      { "<leader>nn", "<cmd>NvimTreeToggle<cr>", desc = "NvimTree: toggle" },
      { "<leader>nf", "<cmd>NvimTreeFindFile<cr>", desc = "NvimTree: find current file" },
    },
    opts = {
      renderer = {
        icons = {
          show = {
            git = false,
            folder = true,
            file = false,
            folder_arrow = true,
          },
        },
      },
    },
  },
}
