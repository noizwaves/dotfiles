return {
  { "editorconfig/editorconfig-vim" },
  {
    "code-biscuits/nvim-biscuits",
    opts = {
      toggle_keybind = "<leader>bb",
    },
  },
  { "ThePrimeagen/vim-be-good", cmd = "VimBeGood" },
  { "psliwka/vim-smoothie" },
  { "towolf/vim-helm", ft = { "helm", "yaml" } },
  { "folke/trouble.nvim", cmd = "Trouble", opts = {} },
}
