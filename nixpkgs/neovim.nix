{ config, pkgs, lib, ... }:
let
  # installs a vim plugin from git with a given tag / branch
  pluginRev = ref: repo: pkgs.vimUtils.buildVimPluginFrom2Nix {
    pname = "${lib.strings.sanitizeDerivationName repo}";
    version = ref;
    src = builtins.fetchGit {
      url = "https://github.com/${repo}.git";
      ref = ref;
    };
  };

  # always installs latest version
  pluginLatest = pluginRev "HEAD";

  # ensure parsers are compiled with CPP-comparible compiler on macOS
  # from https://github.com/nvim-treesitter/nvim-treesitter/issues/1449#issuecomment-870479095
  macosCppCompilerFix = "require'nvim-treesitter.install'.compilers = { 'clang++' }\n";

  symlinkTo = config.lib.file.mkOutOfStoreSymlink;

  # latest stable neovim
  # neovim-unwrapped because https://discourse.nixos.org/t/help-needed-neovim-completions-fail-to-build/14223/3
  neovim-0_6_0 = pkgs.neovim-unwrapped.overrideAttrs (oldAttrs: {
    version = "0.6.0";
    src = pkgs.fetchFromGitHub {
      owner = "neovim";
      repo = "neovim";
      rev = "v0.6.0";
      sha256 = "sha256-mVVZiDjAsAs4PgC8lHf0Ro1uKJ4OKonoPtF59eUd888=";
    };
  });

  use_nightly = true;
in {
  nixpkgs.overlays = [
    (import (builtins.fetchTarball {
      url = https://github.com/nix-community/neovim-nightly-overlay/archive/master.tar.gz;
    }))
  ];

  home.file.".config/nvim/spell".source = symlinkTo ./modules/neovim/spell;

  programs.neovim = {
    enable = true;
    package = if use_nightly then pkgs.neovim-nightly else neovim-0_6_0;
    vimAlias = true;

    extraPackages = with pkgs; [
      # for telescope
      ripgrep
      fd

      # for nvim-treesitter
      gcc
      tree-sitter

      # for LSP
      rnix-lsp
    ];

    # see all plugins in repl using `builtins.attrNames pkgs.vimPlugins`
    plugins = with pkgs.vimPlugins; [
      (pluginLatest "editorconfig/editorconfig-vim")

      nvim-treesitter
      nvim-treesitter-refactor
      playground

      (pluginLatest "nvim-lua/plenary.nvim")
      (pluginLatest "nvim-telescope/telescope.nvim")

      (pluginLatest "junegunn/fzf")
      (pluginLatest "junegunn/fzf.vim")

      (pluginLatest "dracula/vim")

      (pluginLatest "lewis6991/gitsigns.nvim")

      (pluginLatest "vim-airline/vim-airline")
      vim-devicons

      (pluginLatest "kyazdani42/nvim-web-devicons")
      (pluginLatest "kyazdani42/nvim-tree.lua")

      (pluginLatest "code-biscuits/nvim-biscuits")

      (pluginLatest "ThePrimeagen/vim-be-good")

      (pluginLatest "psliwka/vim-smoothie")

      vim-helm

      (pluginLatest "neovim/nvim-lspconfig")

      (pluginLatest "hrsh7th/cmp-nvim-lsp")
      (pluginLatest "hrsh7th/cmp-buffer")
      (pluginLatest "hrsh7th/cmp-path")
      (pluginLatest "hrsh7th/cmp-cmdline")
      (pluginLatest "hrsh7th/nvim-cmp")
      (pluginLatest "ray-x/cmp-treesitter")

      (pluginLatest "jose-elias-alvarez/null-ls.nvim")
      (pluginLatest "folke/trouble.nvim")
    ];

    extraConfig = ''
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

    nnoremap <leader>nn :NvimTreeFocus<cr>
    nnoremap <leader>ng :NvimTreeFindFile<cr>

    " Ctrl+/ to toggle search highlighting
    nnoremap <C-_> <cmd>set invhlsearch<cr>

    nnoremap <leader>s <cmd>set spell!<cr>

    " configure treesitter
    lua <<EOF
    '' +
    (if pkgs.stdenv.isDarwin then macosCppCompilerFix else "") +
    ''
    require'nvim-treesitter.configs'.setup {
      ensure_installed = { "ruby", "typescript", "json", "yaml", "javascript", "bash", "python", "nix" },
      highlight = {
        enable = true,
      },
      indent = {
        enable = true,
        disable = { "yaml" },
      },
      refactor = {
        smart_rename = {
          enable = true,
          keymaps = {
            smart_rename = "<leader>rt",
          },
        },
      },
    }
    EOF

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
      }
    }

    -- run `:lua find_in_folder 'some/path'` to find in a folder
    function find_in_folder(path)
      require('telescope.builtin').live_grep({search_dirs = {path}})
    end
    EOF

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
        { name = 'treesitter' },
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

    -- Setup lspconfig
    local on_attach = function(client, bufnr)
      local function buf_set_keymap(...) vim.api.nvim_buf_set_keymap(bufnr, ...) end

      local opts = { noremap=true, silent=true }

      -- LSP keymaps, `:help vim.lsp.*`
      buf_set_keymap('n', '<leader>d', '<cmd>lua vim.lsp.buf.definition()<cr>', opts)
      buf_set_keymap('n', '<leader>rr', '<cmd>lua vim.lsp.buf.rename()<cr>', opts)
      buf_set_keymap('n', '<leader>h', '<cmd>lua vim.lsp.buf.hover()<cr>', opts)
      buf_set_keymap('n', '<leader>j', '<cmd>lua vim.lsp.buf.code_action()<cr>', opts)
    end

    local capabilities = require('cmp_nvim_lsp').update_capabilities(vim.lsp.protocol.make_client_capabilities())

    require('lspconfig').rnix.setup { on_attach = on_attach, capabilities = capabilities }
    if (os.getenv('NEOVIM_LSP_SORBET') == 'true') then
      local sorbet_cmd = { 'env', 'SRB_SKIP_GEM_RBIS=1', 'bin/srb', 'typecheck', '--lsp' }
      if (os.getenv('NEOVIM_DEVSPACE') == 'true') then
        sorbet_cmd = { 'devspace', 'run', 'sorbet-typecheck-lsp' }
      end
      require('lspconfig').sorbet.setup { cmd = sorbet_cmd, on_attach = on_attach, capabilities = capabilities }
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

    lua << EOF
    require("null-ls").setup({
      sources = {
        require("null-ls").builtins.diagnostics.vale,
      },
    })
    EOF
    '';
  };
}
