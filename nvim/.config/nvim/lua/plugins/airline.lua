return {
  {
    "vim-airline/vim-airline",
    lazy = false,
    init = function()
      vim.g["airline#extensions#tabline#enabled"] = 1
    end,
  },
  { "ryanoasis/vim-devicons" },
}
