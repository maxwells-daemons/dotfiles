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
 - DAP (once it's ready)
 - Plugin with motions and text objects for parent/child/sibling nodes

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
            -- treesitter-textsubjects
            objects['<cr>'] = 'syntax node'
            objects['a<cr>'] = 'containing node'
            -- textobj-entire
            objects['ie'] = 'entire buffer'
            objects['ae'] = 'entire buffer'
            -- textobj-pastedtext
            objects['aP'] = 'pasted text'

            wk.setup {
                motions = {count = false},  -- Disable WhichKey for actions like "c3..."
                plugins = {marks = false},  -- Don't show for marks due to flickering with ``
            }

            -- Motions: used in normal, visual, and operator-pending modes
            local motions = {
                ['['] = {
                    name = 'previous',
                    c = {"&diff ? '[c' : '<cmd>Gitsigns prev_hunk<CR>'", 'Previous change', expr = true},
                    e = {'<cmd>lua vim.diagnostic.goto_prev()<CR>', 'Previous error'},
                    l = {'<Plug>(qf_loc_previous)', 'Previous loclist'},
                    L = {':lfirst<CR>', 'First loclist'},
                    q = {'<Plug>(qf_qf_previous)', 'Previous quickfix'},
                    Q = {':cfirst<CR>', 'First quickfix'},
                },
                [']'] = {
                    name = 'next',
                    c = {"&diff ? ']c' : '<cmd>Gitsigns next_hunk<CR>'", 'Next change', expr = true},
                    e = {'<cmd>lua vim.diagnostic.goto_next()<CR>', 'Next error'},
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
                ao = {'<Plug>(textobj-line-a)', 'inside line (excluding whitespace)'},
                io = {'<Plug>(textobj-line-i)', 'around line (including whitespace)'},
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
                ['<A-h>'] = 'Buffer next',
                ['<A-l>'] = 'Buffer previous',
                ['<C-_>'] = 'Clear highlighting',
                ['<c-s>'] = {'<cmd>lua vim.lsp.buf.signature_help()<CR>', 'Display function signature'},
                K = {'<cmd>lua vim.lsp.buf.hover()<CR>', 'Get symbol info'},
                ['<C-c><C-c>'] = {'<Plug>CommentaryLine', 'Comment line'},
                -- Operators
                ['<C-c>'] = {'<Plug>Commentary', 'Comment'},
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
                    r = {'<cmd>lua vim.lsp.buf.rename()<cr>', 'Rename symbol'},
                    a = {"<cmd>lua require('telescope.builtin').lsp_code_actions()<CR>", 'Code action'},
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
                        ['/'] = {"<cmd>lua require('telescope.builtin').current_buffer_fuzzy_find()<cr>", 'Fuzzy search'},
                        r = {"<cmd>lua require('telescope.builtin').lsp_references()<cr>", 'References'},
                        s = {"<cmd>lua require('telescope.builtin').lsp_document_symbols()<cr>", 'Symbols in the buffer'},
                        S = {"<cmd>lua require('telescope.builtin').lsp_dynamic_workspace_symbols()<cr>", 'Symbols in the workspace'},
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
                ['<C-c>'] = {'<Plug>Commentary', 'Comment'},
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
                nmap <buffer> <A-h> <Plug>(qf_older)
                nmap <buffer> <A-l> <Plug>(qf_newer)
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

    use {
        'kana/vim-textobj-entire', -- Text object for the entire buffer
        requires = { 'kana/vim-textobj-user' }
    }

    use {
        'kana/vim-textobj-line', -- Text object for the current line
        requires = { 'kana/vim-textobj-user' },
        setup = function ()
            vim.g.textobj_line_no_default_key_mappings = true
        end
    }

    use {
        'saaguero/vim-textobj-pastedtext', -- Text object for the last paste
        requires = { 'kana/vim-textobj-user' },
        setup = function ()
            vim.g.pastedtext_select_key = 'aP' -- Map to aP
        end
    }

    ---- Autocompletion
    use {
        'hrsh7th/nvim-cmp', -- Autocomplete engine
        requires = {
            -- Completion sources
            'hrsh7th/cmp-nvim-lsp',
            'hrsh7th/cmp-buffer',
            'hrsh7th/cmp-path',
            -- Snippets
            'hrsh7th/cmp-vsnip',
            'hrsh7th/vim-vsnip'
        },
        config = function()
            vim.o.completeopt = 'menu,menuone,noselect'
            local cmp = require('cmp')

            -- Used for tab complete (https://github.com/hrsh7th/nvim-cmp/wiki/Example-mappings)
            local feedkey = function(key, mode)
                vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(key, true, true, true), mode, true)
            end

            -- Setup completion
            cmp.setup {
                snippet = {
                    expand = function(args)
                        vim.fn["vsnip#anonymous"](args.body)
                    end
                },
                sources = cmp.config.sources {
                    { name = 'vsnip' },
                    { name = 'path' },
                    { name = 'nvim_lsp' },
                    { name = 'buffer' },
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
                        elseif vim.fn["vsnip#available"](1) == 1 then
                            feedkey("<Plug>(vsnip-expand-or-jump)", "")
                        else
                            fallback() -- Send the key that was mapped prior
                        end
                    end, { "i", "s" }),
                    ["<S-Tab>"] = cmp.mapping(function(fallback)
                        if cmp.visible() then
                            cmp.select_prev_item()
                        elseif vim.fn["vsnip#jumpable"](-1) == 1 then
                            feedkey("<Plug>(vsnip-jump-prev)", "")
                        else
                            fallback()
                        end
                    end, { "i", "s" }),
                },
            }
        end
    }

    use { -- Copilot autocomplete
        'github/copilot.vim',
        setup = function()
            -- We map the copilot key manually
            vim.g.copilot_no_tab_map = true
            vim.g.copilot_assume_mapped = true
            vim.g.copilot_tab_fallback = ""
            vim.g.copilot_filetypes = {
                vimwiki = false,
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
                    'comment', 'bash', 'c', 'dockerfile', 'json', 'python', 'lua', 'vim', 'yaml', 'rust'
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
    use 'williamboman/nvim-lsp-installer' -- Installs LSPs locally

    use {
        'jose-elias-alvarez/null-ls.nvim', -- Register local capabilities with LSP interface
        requires = { 'nvim-lua/plenary.nvim' },
        config = function()
            local null_ls = require('null-ls')
            null_ls.setup({ -- NOTE: not using common LSP on_attach
                sources = {
                    -- Formatting
                    null_ls.builtins.formatting.trim_newlines, -- Remove trailing newlines
                    null_ls.builtins.formatting.trim_whitespace, -- Remove trailing whitespace
                    null_ls.builtins.formatting.isort, -- Sort python imports
                    null_ls.builtins.formatting.black, -- Format python code
                    null_ls.builtins.formatting.prettier.with({ -- Multi-language formatter
                        filetypes = {
                            'html', 'css', 'scss', 'less', 'javascript',
                            'json', 'yaml', 'markdown', 'vimwiki'
                        },
                    }),
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

            -- TODO: Pandoc integration
            vim.g.vimwiki_list = {
                {
                    path = '~/media/documents/obsidian',
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

    use { -- Enable short CursorHold updatetime without writing swap too often
        'antoinemadec/FixCursorHold.nvim',
        setup = function()
            vim.g.cursorhold_updatetime = 100
        end
    }
end)

---- LSP setup
-- When we connect to a language server, setup illuminate and lsp_signature
local on_lsp_attach = function(client, bufnr)
    require('illuminate').on_attach(client)
    require('lsp_signature').on_attach({
        bind = true,
        hi_parameter = 'Search',
        floating_window = false,  -- Trigger manually with <C-s>
        hint_enable = false,
    })
end

-- For each language server installed with nvim-lsp-installer, configure
-- it through this callback and launch the server when appropriate.
require('nvim-lsp-installer').on_server_ready(function(server)
    local options = {
        on_attach = on_lsp_attach,
        capabilities = require('cmp_nvim_lsp').update_capabilities( -- cmp setup: tell the LSP we can do completion
            vim.lsp.protocol.make_client_capabilities()
        )
    }

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

    server:setup(options)
end)
