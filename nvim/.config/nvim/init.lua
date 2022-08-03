-- init.lua: configuration for Neovim.
-- Extends default vimrc, which sets basic options and mappings.

-- Load initial config from vimrc
vim.cmd 'source ~/.vim/vimrc'

-- Basic settings specific to nvim
vim.opt.foldcolumn = '1' -- Always display foldcolumn to avoid jitter on folding
vim.opt.signcolumn = 'yes' -- Always display signcolumn to avoid jitter on LSP diagnostics

-- Use system python for nvim in all virtualenvs
vim.g.python3_host_prog = '/opt/homebrew/bin/python3'

---- User autocmds
local lspGroup = vim.api.nvim_create_augroup('UserLsp', {})
vim.api.nvim_create_autocmd('CursorHold', { 
    desc = 'Show floating diagnostics on the cursor line',
    group = lspGroup,
    callback = function() 
        vim.diagnostic.open_float(nil, { scope = "line", focusable = false }) 
    end
})

local direnvGroup = vim.api.nvim_create_augroup('UserDirenv', {})
vim.api.nvim_create_autocmd({'BufNewFile', 'BufRead'}, {
    desc = 'Highlight direnv files as bash',
    pattern = {'.envrc', '.env'},
    group = direnvGroup,
    callback = function() vim.opt.filetype = 'bash' end
})

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
            objects['ac'] = 'a class'
            objects['ic'] = 'inner class'
            objects['a/'] = 'a comment'
            objects['i/'] = 'a comment'
            objects['ai'] = 'a conditional'
            objects['ii'] = 'inner conditional'
            objects['af'] = 'a function'
            objects['if'] = 'inner function'
            objects['al'] = 'a loop'
            objects['il'] = 'inner loop'
            objects['aa'] = 'a parameter'
            objects['ia'] = 'inner parameter'

            wk.setup {
                motions = {count = false},  -- Disable WhichKey for actions like "c3..."
                plugins = {marks = false},  -- Don't show for marks due to flickering with ``
            }

            -- Motions: used in normal, visual, and operator-pending modes
            local motions = {
                ['['] = {
                    name = 'previous',
                    -- UI
                    b = {':bprevious<CR>', 'Previous buffer'},
                    B = {':bfirst<CR>', 'First buffer'},
                    t = {':tabprevious<CR>', 'Previous tab'},
                    T = {':tabfirst<CR>', 'First tab'},
                    -- Quickfix & loclist
                    l = {'<Plug>(qf_loc_previous)', 'Previous loclist'},
                    L = {':lfirst<CR>', 'First loclist'},
                    q = {'<Plug>(qf_qf_previous)', 'Previous quickfix'},
                    Q = {':cfirst<CR>', 'First quickfix'},
                    -- Code
                    g = {"&diff ? '[c' : '<cmd>Gitsigns prev_hunk<CR>'", 'Previous git hunk', expr = true},
                    d = {'<cmd>lua vim.diagnostic.goto_prev()<CR>', 'Previous diagnostic'},
                    -- Treesitter
                    c = 'Previous class start',
                    C = 'Previous class end',
                    ['/'] = 'Previous comment',
                    i = 'Previous conditional start',
                    I = 'Previous conditional end',
                    f = 'Previous function start',
                    F = 'Previous function end',
                    a = 'Previous argument start',
                    A = 'Previous argument end',
                },
                [']'] = {
                    name = 'next',
                    -- UI
                    b = {':bnext<CR>', 'Next buffer'},
                    B = {':blast<CR>', 'Last buffer'},
                    t = {':tabnext<CR>', 'Next tab'},
                    T = {':tablast<CR>', 'Last tab'},
                    -- Quickfix & loclist
                    l = {'<Plug>(qf_loc_next)', 'Next loclist'},
                    L = {':llast<CR>', 'Last loclist'},
                    q = {'<Plug>(qf_qf_next)', 'Next quickfix'},
                    Q = {':clast<CR>', 'Last quickfix'},
                    -- Code
                    g = {"&diff ? ']c' : '<cmd>Gitsigns next_hunk<CR>'", 'Next git hunk', expr = true},
                    d = {'<cmd>lua vim.diagnostic.goto_next()<CR>', 'Next diagnostic'},
                    -- Treesitter
                    c = 'Next class start',
                    C = 'Next class end',
                    ['/'] = 'Next comment',
                    i = 'Next conditional start',
                    I = 'Next conditional end',
                    f = 'Next function start',
                    F = 'Next function end',
                    a = 'Next argument start',
                    A = 'Next argument end',
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

                ['<Esc>'] = 'Clear highlighting',

                ['<C-s>'] = {'<cmd>lua vim.lsp.buf.signature_help()<CR>', 'Display function signature'},
                K = {'<cmd>lua vim.lsp.buf.hover()<CR>', 'Get symbol info'},

                -- Jumps
                g = {
                    d = {'<cmd>lua vim.lsp.buf.definition()<CR>', 'Go to definition'},
                    D = {'<cmd>lua vim.lsp.buf.declaration()<CR>', 'Go to declaration'},
                    i = {'<cmd>lua vim.lsp.buf.implementation()<CR>', 'Go to implementation'},
                    t = {'<cmd>lua vim.lsp.buf.type_definition()<CR>', 'Go to type definition'},
                    r = {'<cmd>lua vim.lsp.buf.references()<CR>', 'Get references in quickfix'},
                },

                ['<Leader>'] = {
                    -- UI
                    q = {'<Plug>(qf_qf_toggle_stay)', 'Toggle quickfix'},
                    l = {'<Plug>(qf_loc_toggle_stay)', 'Toggle loclist'},

                    -- Editing
                    a = {'<Plug>(EasyAlign)', 'Align'},
                    ['/'] = {'<Plug>Commentary', 'Comment operator'},
                    ['//'] = {'<Plug>CommentaryLine', 'Comment line'},

                    -- Groups
                    l = {
                        name = 'lsp',
                        f = {'<cmd>lua vim.lsp.buf.formatting()<CR>', 'Format buffer'},
                        r = {'<cmd>lua vim.lsp.buf.rename()<cr>', 'Rename symbol'},
                        a = {"<cmd>lua vim.lsp.buf.code_action()<CR>", 'Code action'},
                        ['/'] = {':lua require("neogen").generate()<CR>', 'Generate comment'},
                    },
                    d = {
                        name = 'diagnostics',
                        q = {'<cmd>lua vim.diagnostic.setqflist()<CR>', 'Workspace diagnostics in quickfix'},
                        l = {'<cmd>lua vim.diagnostic.setloclist()<CR>', 'Buffer diagnostics in loclist'},
                    },
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
                ['s'] = 'Leap forward', -- From Leap
                ['S'] = 'Leap backward',
                -- Ignored mappings
                ['U'] = 'which_key_ignore',
                ['<C-Space>'] = 'which_key_ignore',
            })

            -- Visual mappings
            wk.register({
                P = 'Paste without overwriting',
                ['<Leader>a'] = {'<Plug>(EasyAlign)', 'Align'},
                ['<Leader>/'] = {'<Plug>Commentary', 'Comment'},
                ['<Leader>lf'] = {'<cmd>lua vim.lsp.buf.range_formatting()<CR>', 'Format'},
                ['<Leader>la'] = {"<cmd>lua vim.lsp.buf.range_code_action()<CR>", 'Code action'},
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
    use 'junegunn/vim-easy-align' -- Alignment

    use { -- Text objects for surroundings
        'tpope/vim-surround',
        requires = { 'tpope/vim-repeat' }
    }

    use { -- Fast 2-character motion
        'ggandor/leap.nvim',
        requires = { 'tpope/vim-repeat' },
        config = function() require('leap').set_default_keymaps() end
    }

    use { -- Generate comment annotations
        'danymat/neogen',
        config = function() require('neogen').setup {} end
    }

    ---- Autocompletion
    use {
        'ms-jpq/coq_nvim', branch = 'coq',
        setup = function()
            vim.g.coq_settings = {
                auto_start = 'shut-up',
                clients = { snippets = { warn = {} } }, -- Disable no-snippets warning
                keymap = { jump_to_mark = '' }, -- Disable jump-to-mark keybind
                display = { icons = { mode = 'none' }}, -- Disable icons
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
                            ["ac"] = "@class.outer",
                            ["ic"] = "@class.inner",
                            ["a/"] = "@comment.outer",
                            ["i/"] = "@comment.outer",
                            ["ai"] = "@conditional.outer",
                            ["ii"] = "@conditional.inner",
                            ["af"] = "@function.outer",
                            ["if"] = "@function.inner",
                            ["al"] = "@loop.outer",
                            ["il"] = "@loop.inner",
                            ["aa"] = "@parameter.outer",
                            ["ia"] = "@parameter.inner",
                        }
                    },
                    move = {
                        enable = true,
                        set_jumps = true,
                        goto_next_start = {
                            ["]c"] = "@class.outer",
                            ["]/"] = "@comment.outer",
                            ["]i"] = "@conditional.outer",
                            ["]f"] = "@function.outer",
                            ["]a"] = "@parameter.inner",
                        },
                        goto_next_end = {
                            ["]C"] = "@class.outer",
                            ["]I"] = "@conditional.outer",
                            ["]F"] = "@function.outer",
                            ["]A"] = "@parameter.inner",
                        },
                        goto_previous_start = {
                            ["[c"] = "@class.outer",
                            ["[/"] = "@comment.outer",
                            ["[i"] = "@conditional.outer",
                            ["[f"] = "@function.outer",
                            ["[a"] = "@parameter.inner",
                        },
                        goto_previous_end = {
                            ["[C"] = "@class.outer",
                            ["[I"] = "@conditional.outer",
                            ["[F"] = "@function.outer",
                            ["[A"] = "@parameter.inner",
                        },
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
            'nvim-telescope/telescope-symbols.nvim' -- To use: :Telescope symbols
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
    use 'farmergreg/vim-lastplace' -- Resume editing at last cursor location

    -- Enable short CursorHold updatetime without writing swap too often
    -- TODO: remove when https://github.com/neovim/neovim/issues/12587 is fixed
    use {
        'antoinemadec/FixCursorHold.nvim',
        setup = function()
            vim.g.cursorhold_updatetime = 100
        end
    }
end)
