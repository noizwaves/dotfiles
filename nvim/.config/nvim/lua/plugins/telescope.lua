return {
  {
    "nvim-telescope/telescope.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    cmd = "Telescope",
    keys = {
      { "<leader><S-o>", "<cmd>Telescope find_files<cr>" },
      { "<leader>b", "<cmd>Telescope buffers<cr>" },
      { "<leader>i", "<cmd>Telescope treesitter<cr>" },
      { "<leader>f", "<cmd>Telescope live_grep<cr>" },
      { "<leader>F", "<cmd>Telescope grep_string<cr>" },
      { "<leader>u", "<cmd>Telescope lsp_workspace_symbols<cr>" },
    },
    config = function()
      require("telescope").setup({
        pickers = {
          find_files = {
            find_command = { "rg", "--files", "--hidden", "-g", "!.git" },
          },
          live_grep = {
            additional_args = function() return { "--hidden", "-g", "!.git" } end,
          },
          grep_string = {
            additional_args = function() return { "--hidden", "-g", "!.git" } end,
          },
        },
        defaults = {
          layout_config = {
            width = { padding = 0 },
            height = { padding = 0 },
          },
          preview = {
            hide_on_startup = true,
          },
          mappings = {
            n = {
              ["p"] = require("telescope.actions.layout").toggle_preview,
            },
          },
        },
      })

      -- :FindInFolder <path> runs live_grep scoped to a directory
      vim.api.nvim_create_user_command("FindInFolder", function(opts)
        require("telescope.builtin").live_grep({ search_dirs = { opts.args } })
      end, { nargs = 1, complete = "file" })
    end,
  },
}
