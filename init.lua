-- Auto-install Lazy.nvim if not already installed
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
    vim.fn.system({
        "git",
        "clone",
        "--filter=blob:none",
        "https://github.com/folke/lazy.nvim.git",
        lazypath,
    })
end
vim.opt.rtp:prepend(lazypath)

-- Automatically set python3_host_prog to the Conda environment's Python
vim.g.python3_host_prog = os.getenv("CONDA_PREFIX") and os.getenv("CONDA_PREFIX") .. "/bin/python" or "/home/alan/miniconda3/bin/python"

-- Lazy setup with plugins
require("lazy").setup({
    -- Comments
    { "terrortylor/nvim-comment", config = function()
    require('nvim_comment').setup()
    end },


    -- File explorer
    { "kyazdani42/nvim-tree.lua", config = function()
    require("nvim-tree").setup {}
    end },



    -- Enhanced Search
    { "nvim-telescope/telescope.nvim", dependencies = { "nvim-lua/plenary.nvim" } },


    -- Basic Linting for Python
    { "jose-elias-alvarez/null-ls.nvim", dependencies = { "nvim-lua/plenary.nvim" }, config = function()
    local null_ls = require("null-ls")
    null_ls.setup({
        sources = {
            null_ls.builtins.diagnostics.ruff,  -- Use Ruff for linting
            null_ls.builtins.formatting.ruff,    -- Use Ruff for formatting
            -- Add other formatters/linter as needed
        },
    })
    end },


    -- Status Line
    { "nvim-lualine/lualine.nvim", config = function()
    require("lualine").setup({
        options = {
            theme = "tokyonight",
        },
    })
    end },


    -- Improve line editing
    { "folke/which-key.nvim", config = function()
    require("which-key").setup {}
    end },


    -- Colorscheme plugin
    { "folke/tokyonight.nvim" },

    -- LSP and autocompletion for Python and C
    { "neovim/nvim-lspconfig", config = function()
        local lspconfig = require("lspconfig")
        -- Python LSP setup
        lspconfig.pyright.setup({})
        -- C/C++ LSP setup
        lspconfig.clangd.setup({})
    end},

    -- Autocompletion plugin
    { "hrsh7th/nvim-cmp", dependencies = {
        "hrsh7th/cmp-nvim-lsp",   -- LSP source
        "hrsh7th/cmp-buffer",      -- Buffer source
        "hrsh7th/cmp-path",        -- Path source
        "saadparwaiz1/cmp_luasnip",-- Snippet source
    }, config = function()
        local cmp = require("cmp")
        cmp.setup {
            mapping = {
                ['<Tab>'] = cmp.mapping.select_next_item(),
                ['<S-Tab>'] = cmp.mapping.select_prev_item(),
                ['<CR>'] = cmp.mapping.confirm { select = true },
            },
            sources = {
                { name = 'nvim_lsp' },  -- LSP source
                { name = 'luasnip' },    -- Snippet source
                { name = 'buffer' },     -- Buffer source for text completion
                { name = 'path' },       -- Path completion
            }
        }
    end},

    -- Snippets plugin for autocompletion
    { "L3MON4D3/LuaSnip" },

    -- Surround and autopairing brackets
    { "tpope/vim-surround" },
    { "jiangmiao/auto-pairs" },
})

-- Basic settings
vim.opt.number = true           -- Show line numbers
vim.opt.relativenumber = true   -- Show relative line numbers
vim.opt.tabstop = 4             -- Tab width
vim.opt.shiftwidth = 4          -- Indentation width
vim.opt.expandtab = true        -- Use spaces instead of tabs
vim.opt.termguicolors = true    -- Enable 24-bit RGB colors
vim.g.mapleader = 'f'

-- Colorscheme with black background
vim.g.tokyonight_style = "night"  -- Use the "night" style for a darker background
vim.cmd("colorscheme tokyonight") -- Load tokyonight theme

-- Key mappings for convenience
vim.api.nvim_set_keymap('n', '<leader>ff', '<cmd>Telescope find_files<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>fg', '<cmd>Telescope live_grep<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>aa', ':!python %<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>ok', '<cmd>lua vim.lsp.buf.format({ async = true })<CR>', { noremap = true, silent = true })
-- Key mapping to hide Python errors
vim.api.nvim_set_keymap('n', '<leader>he', '<cmd>lua vim.diagnostic.hide()<CR>', { noremap = true, silent = true })
-- Key mapping to clean and sort imports
vim.api.nvim_set_keymap('n', '<leader>ci', '<cmd>!autoflake --remove-all-unused-imports --in-place % && isort % && ruff format %<CR>', { noremap = true, silent = true })





