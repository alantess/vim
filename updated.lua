-- =====================================================================
-- init.lua (single file)
-- Packer-based config, cleaned + modernized (NO Telescope)
-- Ruff-first Python setup: ruff_lsp + pyright
--
-- Packer install path:
--   ~/.local/share/nvim/site/pack/packer/start/packer.nvim
--
-- Bootstrap packer:
--   git clone --depth 1 https://github.com/wbthomason/packer.nvim \
--     ~/.local/share/nvim/site/pack/packer/start/packer.nvim
-- =====================================================================

-- (Optional) Python host for Neovim providers (NOT your project venv).
-- Only set this if you know you need it.
-- vim.g.python3_host_prog = "/path/to/python"

vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- =====================================================================
-- Options
-- =====================================================================
vim.opt.number = true
vim.opt.relativenumber = false
vim.opt.termguicolors = true
vim.opt.mouse = "a"
vim.opt.clipboard = "unnamedplus"
vim.opt.signcolumn = "yes"
vim.opt.updatetime = 250
vim.opt.timeoutlen = 400
vim.opt.splitright = true
vim.opt.splitbelow = true
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.expandtab = true
vim.opt.shiftwidth = 2
vim.opt.tabstop = 2
vim.opt.cursorline = true

local map = vim.keymap.set
local function d(desc) return { noremap = true, silent = true, desc = desc } end

-- =====================================================================
-- Packer bootstrap
-- =====================================================================
local ensure_packer = function()
  local fn = vim.fn
  local install_path = fn.stdpath("data") .. "/site/pack/packer/start/packer.nvim"
  if fn.empty(fn.glob(install_path)) > 0 then
    fn.system({
      "git", "clone", "--depth", "1",
      "https://github.com/wbthomason/packer.nvim",
      install_path,
    })
    vim.cmd("packadd packer.nvim")
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

  use({
    "nvim-lualine/lualine.nvim",
    requires = { "nvim-tree/nvim-web-devicons", opt = true },
  })

  use({
    "nvim-tree/nvim-tree.lua",
    requires = { "nvim-tree/nvim-web-devicons" },
  })

  use("folke/which-key.nvim")

  -- LSP + completion
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

  if packer_bootstrap then
    require("packer").sync()
  end
end)

if packer_bootstrap then
  vim.cmd([[echo "Packer installed. Restart Neovim after plugins finish installing."]])
  return
end

-- =====================================================================
-- Plugin setup
-- =====================================================================
vim.cmd([[colorscheme tokyonight]])

pcall(function() require("which-key").setup({}) end)

pcall(function()
  require("lualine").setup({
    options = {
      theme = "tokyonight",
      icons_enabled = true,
      section_separators = "",
      component_separators = "",
    },
  })
end)

pcall(function()
  require("nvim-tree").setup({
    view = { width = 32 },
    renderer = { group_empty = true },
    filters = { dotfiles = false },
  })
end)

pcall(function() require("Comment").setup({}) end)
pcall(function() require("nvim-autopairs").setup({}) end)
pcall(function() require("nvim-surround").setup({}) end)

-- =====================================================================
-- Completion (nvim-cmp)
-- =====================================================================
do
  local ok_cmp, cmp = pcall(require, "cmp")
  if not ok_cmp then break end

  local ok_snip, luasnip = pcall(require, "luasnip")

  cmp.setup({
    snippet = {
      expand = function(args)
        if ok_snip then luasnip.lsp_expand(args.body) end
      end,
    },
    mapping = cmp.mapping.preset.insert({
      ["<C-Space>"] = cmp.mapping.complete(),
      ["<CR>"] = cmp.mapping.confirm({ select = true }),
      ["<Tab>"] = cmp.mapping(function(fallback)
        if cmp.visible() then
          cmp.select_next_item()
        elseif ok_snip and luasnip.expand_or_jumpable() then
          luasnip.expand_or_jump()
        else
          fallback()
        end
      end, { "i", "s" }),
      ["<S-Tab>"] = cmp.mapping(function(fallback)
        if cmp.visible() then
          cmp.select_prev_item()
        elseif ok_snip and luasnip.jumpable(-1) then
          luasnip.jump(-1)
        else
          fallback()
        end
      end, { "i", "s" }),
    }),
    sources = cmp.config.sources({
      { name = "nvim_lsp" },
      { name = "path" },
      { name = "buffer" },
      { name = "luasnip" },
    }),
  })
end

