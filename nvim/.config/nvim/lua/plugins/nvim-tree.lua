return {
  { "kyazdani42/nvim-web-devicons" },
  {
    "kyazdani42/nvim-tree.lua",
    dependencies = { "kyazdani42/nvim-web-devicons" },
    cmd = { "NvimTreeToggle", "NvimTreeFocus", "NvimTreeFindFile" },
    keys = {
      { "<leader>e", "<cmd>NvimTreeToggle<cr>" },
      { "<leader>nn", "<cmd>NvimTreeFocus<cr>" },
      { "<leader>ng", "<cmd>NvimTreeFindFile<cr>" },
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
