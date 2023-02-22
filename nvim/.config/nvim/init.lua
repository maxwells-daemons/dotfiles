--[[ Boostrapping ]]
-- git clone --depth 1 https://github.com/wbthomason/packer.nvim ~/.local/share/nvim/site/pack/packer/start/packer.nvim

-- Automatically PackerCompile when we save this file
vim.api.nvim_create_autocmd("BufWritePost", {
    command = "source <afile> | PackerCompile",
    pattern = vim.env.MYVIMRC,
    group = vim.api.nvim_create_augroup("Packer", {}),
})

--[[ Packages ]]
require("packer").startup(function(use)
    --[[ UI ]]
    use { "nvim-telescope/telescope.nvim", -- Fuzzy finder (requires ripgrep and fd)
        requires = { "nvim-lua/plenary.nvim", { "nvim-telescope/telescope-fzf-native.nvim", run = "make" } },
        after = "telescope-fzf-native.nvim",
        config = function()
            require("telescope").load_extension("fzf")
            local telescope = require("telescope.builtin")

            -- <tab> searches buffers, <enter> searches files, <s-enter> searches hidden files
            vim.keymap.set("n", "<tab>", function() telescope.buffers { sort_mru = true, ignore_current_buffer = true } end)
            vim.keymap.set("n", "<cr>", telescope.find_files)
            vim.keymap.set("n", "<s-cr>", function() telescope.find_files { hidden = true, no_ignore = true} end)
        end
    }

    --[[ Editing ]]
    use "wellle/targets.vim" -- Pair, separator, and count text objects
    use { "tpope/vim-surround", requires = { "tpope/vim-repeat" } } -- Edit surrounding text
    use { "numToStr/Comment.nvim", config = function() require("Comment").setup() end } -- Comment actions (gc, gb)

    use { "junegunn/vim-easy-align", -- Align action (ga)
        config = function() vim.keymap.set({"n", "x"}, "ga", "<Plug>(EasyAlign)") end
    }

    use { "ggandor/leap.nvim", -- Fast 2-character motion (s, S, gs)
        requires = { "tpope/vim-repeat" }, config = function() require("leap").add_default_mappings() end
    }

    --[[ Autocompletion ]]
    use { "L3MON4D3/LuaSnip", -- Snippets
        requires = {"rafamadriz/friendly-snippets"},
        config = function() require("luasnip.loaders.from_vscode").lazy_load() end -- Load default snippets from friendly-snippets
    }

    use { "hrsh7th/nvim-cmp", -- Autocompletion engine
        requires = { "saadparwaiz1/cmp_luasnip", "hrsh7th/cmp-nvim-lsp", "hrsh7th/cmp-nvim-lsp-signature-help", "hrsh7th/cmp-buffer", "hrsh7th/cmp-path" },
        config = function()
            local cmp = require("cmp")
            local luasnip = require("luasnip")
            cmp.setup {
                snippet = { expand = function(args) require("luasnip").lsp_expand(args.body) end },
                mapping = cmp.mapping.preset.insert({
                    -- <c-u/d> to scroll docs
                    ["<c-u>"] = cmp.mapping.scroll_docs(-4),
                    ["<c-d>"] = cmp.mapping.scroll_docs(4),
                    -- <c-space> to begin completion, <c-e> to abort, <cr> to confirm
                    ["<c-space>"] = cmp.mapping.complete(),
                    ["<cr>"] = cmp.mapping.confirm({ select = true }),
                    -- "Supertab" mapping
                    ["<tab>"] = cmp.mapping(
                        function(fallback)
                            if cmp.visible() then cmp.select_next_item()
                            elseif luasnip.expand_or_jumpable() then luasnip.expand_or_jump()
                            else fallback() end
                        end,
                        { "i", "s" }
                    ),
                    ["<s-tab>"] = cmp.mapping(
                        function(fallback)
                            if cmp.visible() then cmp.select_prev_item()
                            elseif luasnip.jumpable(-1) then luasnip.jump(-1)
                            else fallback() end
                        end,
                        { "i", "s" }
                    )
                }),
                sources = { { name = "luasnip" }, { name = "nvim_lsp" }, { name = "nvim_lsp_signature_help" }, { name = "buffer" }, { name = "path" } },
            }
        end
    }

    --[[ Parsing ]]
    use { "nvim-treesitter/nvim-treesitter",
        -- Update parsers when updating TS
        run = function() require("nvim-treesitter.install").update({ with_sync = true }) end,
        requires = { "nvim-treesitter/nvim-treesitter-textobjects", after = { "nvim-treesitter" } },
        config = function()
            require("nvim-treesitter.configs").setup({
                -- Install parsers on buffer enter, plus parser for common comments
                auto_install = true,
                ensure_installed = { "comment" },

                -- TS highlighting and text objects
                highlight = { enable = true },
                textobjects = {
                    select = {
                        enable = true,
                        lookahead = true,
                        keymaps = {
                            ["ac"] = "@comment.outer",     ["ic"] = "@comment.outer",     -- [c]omment
                            ["af"] = "@function.outer",    ["if"] = "@function.inner",    -- [f]unction
                            ["aa"] = "@parameter.outer",   ["ia"] = "@parameter.inner",   -- [a]rgument
                            ["ai"] = "@conditional.outer", ["ii"] = "@conditional.inner", -- [i]f
                            ["al"] = "@loop.outer",        ["il"] = "@loop.inner",        -- [l]oop
                            ["aC"] = "@class.outer",       ["iC"] = "@class.inner",       -- [C]lass
                        }
                    },
                }
            })

            -- TS folding
            vim.o.foldmethod = "expr"
            vim.o.foldexpr = "nvim_treesitter#foldexpr()"
            vim.o.foldlevel = 99
        end
    }

    --[[ Language servers ]]
    use { "neovim/nvim-lspconfig", -- Prebuilt configs
        config = function()
            local lsp = require("lspconfig")
            local capabilities = require("cmp_nvim_lsp").default_capabilities()

            -- Setup language servers
            lsp.pyright.setup({ capabilities =  capabilities })
            lsp.rust_analyzer.setup({ capabilities =  capabilities })
        end
    }

    use { "jose-elias-alvarez/null-ls.nvim", -- Make external tools act as a language server
        requires = { "nvim-lua/plenary.nvim" },
        config = function()
            local null_ls = require("null-ls")
            null_ls.setup({
                sources = {
                    -- Python formatting
                    null_ls.builtins.formatting.isort.with { args = {"--stdout", "--profile", "black", "-"} },
                    null_ls.builtins.formatting.black.with { args = {"--quiet", "--fast", "-" } },

                    -- Multi-language formatting
                    null_ls.builtins.formatting.prettier.with { extra_args = { "--prose-wrap", "always" } },
                    null_ls.builtins.formatting.trim_newlines.with { disabled_filetypes = { "rust" } },
                    null_ls.builtins.formatting.trim_whitespace.with { disabled_filetypes = { "rust" } },

                    -- Code actions
                    null_ls.builtins.code_actions.gitsigns,
                }
            })
        end
    }

    --[[ Git ]]
    use { -- Git editor integration: diffs, edit @ commit, etc
        "tpope/vim-fugitive",
        config = function() vim.keymap.set("n", "<leader>gg", "<cmd>Git<cr>") end
    }

    use { -- Git decorations, text objects, etc
        "lewis6991/gitsigns.nvim",
        requires = { "nvim-lua/plenary.nvim" },
        config = function()
            local gs = require("gitsigns")
            gs.setup()

            -- Navigate [c]hanges
            vim.keymap.set({"n", "x", "o"}, "[c", function() if vim.wo.diff then return "[c" end gs.prev_hunk() end)
            vim.keymap.set({"n", "x", "o"}, "]c", function() if vim.wo.diff then return "]c" end gs.next_hunk() end)

            -- [g]it text objects and actions
            vim.keymap.set({"x", "o"}, "ig", gs.select_hunk)
            vim.keymap.set({"x", "o"}, "ag", gs.select_hunk)

            vim.keymap.set({"n", "v"}, "<leader>gs", ":Gitsigns stage_hunk<cr>")
            vim.keymap.set("n",        "<leader>gS", gs.stage_buffer)
            vim.keymap.set("n",        "<leader>gu", gs.undo_stage_hunk)
            vim.keymap.set("n",        "<leader>gU", gs.reset_buffer_index)
            vim.keymap.set({"n", "v"}, "<leader>gr", ":Gitsigns reset_hunk<cr>")
            vim.keymap.set("n",        "<leader>gR", gs.reset_buffer)
            vim.keymap.set("n",        "<leader>gd", gs.toggle_deleted)
            vim.keymap.set("n",        "<leader>gp", gs.preview_hunk)
            vim.keymap.set("n",        "<leader>gb", gs.blame_line)
        end
    }

    --[[ Visuals ]]
    use { "sainnhe/sonokai", config = function() vim.cmd("colorscheme sonokai") end } -- Colorscheme
    use { "chentoast/marks.nvim", config = function() require("marks").setup({}) end } -- Show marks
    use "lukas-reineke/indent-blankline.nvim" -- Show indent guides
    use "RRethy/vim-illuminate" -- Highlight word under cursor

    --[[ Misc ]]
    use "wbthomason/packer.nvim" -- Package manager
    use "tpope/vim-sleuth" -- Detect tab width from file
end)

