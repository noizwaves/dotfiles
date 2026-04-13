# Neovim Custom Keymap

## Basics

| Shortcut | Action |
|---|---|
| `Space` | Leader |
| `:` | Command prefix |
| `:R` | Reload config |

## Keymap Structure

Keymaps follow a `<leader>${plugin}${command}` pattern. Plugins/areas are:

- `c` — copy
- `o` — open/files
- `f` — find/search
- `g` — git/github
- `n` — nvim-tree

[which-key.nvim](https://github.com/folke/which-key.nvim) shows a popup after pressing `Space` + a plugin key to remind you of the available variations.

## File Navigation (`Space o`)

[fzf.vim](https://github.com/junegunn/fzf.vim) powers `Space oo`; [telescope.nvim](https://github.com/nvim-telescope/telescope.nvim) powers `Space oa` and `Space ob`.

| Shortcut | Action | Command |
|---|---|---|
| `Space oo` | Open git-tracked file | `:FzfGFiles!` |
| `Space oa` | Open any file (incl. gitignored) | `:Telescope find_files` |
| `Space ob` | Open buffer | `:Telescope buffers` |
| `ctrl-/` | Toggle fzf preview pane | |

## Content Search (`Space f`)

Powered by [telescope.nvim](https://github.com/nvim-telescope/telescope.nvim). Toggle the telescope preview pane with `p` in normal mode.

| Shortcut | Action | Command |
|---|---|---|
| `Space ff` | Global find | `:Telescope live_grep` |
| | Global find in folder | `:FindInFolder <path>` |
| `Space fw` | Find word under cursor | `:Telescope grep_string` |
| `Space fs` | Find workspace symbol | `:Telescope lsp_workspace_symbols` |
| `Space ft` | Find treesitter node | `:Telescope treesitter` |

## File Tree (`Space n`)

[NvimTree](https://github.com/nvim-tree/nvim-tree.lua) provides tree-based file navigation.

| Shortcut | Action | Command |
|---|---|---|
| `Space nn` | Toggle file tree | `:NvimTreeToggle` |
| `Space nf` | Reveal current file in tree | `:NvimTreeFindFile` |
| `q` | Close the file tree | |
| | Open file by path | `:e <path>` |

## Copy (`Space c`)

| Shortcut | Action |
|---|---|
| `Space cc` | Copy relative file path |

## Buffer Navigation

| Shortcut | Action | Command |
|---|---|---|
| `shift-l` | Go to next buffer | `:bn` |
| `shift-h` | Go to previous buffer | `:bp` |
| `shift-w` | Close current buffer | `:bd` |

## Git / GitHub (`Space g`)

[vim-fugitive](https://github.com/tpope/vim-fugitive) provides Git and GitHub integration; [lazygit.nvim](https://github.com/kdheepak/lazygit.nvim) embeds lazygit.

| Shortcut | Action | Command |
|---|---|---|
| `Space gg` | Open LazyGit | `:LazyGit` |
| `Space gh` | Open lines in GitHub (visual line mode) | `:GBrowse` |
| | Show blame information | `:Git blame` |

## Plugin Management

[lazy.nvim](https://lazy.folke.io/) manages plugins.

| Shortcut | Action |
|---|---|
| `:Lazy` | Launch plugin manager UI |

## QoL

Biscuits provides closing tag information for blocks.

| Shortcut | Action |
|---|---|
| `:BiscuitsToggle` | Toggle biscuits visibility |
