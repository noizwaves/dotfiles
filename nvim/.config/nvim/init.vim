call plug#begin()
Plug 'editorconfig/editorconfig-vim'

Plug 'nvim-treesitter/nvim-treesitter'

Plug 'nvim-lua/plenary.nvim'
Plug 'nvim-telescope/telescope.nvim'

Plug 'junegunn/fzf'
Plug 'junegunn/fzf.vim'

Plug 'dracula/vim'

Plug 'lewis6991/gitsigns.nvim'

Plug 'vim-airline/vim-airline'
Plug 'ryanoasis/vim-devicons'

Plug 'kyazdani42/nvim-web-devicons'
Plug 'kyazdani42/nvim-tree.lua'

Plug 'code-biscuits/nvim-biscuits'

Plug 'ThePrimeagen/vim-be-good'

Plug 'psliwka/vim-smoothie'

Plug 'towolf/vim-helm'

Plug 'neovim/nvim-lspconfig'

Plug 'hrsh7th/cmp-nvim-lsp'
Plug 'hrsh7th/cmp-buffer'
Plug 'hrsh7th/cmp-path'
Plug 'hrsh7th/cmp-cmdline'
Plug 'hrsh7th/nvim-cmp'
" Plug 'ray-x/cmp-treesitter' " removed: incompatible with nvim-treesitter rewrite

" Plug 'jose-elias-alvarez/null-ls.nvim'
Plug 'folke/trouble.nvim'

Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-rhubarb'
call plug#end()

set runtimepath^=/nix/store/h74kmi4j27i8fsg9y9kgfwmyvc17gh86-vim-pack-dir

set number
set relativenumber
set cursorline
set cursorlineopt=number

set hidden

set incsearch
"set nohlsearch

set list
set listchars=trail:•

set scrolloff=4
set signcolumn=yes

set completeopt=menu,menuone,noselect

set spelllang=en_us
set spellsuggest=best,9
augroup spell
  autocmd!

  au BufRead,BufNewFile *.md setlocal spell
  au FileType gitcommit setlocal spell
augroup END

let g:dracula_colorterm = 0
colorscheme dracula

let g:fzf_command_prefix = 'Fzf'
" Set border to white, ignore looks bad
let g:fzf_colors = {
  \ 'fg':      ['fg', 'Normal'],
  \ 'bg':      ['bg', 'Normal'],
  \ 'hl':      ['fg', 'Search'],
  \ 'fg+':     ['fg', 'Normal'],
  \ 'bg+':     ['bg', 'Normal'],
  \ 'hl+':     ['fg', 'DraculaOrange'],
  \ 'info':    ['fg', 'DraculaPurple'],
  \ 'border':  ['fg', 'Normal'],
  \ 'prompt':  ['fg', 'DraculaGreen'],
  \ 'pointer': ['fg', 'Exception'],
  \ 'marker':  ['fg', 'Keyword'],
  \ 'spinner': ['fg', 'Label'],
  \ 'header':  ['fg', 'Comment'],
  \}

nnoremap <silent> <C-f> :silent !tmux neww tmux-sessionizer<cr>

let mapleader = " "

nnoremap <leader>c :source $MYVIMRC<cr>

nnoremap <S-h> <cmd>bprev<cr>
nnoremap <S-l> <cmd>bnext<cr>
nnoremap <S-w> <cmd>bprev <bar>bdelete #<cr>

" nnoremap <leader>o <cmd>Telescope find_files<cr>
nnoremap <leader><S-o> <cmd>Telescope find_files<cr>
nnoremap <leader>o <cmd>FzfGFiles!<cr>
nnoremap <leader>i <cmd>Telescope treesitter<cr>
nnoremap <leader>f <cmd>Telescope live_grep<cr>
nnoremap <leader>u <cmd>Telescope lsp_workspace_symbols<cr>

nnoremap <leader>e :NvimTreeToggle<cr>
nnoremap <leader>nn :NvimTreeFocus<cr>
nnoremap <leader>ng :NvimTreeFindFile<cr>

