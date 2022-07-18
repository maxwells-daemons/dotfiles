-- init.lua: configuration for Neovim.
-- Extends default vimrc, which sets basic options and mappings.

-- Load initial config from vimrc
vim.cmd 'source ~/.vim/vimrc'

-- Basic settings specific to nvim
vim.opt.foldcolumn = '1' -- Always display foldcolumn to avoid jitter on folding
vim.opt.signcolumn = 'yes' -- Always display signcolumn to avoid jitter on LSP diagnostics

-- When hovering over a line with diagnostics, show them in a floating window
vim.cmd 'autocmd CursorHold * lua vim.diagnostic.open_float(nil, { scope = "line", focusable = false })'

--[[

TODO:
 - Setup DAP
 - Write plugin: undo tree viewer with Telescope
 - Tmux integration

--]]

-- Plugins: managed by [Packer](https://github.com/wbthomason/packer.nvim)
-- Each plugin's configuration is handled next to its installation.
-- NOTE: remember to `source $MYVIMRC | PackerCompile` after making changes!
-- NOTE: to bootstrap, install Packer manually, then `PackerSync`
require('packer').startup(function()
    ---- Packer: manages itself
    use 'wbthomason/packer.nvim'

    ---- Which-key: manages keybindings
    use {
        'folke/which-key.nvim',
        config = function()
            local wk = require('which-key')

            -- Readable names for treesitter-textobjects
            local objects = require('which-key.plugins.presets').objects
            objects['af'] = 'a function'
            objects['if'] = 'inner function'
            objects['ac'] = 'a comment'
            objects['ic'] = 'a comment'
            objects['aC'] = 'a Class'
            objects['iC'] = 'inner Class'
            objects['ai'] = 'a conditional'
            objects['ii'] = 'inner conditional'
            objects['al'] = 'a loop'
            objects['il'] = 'inner loop'

            wk.setup {
                motions = {count = false},  -- Disable WhichKey for actions like "c3..."
                plugins = {marks = false},  -- Don't show for marks due to flickering with ``
            }

            -- Motions: used in normal, visual, and operator-pending modes
            local motions = {
                ['['] = {
                    name = 'previous',
                    c = {"&diff ? '[c' : '<cmd>Gitsigns prev_hunk<CR>'", 'Previous change', expr = true},
                    d = {'<cmd>lua vim.diagnostic.goto_prev()<CR>', 'Previous diagnostic'},
                    l = {'<Plug>(qf_loc_previous)', 'Previous loclist'},
                    L = {':lfirst<CR>', 'First loclist'},
                    q = {'<Plug>(qf_qf_previous)', 'Previous quickfix'},
                    Q = {':cfirst<CR>', 'First quickfix'},
                },
                [']'] = {
                    name = 'next',
                    c = {"&diff ? ']c' : '<cmd>Gitsigns next_hunk<CR>'", 'Next change', expr = true},
                    d = {'<cmd>lua vim.diagnostic.goto_next()<CR>', 'Next diagnostic'},
                    l = {'<Plug>(qf_loc_next)', 'Next loclist'},
                    L = {':llast<CR>', 'Last loclist'},
                    q = {'<Plug>(qf_qf_next)', 'Next quickfix'},
                    Q = {':clast<CR>', 'Last quickfix'},
                },
            }
            wk.register(motions, { mode = 'n' })
            wk.register(motions, { mode = 'x' })
            wk.register(motions, { mode = 'o' })

            -- Text objects: used in visual and operator-pending modes
            local text_objects = {
                ag = {':<C-U>Gitsigns select_hunk<CR>', 'Git hunk'},
                ig = {':<C-U>Gitsigns select_hunk<CR>', 'Git hunk'},
            }
            wk.register(text_objects, { mode = 'x' })
            wk.register(text_objects, { mode = 'o' })

            -- Normal-mode mappings
            wk.register({
                -- UI
                ['<C-h>'] = 'Window left',
                ['<C-j>'] = 'Window down',
                ['<C-k>'] = 'Window up',
                ['<C-l>'] = 'Window right',
                ['<c-s>'] = {'<cmd>lua vim.lsp.buf.signature_help()<CR>', 'Display function signature'},
                K = {'<cmd>lua vim.lsp.buf.hover()<CR>', 'Get symbol info'},
                -- Jumps
                g = {
                    d = {'<cmd>lua vim.lsp.buf.definition()<CR>', 'Go to definition'},
                    D = {'<cmd>lua vim.lsp.buf.declaration()<CR>', 'Go to declaration'},
                    i = {'<cmd>lua vim.lsp.buf.implementation()<CR>', 'Go to implementation'},
                    t = {'<cmd>lua vim.lsp.buf.type_definition()<CR>', 'Go to type definition'},
                    r = {'<cmd>lua vim.lsp.buf.references()<CR>', 'Get references in quickfix'},
                },
                -- Actions
                Q = {'<cmd>lua vim.lsp.buf.formatting()<CR>', 'Format file'},

                ['<Leader>'] = {
                    -- UI
                    ['/'] = 'Clear highlighting',
                    q = {'<Plug>(qf_qf_toggle_stay)', 'Toggle quickfix'},
                    l = {'<Plug>(qf_loc_toggle_stay)', 'Toggle loclist'},
                    -- Editing
                    c = {'<Plug>Commentary', 'Comment'}, -- Operator
                    cc = {'<Plug>CommentaryLine', 'Comment line'},
                    -- LSP
                    r = {'<cmd>lua vim.lsp.buf.rename()<cr>', 'Rename symbol'},
                    a = {"<cmd>lua vim.lsp.buf.code_action()<CR>", 'Code action'},
                    d = {
                        name = 'diagnostics',
                        q = {'<cmd>lua vim.diagnostic.setqflist()<CR>', 'Workspace diagnostics in quickfix'},
                        l = {'<cmd>lua vim.diagnostic.setloclist()<CR>', 'Buffer diagnostics in loclist'},
                    },
                    -- Other groups
                    g = {
                        name = 'git',
                        g = {':Git<CR>', 'Menu'},
                        s = {'<cmd>Gitsigns stage_hunk<CR>', 'Stage hunk'},
                        S = {'<cmd>Gitsigns stage_buffer<CR>', 'Stage everything'},
                        u = {'<cmd>Gitsigns undo_stage_hunk<CR>', 'Undo staging'},
                        U = {'<cmd>Gitsigns reset_buffer_index<CR>', 'Undo all staging'},
                        r = {'<cmd>Gitsigns reset_hunk<CR>', 'Reset hunk'},
                        R = {'<cmd>Gitsigns reset_buffer<CR>', 'Reset everything'},
                        p = {'<cmd>Gitsigns preview_hunk<CR>', 'Preview hunk'},
                        b = {'<cmd>Gitsigns blame_line<CR>', 'View line blame'},
                        d = {'<cmd>Gitsigns toggle_deleted<CR>', 'Toggle deleted line view'},
                    },
                    f = {
                        name = 'find',
                        f = {"<cmd>lua require('telescope.builtin').find_files()<cr>", 'Files'},
                        g = {"<cmd>lua require('telescope.builtin').live_grep()<cr>", 'Grep'},
                        b = {"<cmd>lua require('telescope.builtin').buffers()<cr>", 'Buffers'},
                        r = {"<cmd>lua require('telescope.builtin').lsp_references()<cr>", 'References'},
                        s = {"<cmd>lua require('telescope.builtin').lsp_document_symbols()<cr>", 'Symbols in the buffer'},
                        S = {"<cmd>lua require('telescope.builtin').lsp_dynamic_workspace_symbols()<cr>", 'Symbols in the workspace'},
                        d = {"<cmd>lua require('telescope.builtin').diagnostics {bufnr=0}<cr>", 'Buffer diagnostics'},
                        D = {"<cmd>lua require('telescope.builtin').diagnostics()<cr>", 'Workspace diagnostics'},
                    },
                },
                -- Readable names for builtin mappings
                ['Y'] = 'Yank to end of line',
                ['/'] = 'Search forward',
                ['?'] = 'Search backward',
                ['m'] = 'Place mark',
                ['dm'] = 'Delete mark', -- From Signature
                -- Ignored mappings
                ['U'] = 'which_key_ignore',
                ['<C-Space>'] = 'which_key_ignore',
            })

            -- Visual mappings
            wk.register({
                Q = {'<cmd>lua vim.lsp.buf.range_formatting()<CR>', 'Format'},
                ['<Leader>a'] = {"<cmd>lua vim.lsp.buf.range_code_action()<CR>", 'Code action'},
                ['<Leader>c'] = {'<Plug>Commentary', 'Comment'},
                ['<Leader>gs'] = {':Gitsigns stage_hunk<CR>', 'Stage lines'},
                ['<Leader>gr'] = {':Gitsigns reset_hunk<CR>', 'Reset lines'},
            }, { mode = 'x' })

            -- Insert mode mappings
            wk.register({
                    ['<C-s>'] = {'<cmd>lua vim.lsp.buf.signature_help()<CR>', 'Display function signature'},
                }, {mode='i'}
            )
        end
    }

    ---- Editing
    use 'tpope/vim-commentary' -- Operator for commenting/uncommenting
    use 'wellle/targets.vim' -- Advanced pair text objects

    use { -- Text objects for surroundings
        'tpope/vim-surround',
        requires = { 'tpope/vim-repeat' }
    }

    use { -- Fast 2-character motion
        'ggandor/leap.nvim',
        requires = { 'tpope/vim-repeat' },
        config = function() require('leap').set_default_keymaps() end
    }

    ---- Autocompletion
    use {
        'ms-jpq/coq_nvim', branch = 'coq',
        setup = function()
            vim.g.coq_settings = {
                auto_start = 'shut-up',
                clients = { snippets = {warn = {}} }, -- Disable no-snippets warning
                keymap = { jump_to_mark = '' }, -- Disable jump-to-mark keybind
            }
        end
    }

    ---- Git
    use 'tpope/vim-fugitive' -- Git menu

    use { -- Git gutter signs, hunk navigation, and staging
        'lewis6991/gitsigns.nvim',
        requires = {
            'nvim-lua/plenary.nvim',
            'tpope/vim-repeat'
        },
        config = function() require('gitsigns').setup({ keymaps = {} }) end
    }

    ---- Treesitter
    use {
        'nvim-treesitter/nvim-treesitter',  -- Parsers
        run = ':TSUpdate',
        config = function()
            require('nvim-treesitter.configs').setup {
                -- Make sure these parsers are installed, and install them if missing
                ensure_installed = {
                    'comment', 'bash', 'c', 'dockerfile', 'json',
                    'python', 'lua', 'vim', 'yaml', 'rust'
                },
                -- Highlighting with TS
                highlight = {
                    enable = true,
                    -- Enables vim's builtin regex-based highlighting for indent/etc;
                    -- may have a performance penalty
                    additional_vim_regex_highlighting = true,
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
            }

            -- Treesitter folding
            vim.o.foldmethod = 'expr'
            vim.o.foldexpr = 'nvim_treesitter#foldexpr()'
            vim.o.foldlevel = 99 -- Open folds by default

            -- Pretty fold text substitution
            vim.o.foldtext = [[substitute(getline(v:foldstart),'\\t',repeat('\ ',&tabstop),'g').'...'.trim(getline(v:foldend))]]
        end
    }
    use 'nvim-treesitter/nvim-treesitter-textobjects' -- Syntax-aware text objects

    ---- Telescope
    use { -- Fuzzy finder
        'nvim-telescope/telescope.nvim',
        -- NOTE: depends on
        -- - [ripgrep](https://github.com/BurntSushi/ripgrep)
        -- - [fd](https://github.com/sharkdp/fd)
        requires = {
            'nvim-lua/plenary.nvim',
            'nvim-telescope/telescope-symbols.nvim' -- To use: :Telescope sybmbols
        },
        after = {'which-key.nvim', 'telescope-fzf-native.nvim'},
        config = function() require('telescope').load_extension('fzf') end
    }

    use { -- Fast sorter for Telescope
        'nvim-telescope/telescope-fzf-native.nvim',
        run = 'make'
    }

    ---- Language server
    use {
        'neovim/nvim-lspconfig',  -- Builtin configs for common language servers
        after = {'coq_nvim', 'vim-illuminate'},
        config = function()
            local lspconfig = require('lspconfig')
            local illuminate = require('illuminate')
            local coq = require('coq')

            -- When we connect to a language server, setup illuminate
            local on_lsp_attach = function(client, _)
                illuminate.on_attach(client)
            end

            local setup_lsp = function(server)
                local options = coq.lsp_ensure_capabilities({ on_attach = on_lsp_attach })
                server:setup(options)
            end

            -- Setup language-specific LSP servers
            -- NOTE: depends on:
            -- - [pyright](https://github.com/microsoft/pyright)
            -- - [rust-analyzer](https://rust-analyzer.github.io)
            setup_lsp(lspconfig.pyright)
            setup_lsp(lspconfig.rust_analyzer)
        end
    }

    use 'RRethy/vim-illuminate' -- Highlight matches for symbol under cursor

    use {
        'jose-elias-alvarez/null-ls.nvim', -- Register local capabilities with LSP interface
        -- NOTE: depends on
        -- - [isort](https://github.com/PyCQA/isort)
        -- - [black](https://github.com/psf/black)
        -- - [prettier](https://github.com/prettier/prettier)
        requires = { 'nvim-lua/plenary.nvim' },
        config = function()
            local null_ls = require('null-ls')
            null_ls.setup({ -- NOTE: not using common LSP on_attach
                sources = {
                    -- Formatting
                    null_ls.builtins.formatting.isort.with { -- Sort python imports
                        args = {"--stdout", "--profile", "black", "-"}
                    },
                    null_ls.builtins.formatting.black.with { -- Format python code
                        args = {"--quiet", "--fast", "-" }
                    },
                    null_ls.builtins.formatting.prettier.with { -- Multi-language formatter
                        filetypes = {
                            'html', 'css', 'scss', 'less', 'javascript',
                            'json', 'yaml', 'markdown'
                        },
                        extra_args = { '--prose-wrap', 'always' }
                    },
                    -- Builtin formatters that strip trailing whitespace;
                    -- disabled for languages whose LSP supports formatting
                    null_ls.builtins.formatting.trim_newlines.with {
                        disabled_filetypes = { "rust" }
                    },
                    null_ls.builtins.formatting.trim_whitespace.with {
                        disabled_filetypes = { "rust" }
                    },

                    -- Code actions
                    null_ls.builtins.code_actions.gitsigns, -- Integration with gitsigns
                }
            })
        end
    }

    ---- Language support
    use 'google/vim-jsonnet' -- jsonnet support

    ---- Aesthetics
    use { -- Indent guides
        'lukas-reineke/indent-blankline.nvim',
        config = function()
            require('indent_blankline').setup { show_current_context = true } -- Show current indent level by treesitter
        end
    }

    use { -- Show marks in sign column
        'kshenoy/vim-signature',
        setup = function()
            vim.g.SignatureMap = {
                Leader             =  "m",
                DeleteMark         =  "dm",
                PurgeMarks         =  "m<Space>",
                -- Disable the following mappings
                ListBufferMarks    =  "", ListBufferMarkers  =  "",
                PlaceNextMark      =  "", ToggleMarkAtLine   =  "",
                PurgeMarksAtLine   =  "", PurgeMarkers       =  "",
                GotoNextLineAlpha  =  "", GotoPrevLineAlpha  =  "",
                GotoNextSpotAlpha  =  "", GotoPrevSpotAlpha  =  "",
                GotoNextLineByPos  =  "", GotoPrevLineByPos  =  "",
                GotoNextSpotByPos  =  "", GotoPrevSpotByPos  =  "",
                GotoNextMarker     =  "", GotoPrevMarker     =  "",
                GotoNextMarkerAny  =  "", GotoPrevMarkerAny  =  "",
            }
        end
    }

    use { -- Color scheme
        'sainnhe/sonokai',
        config = function()
            vim.cmd 'colorscheme sonokai'
        end
    }

    ---- Misc
    use 'romainl/vim-qf' -- Make quickfix behavior more convenient
    use 'moll/vim-bbye' -- Add :Bdelete to close buffers without modifying layout

    -- Enable short CursorHold updatetime without writing swap too often
    -- TODO: remove when https://github.com/neovim/neovim/issues/12587 is fixed
    use {
        'antoinemadec/FixCursorHold.nvim',
        setup = function()
            vim.g.cursorhold_updatetime = 100
        end
    }
end)
