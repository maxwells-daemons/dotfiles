-- init.lua: configuration for Neovim.
-- Extends default vimrc, which sets basic options and mappings.

-- Load initial config from vimrc
vim.cmd 'source ~/.vim/vimrc'

-- Basic settings specific to nvim
vim.opt.foldcolumn = '1' -- Always display foldcolumn to avoid jitter on folding
vim.opt.signcolumn = 'yes' -- Always display signcolumn to avoid jitter on LSP diagnostics
vim.opt.mouse = 'a' -- Enable mouse interaction

-- When hovering over a line with diagnostics, show them in a floating window
vim.cmd 'autocmd CursorHold * lua vim.diagnostic.open_float(nil, { scope = "line", focusable = false })'

--[[

TODO:
 - Orgmode
 - Mappings file
 - Copilot (once text flickering issue is fixed: https://github.com/ms-jpq/coq_nvim/issues/379)
 - DAP (once it's ready)
 - Consider removing:
   - lualine
   - nvim-web-devicons

--]]

-- Plugins: managed by Packer (to bootstrap: must first install manually git)
-- Each plugin's configuration is handled next to its installation.
-- NOTE: remember to `source $MYVIMRC | PackerCompile` after making changes!
require('packer').startup(function()
    ---- Packer: manages itself
    use 'wbthomason/packer.nvim'

    ---- Which-key: manages keybindings
    use {
        'folke/which-key.nvim',
        config = function()
            local wk = require('which-key')

            -- Readable names for custom text objects
            local objects = require('which-key.plugins.presets').objects
            objects['af'] = 'a function'
            objects['if'] = 'inner function'
            objects['ac'] = 'a comment'
            objects['ic'] = 'a comment'
            objects['aC'] = 'a class'
            objects['iC'] = 'inner class'
            objects['ai'] = 'a conditional'
            objects['ii'] = 'inner conditional'
            objects['al'] = 'a loop'
            objects['il'] = 'inner loop'
            objects['<cr>'] = 'scope node'
            objects['a<cr>'] = 'containing node'

            wk.setup {
                plugins = {registers = false},
                motions = {count = false},  -- Disable WhichKey for actions like "c3..."
            }

            -- Assign readable labels to default key maps
            wk.register({
                ['<C-_>'] = 'Clear highlighting',
                ['<C-h>'] = 'Window left',
                ['<C-j>'] = 'Window down',
                ['<C-k>'] = 'Window up',
                ['<C-l>'] = 'Window right',
                ['<A-h>'] = 'Buffer next',
                ['<A-l>'] = 'Buffer previous',
                ['/'] = 'Search next',
                ['?'] = 'Search previous',
                ['Y'] = 'Yank to end of line',
                ['.'] = 'Repeat',
                ['u'] = 'Undo',
                ['U'] = 'which_key_ignore',
                ['<C-r>'] = 'Redo',
                ['<C-Space>'] = 'Autocomplete',
            })
        end
    }

    ---- Editing
    use 'wellle/targets.vim' -- Advanced pair text objects

    use { -- Text objects for surroundings
        'tpope/vim-surround',
        requires = { 'tpope/vim-repeat' }
    }

    use { -- Operator for commenting/uncommenting
        'tpope/vim-commentary',
        after = 'which-key.nvim',
        config = function()
            local wk = require('which-key')
            wk.register({['<C-c>'] = {'<Plug>Commentary', 'Comment'}})
            wk.register({['<C-c><C-c>'] = {'<Plug>CommentaryLine', 'Comment line'}})
            wk.register({['<C-c>'] = {'<Plug>Commentary', 'Comment'}}, {mode = 'x'})
            wk.register({['<C-c>'] = {'<Plug>Commentary', 'Comment'}}, {mode = 'o'})
        end

    }

    use { -- Trim trailing whitespace
        'ntpeters/vim-better-whitespace',
        setup = function()
            vim.g.better_whitespace_enabled = 0 -- Don't highlight trailing whitespace
            vim.g.strip_whitespace_on_save = 1
            vim.g.strip_whitespace_confirm = 0
            vim.g.strip_only_modified_lines = 1 -- Can use :StripWhitespace to get the rest
        end
    }

    use { -- Autoformatting
        'sbdchd/neoformat',
        after = 'which-key.nvim',
        config = function()
            local wk = require('which-key')
            wk.register({Q = {':Neoformat<CR>', 'Format file'}}, {silent = false})
            wk.register({Q = {':Neoformat! &ft<CR>', 'Format lines'}}, {silent = false, mode='v'})

            -- Run both isort and black on Python files
            vim.g.neoformat_enabled_python = { 'isort', 'black' }
            vim.cmd('autocmd FileType python let b:neoformat_run_all_formatters = 1')
        end
    }

    use { -- Autocompletion
        'ms-jpq/coq_nvim',
        branch = 'coq', -- NOTE: on first use, do :COQdeps
        config = function()
            vim.g.coq_settings = {
                auto_start = 'shut-up', -- Autostart without welcome message
                ['keymap.jump_to_mark'] = '',
                ['clients.snippets.warn'] = {}, -- Disable warning about not loading default snippets
                ['display.pum.fast_close'] = false, -- Prevent flickering by keeping old suggestions open
            }
        end
    }

    ---- Git
    use { -- Git menu
        'tpope/vim-fugitive',
        after = 'which-key.nvim',
        config = function()
            require('which-key').register({
                ['<Leader>g'] = {
                    name = 'git',
                    g = {':Git<CR>', 'Menu'}
                }
            })
        end
    }

    use { -- Git gutter signs, hunk navigation, and staging
        'lewis6991/gitsigns.nvim',
        requires = {
            'nvim-lua/plenary.nvim',
            'tpope/vim-repeat'
        },
        after = 'which-key.nvim',
        config = function()
            require('gitsigns').setup({
                keymaps = {},
                -- This callback configures gitsigns when it attaches to a buffer
                on_attach = function(bufnr)
                    local wk = require('which-key')

                    wk.register({
                        n = {'<cmd>lua require\"gitsigns.actions\".next_hunk()<CR>', 'Next hunk'},
                        N = {'<cmd>lua require\"gitsigns.actions\".prev_hunk()<CR>', 'Previous hunk'},
                        s = {'<cmd>lua require"gitsigns".stage_hunk()<CR>', 'Stage hunk'},
                        S = {'<cmd>lua require"gitsigns".stage_buffer()<CR>', 'Stage everything'},
                        u = {'<cmd>lua require"gitsigns".undo_stage_hunk()<CR>', 'Undo staging'},
                        U = {'<cmd>lua require"gitsigns".reset_buffer_index()<CR>', 'Undo everything'},
                        r = {'<cmd>lua require"gitsigns".reset_hunk()<CR>', 'Reset hunk'},
                        R = {'<cmd>lua require"gitsigns".reset_buffer()<CR>', 'Reset everything'},
                        p = {'<cmd>lua require"gitsigns".preview_hunk()<CR>', 'Preview hunk'},
                    }, {buffer=bufnr, prefix='<Leader>g'})

                    wk.register({
                        s = {'<cmd>lua require"gitsigns".stage_hunk({vim.fn.line("."), vim.fn.line("v")})<CR>', 'Stage lines'},
                        r = {'<cmd>lua require"gitsigns".reset_hunk({vim.fn.line("."), vim.fn.line("v")})<CR>', 'Reset lines'},
                    }, {buffer=bufnr, prefix='<Leader>g', mode='v'})

                    wk.register(
                        {ag = {':<C-U>lua require"gitsigns.actions".select_hunk()<CR>', 'Git hunk'}},
                        {ig = {':<C-U>lua require"gitsigns.actions".select_hunk()<CR>', 'Git hunk'}},
                        {buffer=bufnr, mode='o'}
                    )
                    wk.register(
                        {ag = {':<C-U>lua require"gitsigns.actions".select_hunk()<CR>', 'Git hunk'}},
                        {ig = {':<C-U>lua require"gitsigns.actions".select_hunk()<CR>', 'Git hunk'}},
                        {buffer=bufnr, mode='x'}
                    )
                end
            })
        end
    }

    ---- Treesitter
    use {
        'nvim-treesitter/nvim-treesitter',  -- Parsers
        run = ':TSUpdate',
        config = function()
            require('nvim-treesitter.configs').setup {
                -- Make sure these parsers are installed, and install them if missing
                ensure_installed = {
                    'comment', 'bash', 'c', 'dockerfile', 'json', 'python', 'lua', 'vim', 'yaml'
                },
                -- Highlighting with TS
                highlight = {
                    enable = true,
                    -- Enables vim's builtin regex-based highlighting for indent/etc;
                    -- may have a performance penalty
                    additional_vim_regex_highlighting = true,
                },
                -- Expand/reduce visual selection by TD nodes: <C-j>/<C-k> (<C-l> for scope)
                incremental_selection = {
                    enable = true,
                    keymaps = {
                        node_incremental = "<C-k>",
                        node_decremental = "<C-j>",
                        scope_incremental = "<C-l>",
                    },
                },
                -- Text objects for particular types of syntax nodes
                textobjects = {
                    select = {
                        enable = true,
                        lookahead = true,
                        keymaps = {
                            ["af"] = "@function.outer",
                            ["if"] = "@function.inner",
                            ["ac"] = "@comment.outer",
                            ["ic"] = "@comment.outer",
                            ["aC"] = "@class.outer",
                            ["iC"] = "@class.inner",
                            ["ai"] = "@conditional.outer",
                            ["ii"] = "@conditional.inner",
                            ["al"] = "@loop.outer",
                            ["il"] = "@loop.inner",
                        }
                    }
                },
                -- "Smart" TS text objects
                textsubjects = {
                    enable = true,
                    keymaps = {
                        ["<cr>"] = 'textsubjects-smart', -- Local scope
                        ["a<cr>"] = 'textsubjects-container-outer', -- Local container
                    }
                },
            }
        end
    }
    use 'nvim-treesitter/nvim-treesitter-textobjects' -- Syntax-aware text objects
    use 'RRethy/nvim-treesitter-textsubjects' -- "Smart" treesitter text objects

    ---- Telescope
    use { -- Fuzzy finder
        'nvim-telescope/telescope.nvim',
        requires = { 'nvim-lua/plenary.nvim' },
        after = {'which-key.nvim', 'telescope-fzf-native.nvim'},
        config = function()
            require('telescope').load_extension('fzf')  -- Use native fzf sorter

            require('which-key').register({
                ['<Leader>f'] = {
                    name = 'find',
                    f = {"<cmd>lua require('telescope.builtin').find_files()<cr>", 'Files'},
                    g = {"<cmd>lua require('telescope.builtin').live_grep()<cr>", 'Grep'},
                    b = {"<cmd>lua require('telescope.builtin').buffers()<cr>", 'Buffers'},
                    ['/'] = {"<cmd>lua require('telescope.builtin').current_buffer_fuzzy_find()<cr>", 'Fuzzy search'},
                    r = {"<cmd>lua require('telescope.builtin').lsp_references()<cr>", 'References'},
                    s = {"<cmd>lua require('telescope.builtin').lsp_document_symbols()<cr>", 'Symbols in the buffer'},
                    S = {"<cmd>lua require('telescope.builtin').lsp_workspace_symbols()<cr>", 'Symbols in the workspace'},
                }
            })
        end
    }

    use { -- Fast sorter for Telescope
        'nvim-telescope/telescope-fzf-native.nvim',
        run = 'make'
    }

    ---- Language server
    use 'neovim/nvim-lspconfig' -- Builtin configs for common language servers
    use 'ray-x/lsp_signature.nvim' -- Display function signature helper
    use 'RRethy/vim-illuminate' -- Highlight matches for symbol under cursor
    use 'williamboman/nvim-lsp-installer' -- Installs LSPs locally
    -- LSP config finished after plugins block

    ---- Aesthetics
    use 'lukas-reineke/indent-blankline.nvim' -- Indent guides
    use 'kshenoy/vim-signature' -- Show marks in sign column

    use { -- Color scheme
        'sainnhe/sonokai',
        config = function()
            vim.cmd 'colorscheme sonokai'
        end
    }

    use { -- Icons for various things
        'kyazdani42/nvim-web-devicons',
        config = function()
            require('nvim-web-devicons').setup {}
        end
    }

    use { -- Status line
        'nvim-lualine/lualine.nvim',
        config = function()
            local lualine = require('lualine')
            local lualine_config = lualine.get_config()

            lualine_config.options = {
                theme = 'sonokai',
                section_separators = { left = '', right = ''},
                component_separators = { left = '', right = ''},
            }
            lualine_config.extensions = { 'quickfix', 'fugitive' }

            -- Fix diagnostic colors, which are broken in sonokai
            lualine_config.sections.lualine_b[3].diagnostics_color = {
                    error = { fg = '#fc5d7c' },
                    warn = { fg = '#e7c664' },
                    info = { fg = '#76cce0' },
                    hint = { fg = '#9ed072' },
            }
            lualine.setup(lualine_config)

            vim.opt.showmode = false  -- Lualine will show the mode for us
        end
    }

    ---- Misc
    use { -- Enable short CursorHold updatetime without writing swap too often
        'antoinemadec/FixCursorHold.nvim',
        setup = function()
            vim.g.cursorhold_updatetime = 100
        end
    }

    use { -- Make quickfix behavior more convenient
        'romainl/vim-qf',
        config = function()
            vim.cmd [[
            function! QFMappings()
                nmap <buffer> <A-h> <Plug>(qf_older)
                nmap <buffer> <A-l> <Plug>(qf_newer)
                nmap <buffer> {     <Plug>(qf_previous_file)
                nmap <buffer> }     <Plug>(qf_next_file)
            endfunction

            autocmd FileType qf call QFMappings()
            ]]
        end
    }
end)

---- Other mappings
local wk = require('which-key')
wk.register({
    ['<Leader>e'] = {
        name = 'errors',
        l = {'<cmd>lua vim.diagnostic.setloclist()<CR>', 'Errors into loclist'},
        q = {'<cmd>lua vim.diagnostic.setqflist()<CR>', 'Errors into quickfix list'},
        n = {'<cmd>lua vim.diagnostic.goto_next()<CR>', 'Next error'},
        N = {'<cmd>lua vim.diagnostic.goto_prev()<CR>', 'Previous error'},
    }
})
wk.register({
    ['<Leader>en'] = {'<cmd>lua vim.diagnostic.goto_next()<CR>', 'Next error'},
    ['<Leader>eN'] = {'<cmd>lua vim.diagnostic.goto_prev()<CR>', 'Previous error'},
}, {mode = 'o'})
wk.register({
    ['<Leader>en'] = {'<cmd>lua vim.diagnostic.goto_next()<CR>', 'Next error'},
    ['<Leader>eN'] = {'<cmd>lua vim.diagnostic.goto_prev()<CR>', 'Previous error'},
}, {mode = 'x'})

---- LSP setup
-- See: https://github.com/neovim/nvim-lspconfig

-- Setup function which runs when we connect to a language server
local on_lsp_attach = function(client, bufnr)
    -- Attach illuminate and lsp_signature
    require('illuminate').on_attach(client)
    require('lsp_signature').on_attach({
        bind = true,
        hi_parameter = 'Search',
        floating_window = false,  -- Trigger manually with <C-s>
        hint_enable = false,
    })

    --Assign LSP-specific keybindings
    local wk = require('which-key')
    wk.register({
        K = {'<cmd>lua vim.lsp.buf.hover()<CR>', 'Get symbol info'},
        gd = {'<cmd>lua vim.lsp.buf.definition()<CR>', 'Go to definition'},
        gD = {'<cmd>lua vim.lsp.buf.declaration()<CR>', 'Go to declaration'},
        gi = {'<cmd>lua vim.lsp.buf.implementation()<CR>', 'Go to implementation'},
        gt = {'<cmd>lua vim.lsp.buf.type_definition()<CR>', 'Go to type definition'},
        gr = {'<cmd>lua vim.lsp.buf.references()<CR>', 'Get references in quickfix'},
        ['<Leader>r'] = {'<cmd>lua vim.lsp.buf.rename()<cr>', 'Rename symbol'},
        ['<Leader>a'] = {'<cmd>lua vim.lsp.buf.code_action()<CR>', 'Code action'},
        ['<Leader>w'] = {
            name = 'workspace',
            a = {'<cmd>lua vim.lsp.buf.add_workspace_folder()<CR>', 'Add workspace folder'},
            d = {'<cmd>lua vim.lsp.buf.remove_workspace_folder()<CR>', 'Delete workspace folder'},
            l = {'<cmd>lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))<CR>', 'List workspace folders'},
        }
    }, {buffer = bufnr})

    wk.register(
        {['<c-s>'] = {'<cmd>lua vim.lsp.buf.signature_help()<CR>', 'Display function signature'}},
        {buffer = bufnr, mode='i'}
    )
    wk.register(
        {['<c-s>'] = {'<cmd>lua vim.lsp.buf.signature_help()<CR>', 'Display function signature'}},
        {buffer = bufnr, mode='n'}
    )

    wk.register(
        {['<Leader>a'] = {'<cmd>lua vim.lsp.buf.range_code_action()<CR>', 'Code action'}},
        {buffer = bufnr, mode='v'}
    )
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

-- NOTE:
-- if using python with pyright and pyenv, activate the pyenv virtualenv
-- first, then use `pyenv pyright` to generate the pyright config