" Ctrl+/ to toggle search highlighting
nnoremap <C-_> <cmd>set invhlsearch<cr>

nnoremap <leader>s <cmd>set spell!<cr>

xnoremap <leader>g :GBrowse<cr>

" Treesitter highlight and indent are built-in in Nvim 0.11
" Use :TSInstall to add parsers, :InspectTree replaces playground

" configure airline
let g:airline#extensions#tabline#enabled = 1

lua <<EOF
require('nvim-biscuits').setup({
  toggle_keybind = "<leader>bb",
})
EOF

lua <<EOF
require('telescope').setup {
  pickers = {
    find_files = {
      find_command = { 'rg', '--files', '--hidden', '-g', '!.git' },
    },
    live_grep = {
      additional_args = function () return { '--hidden', '-g', '!.git' } end,
    },
  },
  defaults = {
    mappings = {
      n = {
        ["p"] = require("telescope.actions.layout").toggle_preview,
      },
    },
  },
}
EOF

" Implement find in folder
function s:find_in_folder(path)
  :call luaeval("require('telescope.builtin').live_grep({search_dirs = {_A[1]}})", [a:path])
endfunction

:command -nargs=1 -complete=file FindInFolder :call s:find_in_folder(<args>)

" configure LSP
lua <<EOF
-- Setup cmp
local cmp = require('cmp')

cmp.setup({
  mapping = {
    ['<cr>'] = cmp.mapping.confirm({ select = true }),
    ['<tab>'] = cmp.mapping(cmp.mapping.select_next_item(), { 'i', 'c' }),
    ['<S-tab>'] = cmp.mapping(cmp.mapping.select_prev_item(), { 'i', 'c' }),
  },
  sources = cmp.config.sources({
    { name = 'nvim_lsp' },
  }, {
    { name = 'buffer' },
  })
})

cmp.setup.filetype('markdown', {
  sources = cmp.config.sources({
    { name = 'nvim_lsp' },
  })
})

cmp.setup.cmdline(':', {
  sources = cmp.config.sources({
    { name = 'path' }
  }, {
    { name = 'cmdline' }
  })
})

-- LSP keymaps via LspAttach autocmd (replaces on_attach)
vim.api.nvim_create_autocmd('LspAttach', {
  callback = function(args)
    local opts = { noremap = true, silent = true, buffer = args.buf }
    vim.keymap.set('n', '<leader>d', vim.lsp.buf.definition, opts)
    vim.keymap.set('n', '<leader>rr', vim.lsp.buf.rename, opts)
    vim.keymap.set('n', '<leader>h', vim.lsp.buf.hover, opts)
    vim.keymap.set('n', '<leader>j', vim.lsp.buf.code_action, opts)
  end,
})

-- Set capabilities globally for all LSP servers
vim.lsp.config('*', {
  capabilities = require('cmp_nvim_lsp').default_capabilities(),
})

-- Enable LSP servers (configs provided by nvim-lspconfig in lsp/ directory)
vim.lsp.enable('rnix')

if os.getenv('NEOVIM_LSP_SORBET') == 'true' then
  local sorbet_cmd = { 'env', 'SRB_SKIP_GEM_RBIS=1', 'bin/srb', 'typecheck', '--lsp' }
  if os.getenv('NEOVIM_DEVSPACE') == 'true' then
    sorbet_cmd = { 'devspace', 'run', 'sorbet-typecheck-lsp' }
  end
  vim.lsp.config('sorbet', { cmd = sorbet_cmd })
  vim.lsp.enable('sorbet')
end
EOF

lua <<EOF
require('gitsigns').setup {}
EOF

lua <<EOF
require('nvim-tree').setup {
  renderer = {
    icons = {
      show = {
        git = false,
        folder = true,
        file = false,
        folder_arrow = true,
      },
    },
  },
}
EOF

" lua << EOF
" require("null-ls").setup({
"  sources = {
"     require("null-ls").builtins.diagnostics.vale,
"   },
" })
" EOF
