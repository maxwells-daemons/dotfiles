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
 - Replace/remove vim-signature
 - Align plugin
 - Status line (https://github.com/nvim-lualine/lualine.nvim) and https://github.com/SmiteshP/nvim-gps

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

            -- Readable names for custom text objects
            local objects = require('which-key.plugins.presets').objects
            -- treesitter-textobjects
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
                    b = {':bprevious<CR>', 'Previous buffer'},
                    B = {':bfirst', 'First buffer'},
                    l = {'<Plug>(qf_loc_previous)', 'Previous loclist'},
                    L = {':lfirst<CR>', 'First loclist'},
                    q = {'<Plug>(qf_qf_previous)', 'Previous quickfix'},
                    Q = {':cfirst<CR>', 'First quickfix'},
                },
                [']'] = {
                    name = 'next',
                    c = {"&diff ? ']c' : '<cmd>Gitsigns next_hunk<CR>'", 'Next change', expr = true},
                    d = {'<cmd>lua vim.diagnostic.goto_next()<CR>', 'Next diagnostic'},
                    b = {':bnext<CR>', 'Next buffer'},
                    B = {':blast<CR>', 'Last buffer'},
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
                    -- Commenting
                    c = {'<Plug>Commentary', 'Comment'}, -- Operator
                    cc = {'<Plug>CommentaryLine', 'Comment line'},
                    -- LSP
                    r = {'<cmd>lua vim.lsp.buf.rename()<cr>', 'Rename symbol'},
                    a = {"<cmd>lua require('telescope.builtin').lsp_code_actions()<CR>", 'Code action'},
                    d = {
                        name = 'diagnostics',
                        q = {'<cmd>lua vim.diagnostic.setqflist()<CR>', 'Workspace diagnostics in quickfix'},
                        l = {'<cmd>lua vim.diagnostic.setloclist()<CR>', 'Buffer diagnostics in loclist'},
                    },
                    -- Others
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
                    w = { name = 'wiki' },
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
                ['<Leader>c'] = {'<Plug>Commentary', 'Comment'},
                ['<Leader>a'] = {"<cmd>lua require('telescope.builtin').lsp_range_code_actions()<CR>", 'Code action'},
                ['<Leader>gs'] = {':Gitsigns stage_hunk<CR>', 'Stage lines'},
                ['<Leader>gr'] = {':Gitsigns reset_hunk<CR>', 'Reset lines'},
            }, { mode = 'x' })

            -- Insert mode mappings
            wk.register({
                    ['<C-s>'] = {'<cmd>lua vim.lsp.buf.signature_help()<CR>', 'Display function signature'},
                    ['<C-v>'] = {'copilot#Accept("")', 'Accept copilot suggestion', expr = 1},
                    ['<C-c>'] = {'copilot#Dismiss()', 'Dismiss copilot suggestion', expr = 1},
                }, {mode='i'}
            )
            -- NOTE: autocomplete mappings set up in the cmp section

            -- Quickfix menu mappings
            vim.cmd [[
            function! QFMappings()
                nmap <buffer> {     <Plug>(qf_previous_file)
                nmap <buffer> }     <Plug>(qf_next_file)
            endfunction

            autocmd FileType qf call QFMappings()
            ]]
        end
    }

    ---- Editing
    use 'tpope/vim-commentary' -- Operator for commenting/uncommenting
    use 'wellle/targets.vim' -- Advanced pair text objects

    use { -- Text objects for surroundings
        'tpope/vim-surround',
        requires = { 'tpope/vim-repeat' }
    }

    ---- Autocompletion
    use {
        'hrsh7th/nvim-cmp', -- Autocomplete engine
        requires = {
            -- Completion sources
            'hrsh7th/cmp-nvim-lsp',
            'hrsh7th/cmp-buffer',
            'hrsh7th/cmp-path',
            'saadparwaiz1/cmp_luasnip',
        },
        after = 'LuaSnip',
        config = function()
            vim.o.completeopt = 'menu,menuone,noselect'

            local cmp = require('cmp')
            local luasnip = require('luasnip')

            -- Setup completion
            cmp.setup {
                sources = cmp.config.sources {
                    { name = 'path' },
                    { name = 'nvim_lsp' },
                    { name = 'buffer' },
                    { name = 'luasnip' },
                },
                snippet = {
                    expand = function(args) return luasnip.lsp_expand(args.body) end,
                },
                mapping = {
                    ['<C-u>'] = cmp.mapping(cmp.mapping.scroll_docs(-4), { 'i', 'c' }),
                    ['<C-d>'] = cmp.mapping(cmp.mapping.scroll_docs(4), { 'i', 'c' }),
                    ['<C-Space>'] = cmp.mapping(cmp.mapping.complete(), { 'i', 'c' }),
                    ['<C-y>'] = cmp.config.disable,
                    ['<C-e>'] = cmp.mapping({
                        i = cmp.mapping.abort(),
                        c = cmp.mapping.close(),
                    }),
                    ['<CR>'] = cmp.mapping.confirm({ select = true }),
                    -- Tab completion (modified from: https://github.com/hrsh7th/nvim-cmp/wiki/Example-mappings)
                    ["<Tab>"] = cmp.mapping(function(fallback)
                        if cmp.visible() then
                            cmp.select_next_item()
                        elseif luasnip.expand_or_jumpable() then
                            luasnip.expand_or_jump()
                        else
                            fallback() -- Send the key that was mapped prior
                        end
                    end, { "i", "s" }),
                    ["<S-Tab>"] = cmp.mapping(function(fallback)
                        if cmp.visible() then
                            cmp.select_prev_item()
                        elseif luasnip.jumpable(-1) then
                            luasnip.jump(-1)
                        else
                            fallback()
                        end
                    end, { "i", "s" }),
                },
            }
        end
    }

    use { -- Snippets
        'L3MON4D3/LuaSnip',
        config = function()
            ls = require('luasnip')
            ls.snippets = {
                all = {
                    ls.snippet("date", ls.function_node(function() return os.date("%y-%m-%d") end)),
                    ls.snippet("time", ls.function_node(function() return os.date("%I:%M %p") end)),
                },
                python = {
                    ls.snippet(
                        "pdb",
                        ls.text_node {
                            "# TODO: remove",
                            "# fmt: off",
                            "import pdb; pdb.set_trace()",
                            "# fmt: on",
                            "",
                        }
                    ),
                }
            }
        end
    }

    use { -- Copilot autocomplete
        'github/copilot.vim',
        -- NOTE: depends on Node.js>=12
        setup = function()
            -- We map the copilot key manually
            vim.g.copilot_no_tab_map = true
            vim.g.copilot_assume_mapped = true
            vim.g.copilot_tab_fallback = ""
            vim.g.copilot_filetypes = {
                vimwiki = false,
                TelescopePrompt = false,
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
        config = function()
            local telescope = require('telescope')
            telescope.load_extension('fzf')
            telescope.setup {
                pickers = {
                    lsp_code_actions = { theme = "cursor" },
                    lsp_range_code_actions = { theme = "cursor" },
                }
            }
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
                            'json', 'yaml', 'markdown', 'vimwiki'
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
    -- LSP config finished after plugins block

    ---- Notes
    use {
        'vimwiki/vimwiki',
        config = function()
            -- TODO: integrate with Obsidian tags by modifying
            -- s:markdown_syntax.tag_search and s:markdown_syntax.tag_match
            -- (see: .local/share/nvim/site/pack/packer/start/vimwiki/syntax/vimwiki_markdown.vim)

            -- TODO: integrate with TreeSitter markdown syntax

            -- TODO: Pandoc integration
            vim.g.vimwiki_list = {
                {
                    path = '~/media/documents/obsidian', -- NOTE: must update per host
                    syntax = 'markdown',
                    ext = '.md'
                }
            }
            vim.g.vimwiki_listsyms = ' .oOx' -- Compatibility with Obsidian checkboxes
            vim.g.vimwiki_auto_chdir = 1 -- Automatically chdir into wiki dir when entering a wiki file
        end
    }

    ---- Aesthetics
    use 'lukas-reineke/indent-blankline.nvim' -- Indent guides

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

---- LSP setup
local lspconfig = require('lspconfig')

-- When we connect to a language server, setup illuminate and lsp_signature
local on_lsp_attach = function(client, _)
    require('illuminate').on_attach(client)
    require('lsp_signature').on_attach({
        bind = true,
        hi_parameter = 'Search',
        floating_window = false,  -- Trigger manually with <C-s>
        hint_enable = false,
    })
end

local setup_lsp = function(server)
    local options = {
        on_attach = on_lsp_attach,
        -- cmp setup: tell the LSP we can do completion
        capabilities = require('cmp_nvim_lsp').update_capabilities(
            vim.lsp.protocol.make_client_capabilities()
        ),
    }
    server:setup(options)
end

-- Setup language-specific LSP servers
-- NOTE: depends on:
-- - [pyright](https://github.com/microsoft/pyright)
-- - [rust-analyzer](https://rust-analyzer.github.io)
setup_lsp(lspconfig.pyright)
setup_lsp(lspconfig.rust_analyzer)
