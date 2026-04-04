return {
  {
    "tpope/vim-fugitive",
    dependencies = { "tpope/vim-rhubarb" },
    cmd = { "Git", "GBrowse" },
    keys = {
      { "<leader>g", ":GBrowse<cr>", mode = "x" },
      {
        "<leader>l",
        ":<C-u>execute \"Git log -L \" . line(\"'<\") . \",\" . line(\"'>\") . \":%\"<cr>",
        mode = "x",
      },
    },
  },
  { "tpope/vim-rhubarb" },
}
