-- =====================================================================
-- init.lua (Single File - Fixed & Modernized)
-- =====================================================================

vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- =====================================================================
-- Options
-- =====================================================================
local opt = vim.opt
opt.number = true
opt.relativenumber = false
opt.termguicolors = true
opt.mouse = "a"
opt.clipboard = "unnamedplus"
opt.signcolumn = "yes"
opt.updatetime = 250
opt.timeoutlen = 400
opt.splitright = true
opt.splitbelow = true
opt.ignorecase = true
opt.smartcase = true
opt.expandtab = true
opt.shiftwidth = 2
opt.tabstop = 2
opt.cursorline = true

-- =====================================================================
-- Packer Bootstrap
-- =====================================================================
local ensure_packer = function()
  local fn = vim.fn
  local install_path = fn.stdpath("data") .. "/site/pack/packer/start/packer.nvim"
  if fn.empty(fn.glob(install_path)) > 0 then
    fn.system({ "git", "clone", "--depth", "1", "https://github.com/wbthomason/packer.nvim", install_path })
    vim.cmd([[packadd packer.nvim]])
    return true
  end
  return false
end

local packer_bootstrap = ensure_packer()

-- =====================================================================
-- Plugins
-- =====================================================================
require("packer").startup(function(use)
  use("wbthomason/packer.nvim")
  use("folke/tokyonight.nvim")
  use({ "nvim-lualine/lualine.nvim", requires = { "nvim-tree/nvim-web-devicons", opt = true } })
  use({ "nvim-tree/nvim-tree.lua", requires = { "nvim-tree/nvim-web-devicons" } })
  use("folke/which-key.nvim")

  -- LSP + Completion
  use("neovim/nvim-lspconfig")
  use("hrsh7th/nvim-cmp")
  use("hrsh7th/cmp-nvim-lsp")
  use("hrsh7th/cmp-buffer")
  use("hrsh7th/cmp-path")
  use("L3MON4D3/LuaSnip")
  use("saadparwaiz1/cmp_luasnip")

  -- Editing QoL
  use("numToStr/Comment.nvim")
  use("windwp/nvim-autopairs")
  use("kylechui/nvim-surround")

  if packer_bootstrap then require("packer").sync() end
end)

if packer_bootstrap then return end

-- =====================================================================
-- Plugin Setup
-- =====================================================================
vim.cmd([[colorscheme tokyonight]])

require("which-key").setup({})
require("lualine").setup({ options = { theme = "tokyonight", section_separators = "", component_separators = "" } })
require("nvim-tree").setup({ view = { width = 30 }, renderer = { group_empty = true } })
require("Comment").setup({})
require("nvim-autopairs").setup({})
require("nvim-surround").setup({})

-- =====================================================================
-- Completion (nvim-cmp) - Logic Fixed
-- =====================================================================
local cmp_status, cmp = pcall(require, "cmp")
if cmp_status then
  local luasnip = require("luasnip")
  cmp.setup({
    snippet = { expand = function(args) luasnip.lsp_expand(args.body) end },
    mapping = cmp.mapping.preset.insert({
      ["<C-Space>"] = cmp.mapping.complete(),
      ["<CR>"] = cmp.mapping.confirm({ select = true }),
      ["<Tab>"] = cmp.mapping(function(fallback)
        if cmp.visible() then cmp.select_next_item()
        elseif luasnip.expand_or_jumpable() then luasnip.expand_or_jump()
        else fallback() end
      end, { "i", "s" }),
      ["<S-Tab>"] = cmp.mapping(function(fallback)
        if cmp.visible() then cmp.select_prev_item()
        elseif luasnip.jumpable(-1) then luasnip.jump(-1)
        else fallback() end
      end, { "i", "s" }),
    }),
    sources = cmp.config.sources({
      { name = "nvim_lsp" },
      { name = "luasnip" },
      { name = "path" },
      { name = "buffer" },
    }),
  })
end

-- =====================================================================
-- LSP Setup (Ruff & Pyright)
-- =====================================================================
local lsp_status, lspconfig = pcall(require, "lspconfig")
if lsp_status then
  local capabilities = require("cmp_nvim_lsp").default_capabilities()

  local on_attach = function(client, bufnr)
    local bmap = function(mode, lhs, rhs, desc)
      vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, silent = true, desc = desc })
    end

    bmap("n", "gd", vim.lsp.buf.definition, "Go to definition")
    bmap("n", "K", vim.lsp.buf.hover, "Hover")
    bmap("n", "<leader>rn", vim.lsp.buf.rename, "Rename")
    bmap("n", "<leader>ca", vim.lsp.buf.code_action, "Code action")
    bmap("n", "<leader>f", function() vim.lsp.buf.format({ async = true }) end, "Format")
  end

  -- Note: 'ruff_lsp' is deprecated in favor of 'ruff'
  local servers = { "pyright", "ruff", "lua_ls" }
  for _, lsp in ipairs(servers) do
    lspconfig[lsp].setup({
      on_attach = on_attach,
      capabilities = capabilities,
    })
  end
end

-- =====================================================================
-- Keymaps
-- =====================================================================
local map = vim.keymap.set
map("n", "<leader>t", "<cmd>NvimTreeToggle<cr>", { desc = "Toggle Tree" })
map("n", "<leader>w", "<cmd>w<cr>", { desc = "Save" })
map("n", "<leader>q", "<cmd>q<cr>", { desc = "Quit" })

-- Diagnostic toggles
map("n", "<leader>dd", function() vim.diagnostic.enable(false) end, { desc = "Disable Diagnostics" })
map("n", "<leader>de", function() vim.diagnostic.enable(true) end, { desc = "Enable Diagnostics" })
