return {
  {
    "vim-airline/vim-airline",
    lazy = false,
    dependencies = { "vim-airline/vim-airline-themes" },
    init = function()
      vim.g["airline#extensions#tabline#enabled"] = 1
      vim.g.airline_theme = "night_owl"
    end,
  },
  { "ryanoasis/vim-devicons" },
}