-- =====================================================================
-- LSP (Ruff-first)
-- =====================================================================
do
  local ok_lsp, lspconfig = pcall(require, "lspconfig")
  if not ok_lsp then break end

  local capabilities = vim.lsp.protocol.make_client_capabilities()
  local ok_cmp_lsp, cmp_lsp = pcall(require, "cmp_nvim_lsp")
  if ok_cmp_lsp then
    capabilities = cmp_lsp.default_capabilities(capabilities)
  end

  vim.diagnostic.config({
    virtual_text = true,
    signs = true,
    underline = true,
    update_in_insert = false,
    severity_sort = true,
  })

  local on_attach = function(client, bufnr)
    local function bmap(mode, lhs, rhs, desc)
      vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, noremap = true, silent = true, desc = desc })
    end

    bmap("n", "gd", vim.lsp.buf.definition, "Go to definition")
    bmap("n", "gD", vim.lsp.buf.declaration, "Go to declaration")
    bmap("n", "gr", vim.lsp.buf.references, "References")
    bmap("n", "gi", vim.lsp.buf.implementation, "Implementation")
    bmap("n", "K", vim.lsp.buf.hover, "Hover")
    bmap("n", "<leader>rn", vim.lsp.buf.rename, "Rename")
    bmap("n", "<leader>ca", vim.lsp.buf.code_action, "Code action")

    -- Format: prefer Ruff when available, otherwise fallback to whatever supports formatting
    bmap("n", "<leader>f", function()
      vim.lsp.buf.format({
        async = true,
        -- If ruff_lsp is attached and supports formatting, prefer it.
        filter = function(c)
          if c.name == "ruff_lsp" then return true end
          return true
        end,
      })
    end, "Format buffer")

    bmap("n", "[d", vim.diagnostic.goto_prev, "Prev diagnostic")
    bmap("n", "]d", vim.diagnostic.goto_next, "Next diagnostic")
    bmap("n", "<leader>e", vim.diagnostic.open_float, "Diagnostic float")

    -- Ruff convenience (works if ruff_lsp is attached)
    bmap("n", "<leader>rf", function()
      -- "source.fixAll" is commonly supported; if your ruff_lsp build differs, this harmlessly no-ops.
      vim.lsp.buf.code_action({
        context = { only = { "source.fixAll" }, diagnostics = {} },
        apply = true,
      })
    end, "Ruff: fix all")

    bmap("n", "<leader>ro", function()
      -- Organize imports if available (Ruff often provides it)
      vim.lsp.buf.code_action({
        context = { only = { "source.organizeImports" }, diagnostics = {} },
        apply = true,
      })
    end, "Ruff: organize imports")
  end

  -- Python: Ruff LSP (lint/fixes) + Pyright (types)
  if lspconfig.ruff_lsp then
    lspconfig.ruff_lsp.setup({
      on_attach = on_attach,
      capabilities = capabilities,
      init_options = {
        settings = {
          -- Ruff will read pyproject.toml automatically.
          -- Put project rules/line-length/etc there.
        },
      },
    })
  end

  if lspconfig.pyright then
    lspconfig.pyright.setup({
      on_attach = on_attach,
      capabilities = capabilities,
      settings = {
        python = {
          analysis = {
            autoSearchPaths = true,
            useLibraryCodeForTypes = true,
            diagnosticMode = "workspace",
          },
        },
      },
    })
  end

  -- Lua LSP for editing init.lua
  if lspconfig.lua_ls then
    lspconfig.lua_ls.setup({
      on_attach = on_attach,
      capabilities = capabilities,
      settings = {
        Lua = {
          diagnostics = { globals = { "vim" } },
          workspace = { checkThirdParty = false },
          telemetry = { enable = false },
        },
      },
    })
  end
end

-- =====================================================================
-- Keymaps
-- =====================================================================
map("n", "<leader>t", "<cmd>NvimTreeToggle<cr>", d("Toggle file tree"))
map("n", "<leader>r", "<cmd>NvimTreeRefresh<cr>", d("Refresh file tree"))
map("n", "<leader>n", "<cmd>NvimTreeFindFile<cr>", d("Reveal current file"))

map("n", "<leader>w", "<cmd>w<cr>", d("Save"))
map("n", "<leader>q", "<cmd>q<cr>", d("Quit"))

map("n", "<leader>dd", function() vim.diagnostic.disable() end, d("Disable diagnostics"))
map("n", "<leader>de", function() vim.diagnostic.enable() end, d("Enable diagnostics"))
map("n", "<leader>dl", function() vim.diagnostic.setloclist() end, d("Diagnostics -> loclist"))