--[[ Mappings ]]
-- Leader is <space>
vim.keymap.set("n", "<space>", "<nop>")
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- <c-hjkl> navigates splits
vim.keymap.set("n", "<c-h>", "<c-w>h")
vim.keymap.set("n", "<c-j>", "<c-w>j")
vim.keymap.set("n", "<c-k>", "<c-w>k")
vim.keymap.set("n", "<c-l>", "<c-w>l")

-- <esc> clears search highlight
vim.keymap.set("n", "<esc>", "<cmd>nohlsearch<cr>")

-- gp selects last paste
vim.keymap.set("n", "gp", "`[v`]")

-- [d]iagnostics
vim.keymap.set({"n", "x", "o"}, "[d", vim.diagnostic.goto_prev)
vim.keymap.set({"n", "x", "o"}, "]d", vim.diagnostic.goto_next)
vim.keymap.set("n", "<leader>d", vim.diagnostic.setloclist)
vim.keymap.set("n", "<leader>D", vim.diagnostic.setqflist)

-- LSP motions and actions
vim.keymap.set("n",        "K",         vim.lsp.buf.hover)
vim.keymap.set("n",        "gk",        vim.lsp.buf.signature_help)
vim.keymap.set({"n", "v"}, "=", function() vim.lsp.buf.format({ async = true }) end)
vim.keymap.set("n",        "<leader>r", vim.lsp.buf.rename)
vim.keymap.set({"n", "v"}, "<leader>a", vim.lsp.buf.code_action)

