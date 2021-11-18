-- init.lua: configuration for Neovim.
-- Extends default vimrc, which sets basic options and mappings.

--[[

Commands:
  - <C-/>: clear search highlight
  - <C-hjkl>: navigate splits
  - <S-hl>: cycle buffers
  - <Leader>r: rename
  - <Leader>a: code action
  - <Leader>e: see error
  - K: view LSP help (<Leader>k views signature help)
  - Q: autoformat
  - dm: delete mark

Motions:
  - gd/gD/gi/gr: go to definition / declaration / implementation / references
  - ge/gE: go to next/previous error
  - gh/gH: go to next/previous git hunk

Operators:
  - <C-c>: comment/uncomment (vim-commentary); <C-c><C-c> acts on current line

Text objects:
  - <CR>: "smart" TS query: comments, function calls/definitions, classes, loops, if statements, arguments
  - a<CR>: "smart" TS container: classes, functions, structs, methods
  - n (next) and l (last) pairs / quotes / separators / arguments
  - ia/aa: arguments
  - ih: git hunks

Completion:
  - <C-space>: manually trigger completion
  - <tab>/<S-tab>: navigate completions
  - <cr>: accept completion
  - <c-k>: bigger preview window
  - <c-n>: jump to next placeholder in snippet
  - <c-r>: accept copilot suggestion

Git:
  - <Leader>g: open git menu
  - <Leader>hs: stage hunk (line or cursor)
  - <Leader>hS: stage whole buffer
  - <Leader>hu: undo staging hunk
  - <Leader>hU: undo all staging
  - <Leader>hr: reset hunk (line or cursor)
  - <Leader>hR: reset whole buffer
  - <Leader>hp: preview hunk

Telescope:
  - <Leader>ff: find file
  - <Leader>fg: grep multiple files
  - <Leader>fb: find buffer
  - <Leader>f/: find within this buffer
  - <Leader>fr: find references to symbol under cursor
  - <Leader>fs: find LSP symbols in this buffer
  - <Leader>fS: find LSP symbols in the workspace
  - <Leader>fd: find LSP diagnostics in this buffer
  - <Leader>fD: find LSP diagnostics in the workspace

--]]

-- Load initial config from vimrc
vim.cmd 'source ~/.vim/vimrc'

--[[

TODO:
 - Orgmode
 - Toggle quickfix
 - DAP

--]]

-- Plugins: managed by Packer (to bootstrap: must first install manually git)
require('packer').startup(function()
    -- Packer: manages itself
    use 'wbthomason/packer.nvim'

    -- Editing
    use {
        'tpope/vim-surround', -- Text objects for surroundings
        requires = { 'tpope/vim-repeat' }
    }
    use 'wellle/targets.vim' -- Advanced pair text objects
    use 'tpope/vim-commentary' -- Operator for commenting/uncommenting
    use 'RRethy/nvim-treesitter-textsubjects' -- Context-sensitive treesitter text objects
    use 'ntpeters/vim-better-whitespace' -- Trim trailing whitespace

    -- Aesthetics
    use 'sainnhe/sonokai' -- Color scheme
    use 'lukas-reineke/indent-blankline.nvim' -- Indent guides
    use 'RRethy/vim-illuminate' -- Highlight matches for symbol under cursor
    use 'kshenoy/vim-signature' -- Show marks in sign column

    -- Autoformatting (several advantages over LSP formatting)
    use 'sbdchd/neoformat'

    -- Autocompletion
    use {
        'ms-jpq/coq_nvim', -- Completion engine
        branch = 'coq' -- NOTE: on first use, do :COQdeps
    }
    use 'github/copilot.vim' -- Github Copilot; NOTE: on first use, do :Copilot setup
    use 'ms-jpq/coq.thirdparty' -- Integrate coq with copilot

    -- LSP
    use 'neovim/nvim-lspconfig' -- Builtin configs for common language servers
    use 'williamboman/nvim-lsp-installer' -- Installs LSPs locally
    use 'ray-x/lsp_signature.nvim' -- Show function signatures when typing a call

    -- Treesitter
    use {
        'nvim-treesitter/nvim-treesitter', -- Language parsers
        run = ':TSUpdate',
    }

    -- Git
    use 'tpope/vim-fugitive' -- Git menu
    use {
        'lewis6991/gitsigns.nvim', -- Git signs, hunk navigation, and staging
        requires = {
            'nvim-lua/plenary.nvim',
            'tpope/vim-repeat'
          }
    }

    -- Telescope
    use {
        'nvim-telescope/telescope.nvim', -- Fuzzy finder
        requires = { 'nvim-lua/plenary.nvim' }
    }
    use {
        'nvim-telescope/telescope-fzf-native.nvim', -- Fast sorter for Telescope
        run = 'make'
    }
end)

