return {
  {
    "nvim-telescope/telescope.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    cmd = "Telescope",
    keys = {
      { "<leader>oa", "<cmd>Telescope find_files<cr>", desc = "Open: all files (incl. gitignored)" },
      { "<leader>ob", "<cmd>Telescope buffers<cr>", desc = "Open: buffer" },
      { "<leader>ff", "<cmd>Telescope live_grep<cr>", desc = "Find: live grep" },
      { "<leader>fw", "<cmd>Telescope grep_string<cr>", desc = "Find: word under cursor" },
      { "<leader>fs", "<cmd>Telescope lsp_workspace_symbols<cr>", desc = "Find: workspace symbols" },
      { "<leader>ft", "<cmd>Telescope treesitter<cr>", desc = "Find: treesitter nodes" },
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
