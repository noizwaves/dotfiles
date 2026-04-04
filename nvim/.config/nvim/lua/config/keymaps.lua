-- Non-plugin keymaps. Plugin-specific mappings live in their spec files.
local map = vim.keymap.set

map("n", "<C-f>", ":silent !tmux neww tmux-sessionizer<cr>", { silent = true })

map("n", "<leader>c", ":source $MYVIMRC<cr>")

map("n", "<S-h>", "<cmd>bprev<cr>")
map("n", "<S-l>", "<cmd>bnext<cr>")
map("n", "<S-w>", "<cmd>bprev <bar>bdelete #<cr>")

-- Ctrl+/ to toggle search highlighting
map("n", "<C-_>", "<cmd>set invhlsearch<cr>")

map("n", "<leader>s", "<cmd>set spell!<cr>")