---- Mappings
local map = vim.api.nvim_set_keymap

-- Toggle commenting with <C-c>.
--  - <C-c> in normal mode starts a comment operator
--  - <C-c><C-c> or <C-c>c in normal mode comments one line
--  - <C-c> in visual mode or as an operator comments
map('n', '<C-c>', '<Plug>Commentary', { silent = true })
map('n', '<C-c><C-c>', '<Plug>CommentaryLine', { silent = true })
map('n', '<C-c>c', '<Plug>CommentaryLine', { silent = true })
map('x', '<C-c>', '<Plug>Commentary', { silent = true })
map('o', '<C-c>', '<Plug>Commentary', { silent = true })

-- Q runs autoformatting
map('n', 'Q', ':Neoformat<CR>', {})

-- <Leader>g opens fugitive status
map('n', '<Leader>g', ':Git<CR>', {})

-- gh / gH: go to next/previous hunk
map('n', 'gh', ']c', {})
map('n', 'gH', '[c', {})

-- Telescope mappings
map('n', '<Leader>ff', "<cmd>lua require('telescope.builtin').find_files()<cr>", {})
map('n', '<Leader>fg', "<cmd>lua require('telescope.builtin').live_grep()<cr>", {})
map('n', '<Leader>fb', "<cmd>lua require('telescope.builtin').buffers()<cr>", {})
map('n', '<Leader>f/', "<cmd>lua require('telescope.builtin').current_buffer_fuzzy_find()<cr>", {})
map('n', '<Leader>fr', "<cmd>lua require('telescope.builtin').lsp_references()<cr>", {})
map('n', '<Leader>fs', "<cmd>lua require('telescope.builtin').lsp_document_symbols()<cr>", {})
map('n', '<Leader>fS', "<cmd>lua require('telescope.builtin').lsp_workspace_symbols()<cr>", {})
map('n', '<Leader>fd', "<cmd>lua require('telescope.builtin').lsp_document_diagnostics()<cr>", {})
map('n', '<Leader>fD', "<cmd>lua require('telescope.builtin').lsp_workspace_diagnostics()<cr>", {})

---- Whitespace trimming
vim.g.better_whitespace_enabled = 0 -- Don't highlight trailing whitespace
vim.g.strip_whitespace_on_save = 1
vim.g.strip_whitespace_confirm = 0
vim.g.strip_only_modified_lines = 1 -- Can use :StripWhitespace to get the rest

---- Autoformatting
-- Run both isort and black on Python files
vim.g.neoformat_enabled_python = { 'isort', 'black' }
vim.cmd('autocmd FileType python let b:neoformat_run_all_formatters = 1')

---- Autocompletion
vim.g.coq_settings = {
    auto_start = 'shut-up', -- Autostart without welcome message
    ['keymap.jump_to_mark'] = '<c-n>',
    ['clients.snippets.warn'] = {}, -- Disable warning about not loading default snippets
    ['display.pum.fast_close'] = false, -- Prevent flickering by keeping old suggestions open
}

-- Note: this is a workaround; see https://github.com/ms-jpq/coq.thirdparty
require('coq_3p') {
    { src = "copilot", short_name = "COP", tmp_accept_key = "<c-r>" }
}

-- Prevent copilot from attempting completion in Telescope windows
vim.g.copilot_filetypes = {
    TelescopePrompt = false,
}

---- LSP
-- See: https://github.com/neovim/nvim-lspconfig

