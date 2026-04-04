local augroup = vim.api.nvim_create_augroup
local autocmd = vim.api.nvim_create_autocmd

-- Auto-reload buffers when the underlying file changes on disk
autocmd({ "FocusGained", "BufEnter", "CursorHold", "CursorHoldI" }, {
  group = augroup("autoreload", { clear = true }),
  command = "checktime",
})

-- Enable spellcheck for markdown files and git commit messages
local spell_group = augroup("spell", { clear = true })
autocmd({ "BufRead", "BufNewFile" }, {
  group = spell_group,
  pattern = "*.md",
  callback = function() vim.opt_local.spell = true end,
})
autocmd("FileType", {
  group = spell_group,
  pattern = "gitcommit",
  callback = function() vim.opt_local.spell = true end,
})