vim.keymap.set("n", "gd", vim.lsp.buf.definition)
vim.keymap.set("n", "gD", vim.lsp.buf.declaration)
vim.keymap.set("n", "gr", vim.lsp.buf.references)
vim.keymap.set("n", "gi", vim.lsp.buf.implementation)
vim.keymap.set("n", "gt", vim.lsp.buf.type_definition)

--[[ Settings ]]
-- Persist undo history
vim.o.undofile = true

-- Disable ShaDa; do not persist marks, commandline, etc
vim.o.shada = nil

-- Use system clipboard
vim.o.clipboard = "unnamedplus"

-- Trigger CursorHold events after 500ms
vim.o.updatetime = 500

-- Searches without caps are case-insensitive
vim.o.ignorecase = true
vim.o.smartcase = true

-- Indent to a multiple of shiftwidth
vim.o.shiftround = true

-- Improve wildmenu completions
vim.o.wildmode = "longest:full,full"

--[[ Visuals ]]
-- Show absolute and relative line numbers
vim.o.number = true
vim.o.relativenumber = true

-- Enable 24-bit colors
vim.o.termguicolors = true

-- Always show sign and fold columns
vim.o.signcolumn = "yes"
vim.o.foldcolumn = "1"

-- Show line diagnostics on cursor hover
vim.api.nvim_create_autocmd("CursorHold", {
    callback = function()
        -- Check if there's already a floating window; don't overwrite it if so
        for _, winid in pairs(vim.api.nvim_tabpage_list_wins(0)) do
            if vim.api.nvim_win_get_config(winid).zindex then
                return
            end
        end
        vim.diagnostic.open_float({ focusable = false })
    end,
    group = vim.api.nvim_create_augroup("Hover", {})
})
