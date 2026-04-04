return {
  {
    "neovim/nvim-lspconfig",
    dependencies = { "hrsh7th/cmp-nvim-lsp" },
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      -- LSP keymaps are attached per-buffer when a server attaches
      vim.api.nvim_create_autocmd("LspAttach", {
        callback = function(args)
          local opts = { noremap = true, silent = true, buffer = args.buf }
          vim.keymap.set("n", "<leader>d", vim.lsp.buf.definition, opts)
          vim.keymap.set("n", "<leader>rr", vim.lsp.buf.rename, opts)
          vim.keymap.set("n", "<leader>h", vim.lsp.buf.hover, opts)
          vim.keymap.set("n", "<leader>j", vim.lsp.buf.code_action, opts)
        end,
      })

      -- Set capabilities globally for all LSP servers
      vim.lsp.config("*", {
        capabilities = require("cmp_nvim_lsp").default_capabilities(),
      })

      -- Sorbet (Gusto work environments)
      if os.getenv("NEOVIM_LSP_SORBET") == "true" then
        local sorbet_cmd = { "env", "SRB_SKIP_GEM_RBIS=1", "bin/srb", "typecheck", "--lsp" }
        if os.getenv("NEOVIM_DEVSPACE") == "true" then
          sorbet_cmd = { "devspace", "run", "sorbet-typecheck-lsp" }
        end
        vim.lsp.config("sorbet", { cmd = sorbet_cmd })
        vim.lsp.enable("sorbet")
      end
    end,
  },
}