-- Once attached to language server, setup keymaps
local on_lsp_attach = function(client, bufnr)
    local function buf_set_keymap(mode, mapping, command)
        vim.api.nvim_buf_set_keymap(bufnr, mode, mapping, command, { noremap = true })
    end

    -- LSP mappings
    buf_set_keymap('n', '<Leader>r', '<cmd>lua vim.lsp.buf.rename()<cr>')
    buf_set_keymap('n', '<Leader>a', '<cmd>lua vim.lsp.buf.code_action()<CR>')
    buf_set_keymap('v', '<Leader>a', '<cmd>lua vim.lsp.buf.range_code_action()<CR>')
    buf_set_keymap('n', '<Leader>e', '<cmd>lua vim.lsp.diagnostic.show_line_diagnostics()<CR>')
    buf_set_keymap('n', 'K', '<cmd>lua vim.lsp.buf.hover()<CR>')
    buf_set_keymap('n', '<Leader>k', '<cmd>lua vim.lsp.buf.signature_help()<CR>')

    buf_set_keymap('n', 'gd', '<cmd>lua vim.lsp.buf.definition()<CR>')
    buf_set_keymap('n', 'gD', '<cmd>lua vim.lsp.buf.declaration()<CR>')
    buf_set_keymap('n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<CR>')
    buf_set_keymap('n', 'gr', '<cmd>lua vim.lsp.buf.references()<CR>')

    -- ge/gE: go to next/prev error
    buf_set_keymap('n', 'ge', '<cmd>lua vim.diagnostic.goto_next()<CR>')
    buf_set_keymap('x', 'ge', '<cmd>lua vim.diagnostic.goto_next()<CR>')
    buf_set_keymap('o', 'ge', '<cmd>lua vim.diagnostic.goto_next()<CR>')

    buf_set_keymap('n', 'gE', '<cmd>lua vim.diagnostic.goto_prev()<CR>')
    buf_set_keymap('x', 'gE', '<cmd>lua vim.diagnostic.goto_prev()<CR>')
    buf_set_keymap('o', 'gE', '<cmd>lua vim.diagnostic.goto_prev()<CR>')

    -- Setup lsp_signature
    require('lsp_signature').on_attach({
        bind = true,
        hint_prefix = 'Param ',
    })

    -- Setup vim-illuminate to highlight symbols under the cursor
    require('illuminate').on_attach(client)
end

-- For each language server installed with nvim-lsp-installer, configure
-- it through this callback and launch the server when appropriate.
require('nvim-lsp-installer').on_server_ready(function(server)
    local options = { on_attach = on_lsp_attach }

    -- Lua-specific configuration
    if server.name == 'sumneko_lua' then
        options.settings = {
            Lua = {
                diagnostics = {
                    -- Don't warn us about these missing globals in vim config
                    globals = { 'vim', 'use' }
                }
            }
        }
    end

    -- Enable LSP snippets for coq_nvim
    options = require('coq').lsp_ensure_capabilities(options)

    server:setup(options)
end)

-- NOTE: if using python with pyright and pyenv, activate the pyenv virtualenv
-- first, then use `pyenv pyright` to generate the pyright config

---- Treesitter and treesitter-textsubjects
require('nvim-treesitter.configs').setup {
    -- Make sure these parsers are installed, and install them if missing
    ensure_installed = {
        'bash', 'c', 'dockerfile', 'json', 'python', 'lua', 'vim', 'yaml'
    },
    -- Highlighting with TS
    highlight = {
        enable = true,
        -- Enables vim's builtin regex-based highlighting for indent/etc;
        -- may have a performance penalty
        additional_vim_regex_highlighting = true,
    },
    -- Context-sensitive TS text objects
    textsubjects = {
        enable = true,
        keymaps = {
            ["<cr>"] = 'textsubjects-smart', -- Local scope
            ["a<cr>"] = 'textsubjects-container-outer', -- Local container
        }
    },
}

---- gitsigns
require('gitsigns').setup()

---- Telescope
require('telescope').load_extension('fzf')

---- Aesthetics
vim.cmd 'colorscheme sonokai'
vim.opt.foldcolumn = '1' -- Always display foldcolumn to avoid jitter on folding
vim.opt.signcolumn = 'yes' -- Always display signcolumn to avoid jitter on LSP diagnostics

---- Misc
vim.opt.mouse = 'a' -- Enable mouse interaction
