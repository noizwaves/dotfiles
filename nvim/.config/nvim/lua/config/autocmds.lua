local augroup = vim.api.nvim_create_augroup
local autocmd = vim.api.nvim_create_autocmd

-- Auto-reload buffers when the underlying file changes on disk
autocmd({ "FocusGained", "BufEnter", "CursorHold", "CursorHoldI" }, {
  group = augroup("autoreload", { clear = true }),
  command = "checktime",
})

-- Enable spellcheck for git commit messages
autocmd("FileType", {
  group = augroup("spell", { clear = true }),
  pattern = "gitcommit",
  callback = function() vim.opt_local.spell = true end,
})
