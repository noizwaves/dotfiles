return {
  {
    "hrsh7th/nvim-cmp",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "hrsh7th/cmp-cmdline",
    },
    event = { "InsertEnter", "CmdlineEnter" },
    config = function()
      local cmp = require("cmp")

      cmp.setup({
        mapping = {
          ["<cr>"] = cmp.mapping.confirm({ select = true }),
          ["<tab>"] = cmp.mapping(cmp.mapping.select_next_item(), { "i", "c" }),
          ["<S-tab>"] = cmp.mapping(cmp.mapping.select_prev_item(), { "i", "c" }),
        },
        sources = cmp.config.sources({
          { name = "nvim_lsp" },
        }, {
          { name = "buffer" },
        }),
      })

      cmp.setup.filetype("markdown", {
        sources = cmp.config.sources({
          { name = "nvim_lsp" },
        }),
      })

      cmp.setup.cmdline(":", {
        sources = cmp.config.sources({
          { name = "path" },
        }, {
          { name = "cmdline" },
        }),
      })
    end,
  },
}
