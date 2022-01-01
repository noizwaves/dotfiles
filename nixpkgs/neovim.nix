{ pkgs, lib, ... }:
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
in {
  programs.neovim = {
    enable = true;
    package = neovim-0_6_0;
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
      editorconfig-vim

      nvim-treesitter

      plenary-nvim
      nvim-web-devicons
      telescope-nvim
      telescope-fzf-native-nvim

      dracula-vim

      vim-gitgutter

      airline
      vim-devicons

      nerdtree

      (pluginLatest "code-biscuits/nvim-biscuits")

      (pluginLatest "ThePrimeagen/vim-be-good")

      vim-smoothie

      nvim-lspconfig

      (pluginLatest "hrsh7th/cmp-nvim-lsp")
      (pluginLatest "hrsh7th/cmp-buffer")
      (pluginLatest "hrsh7th/cmp-path")
      (pluginLatest "hrsh7th/cmp-cmdline")
      (pluginLatest "hrsh7th/nvim-cmp")
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

    let g:dracula_colorterm = 0
    colorscheme dracula

    nnoremap <silent> <C-f> :silent !tmux neww tmux-sessionizer<cr>

    let mapleader = " "

    nnoremap <leader>rc :source $MYVIMRC<cr>

    nnoremap <leader>o <cmd>Telescope find_files<cr>
    nnoremap <leader>i <cmd>Telescope treesitter<cr>
    nnoremap <leader>f <cmd>Telescope live_grep<cr>
    nnoremap <leader>u <cmd>Telescope lsp_workspace_symbols<cr>

    nnoremap <leader>nn :NERDTreeFocus<cr>
    nnoremap <leader>nh :NERDTreeToggle<cr>
    nnoremap <leader>ng :NERDTreeFind<cr>

    " Ctrl+/ to toggle search highlighting
    nnoremap <C-_> <cmd>set invhlsearch<cr>

    " configure treesitter
    lua <<EOF
    '' +
    (if pkgs.stdenv.isDarwin then macosCppCompilerFix else "") +
    ''
    require'nvim-treesitter.configs'.setup {
      ensure_installed = "maintained",

      highlight = {
        enable = true,
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
          find_command = { 'rg', '--files', '--hidden', '--no-ignore', '-g', '!.git', '-g', '!node_modules', '-g', '!vendor' }
        },
        live_grep = {
          additional_args = function () return { '--hidden', '--no-ignore', '-g', '!.git', '-g', '!node_modules', '-g', '!vendor' } end
        }
      }
    }

    require('telescope').load_extension('fzf')
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
        { name = 'buffer' },
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
      local function buf_set_option(...) vim.api.nvim_buf_set_option(bufnr, ...) end

      local opts = { noremap=true, silent=true }

      -- LSP keymaps, `:help vim.lsp.*`
      buf_set_keymap('n', '<leader>d', '<cmd>lua vim.lsp.buf.definition()<cr>', opts)
      buf_set_keymap('n', '<leader>r', '<cmd>lua vim.lsp.buf.rename()<cr>', opts)
      buf_set_keymap('n', '<leader>h', '<cmd>lua vim.lsp.buf.hover()<cr>', opts)
      buf_set_keymap('n', '<leader>f', '<cmd>lua vim.lsp.buf.formatting()<cr>', opts)
      buf_set_keymap('n', '<leader>j', '<cmd>lua vim.lsp.buf.code_action()<cr>', opts)
    end

    local capabilities = require('cmp_nvim_lsp').update_capabilities(vim.lsp.protocol.make_client_capabilities())

    require('lspconfig').rnix.setup {
      on_attach = on_attach,
      capabilities = capabilities,
    }
    EOF
    '';
  };
}
