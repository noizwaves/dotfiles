return {
  {
    "tpope/vim-fugitive",
    dependencies = { "tpope/vim-rhubarb" },
    cmd = { "Git", "GBrowse" },
    keys = {
      { "<leader>gh", ":GBrowse<cr>", mode = { "n", "x" }, desc = "Git: browse on GitHub" },
    },
  },
  { "tpope/vim-rhubarb" },
}
