return {
  {
    "junegunn/fzf",
    build = ":call fzf#install()",
    init = function()
      vim.g.fzf_command_prefix = "Fzf"
      vim.g.fzf_preview_window = { "right:50%:hidden", "ctrl-/" }
      -- Set border to white; default ignore colours look bad against dracula
      vim.g.fzf_colors = {
        fg = { "fg", "Normal" },
        bg = { "bg", "Normal" },
        hl = { "fg", "Search" },
        ["fg+"] = { "fg", "Normal" },
        ["bg+"] = { "bg", "Normal" },
        ["hl+"] = { "fg", "DraculaOrange" },
        info = { "fg", "DraculaPurple" },
        border = { "fg", "Normal" },
        prompt = { "fg", "DraculaGreen" },
        pointer = { "fg", "Exception" },
        marker = { "fg", "Keyword" },
        spinner = { "fg", "Label" },
        header = { "fg", "Comment" },
      }
    end,
  },
  {
    "junegunn/fzf.vim",
    dependencies = { "junegunn/fzf" },
    keys = {
      { "<leader>o", "<cmd>FzfGFiles!<cr>" },
    },
  },
}
