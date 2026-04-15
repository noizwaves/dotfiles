-- Non-plugin keymaps. Plugin-specific mappings live in their spec files.
local map = vim.keymap.set

map("n", "<C-f>", ":silent !tmux neww tmux-sessionizer<cr>", { silent = true })

vim.api.nvim_create_user_command("R", "source $MYVIMRC", {})

-- Copy relative file path to system clipboard
map("n", "<leader>cc", function()
  local path = vim.fn.expand("%")
  vim.fn.setreg("+", path)
  vim.notify("Copied: " .. path)
end, { desc = "Relative file path" })

map("n", "<S-h>", "<cmd>bprev<cr>")
map("n", "<S-l>", "<cmd>bnext<cr>")
map("n", "<S-w>", function()
  if #vim.fn.getbufinfo({ buflisted = 1 }) == 1 then
    vim.cmd("bdelete")
  else
    vim.cmd("bprev | bdelete #")
  end
end)

-- Ctrl+/ to toggle search highlighting
map("n", "<C-_>", "<cmd>set invhlsearch<cr>")

map("n", "<leader>s", "<cmd>set spell!<cr>")
