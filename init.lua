-- ~/.config/nvim/init.lua
-- Self-bootstrapping Neovim config using lazy.nvim

-----------------------------------------------------------
-- Leader keys (must be set before lazy)
-----------------------------------------------------------
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-----------------------------------------------------------
-- Core options
-----------------------------------------------------------
local opt = vim.opt
opt.number = true
opt.relativenumber = true
opt.mouse = "a"
opt.clipboard = "unnamedplus"
opt.breakindent = true
opt.undofile = true
opt.ignorecase = true
opt.smartcase = true
opt.signcolumn = "yes"
opt.updatetime = 250
opt.timeoutlen = 300
opt.splitright = true
opt.splitbelow = true
opt.list = true
opt.listchars = { tab = "» ", trail = "·", nbsp = "␣" }
opt.inccommand = "split"
opt.cursorline = true
opt.scrolloff = 8
opt.termguicolors = true
opt.expandtab = true
opt.shiftwidth = 2
opt.tabstop = 2
opt.softtabstop = 2
opt.smartindent = true
opt.wrap = false

-----------------------------------------------------------
-- Diagnostics appearance
-----------------------------------------------------------
vim.diagnostic.config({
  virtual_text = { prefix = "●" },
  signs = {
    text = {
      [vim.diagnostic.severity.ERROR] = "✘",
      [vim.diagnostic.severity.WARN] = "▲",
      [vim.diagnostic.severity.HINT] = "⚑",
      [vim.diagnostic.severity.INFO] = "»",
    },
  },
  underline = true,
  update_in_insert = false,
  severity_sort = true,
  float = { border = "rounded", source = true },
})

-----------------------------------------------------------
-- Basic keymaps
-----------------------------------------------------------
local map = vim.keymap.set
map("n", "<Esc>", "<cmd>nohlsearch<CR>")
map("n", "<leader>w", "<cmd>write<CR>", { desc = "Save" })
map("n", "<leader>q", "<cmd>quit<CR>", { desc = "Quit" })
-- Window navigation
map("n", "<C-h>", "<C-w>h", { desc = "Move to left window" })
map("n", "<C-l>", "<C-w>l", { desc = "Move to right window" })
map("n", "<C-j>", "<C-w>j", { desc = "Move to lower window" })
map("n", "<C-k>", "<C-w>k", { desc = "Move to upper window" })
-- Move lines
map("v", "J", ":m '>+1<CR>gv=gv", { desc = "Move selection down" })
map("v", "K", ":m '<-2<CR>gv=gv", { desc = "Move selection up" })
-- Keep cursor centered when scrolling / searching
map("n", "<C-d>", "<C-d>zz")
map("n", "<C-u>", "<C-u>zz")
map("n", "n", "nzzzv")
map("n", "N", "Nzzzv")
-- Better indenting (stay in visual mode)
map("v", "<", "<gv")
map("v", ">", ">gv")
-- Run current Python file
map("n", "<leader>rp", "<cmd>w<CR><cmd>!python3 %<CR>", { desc = "[R]un [P]ython file" })
-- Diagnostics
map("n", "<leader>dd", function() vim.diagnostic.enable(false) end, { desc = "[D]isable [D]iagnostics" })
map("n", "<leader>de", function() vim.diagnostic.enable(true) end, { desc = "[D]iagnostics [E]nable" })
map("n", "<leader>dl", vim.diagnostic.open_float, { desc = "[D]iagnostic [L]ine float" })
map("n", "[d", function() vim.diagnostic.jump({ count = -1, float = true }) end, { desc = "Prev diagnostic" })
map("n", "]d", function() vim.diagnostic.jump({ count = 1, float = true }) end, { desc = "Next diagnostic" })

-----------------------------------------------------------
-- Bootstrap lazy.nvim
-----------------------------------------------------------
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local repo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", repo, lazypath })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({ { "Failed to clone lazy.nvim:\n", "ErrorMsg" }, { out, "WarningMsg" } }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)

-----------------------------------------------------------
-- Plugins
-----------------------------------------------------------
require("lazy").setup({
  -- Colorscheme
  {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000,
    config = function()
      require("catppuccin").setup({ flavour = "mocha" })
      vim.cmd.colorscheme("catppuccin")
    end,
  },

  -- Detect tabstop/shiftwidth automatically
  "tpope/vim-sleuth",

  -- Git signs in the gutter
  {
    "lewis6991/gitsigns.nvim",
    opts = {
      signs = {
        add = { text = "+" },
        change = { text = "~" },
        delete = { text = "_" },
        topdelete = { text = "‾" },
        changedelete = { text = "~" },
      },
    },
  },

  -- Which-key: shows keybindings
  { "folke/which-key.nvim", event = "VeryLazy", opts = {} },

  -- Telescope: fuzzy finder
  {
    "nvim-telescope/telescope.nvim",
    event = "VimEnter",
    branch = "0.1.x",
    dependencies = {
      "nvim-lua/plenary.nvim",
      { "nvim-telescope/telescope-fzf-native.nvim", build = "make", cond = function() return vim.fn.executable("make") == 1 end },
      "nvim-telescope/telescope-ui-select.nvim",
    },
    config = function()
      require("telescope").setup({
        extensions = { ["ui-select"] = { require("telescope.themes").get_dropdown() } },
      })
      pcall(require("telescope").load_extension, "fzf")
      pcall(require("telescope").load_extension, "ui-select")
      local builtin = require("telescope.builtin")
      map("n", "<leader>sf", builtin.find_files, { desc = "[S]earch [F]iles" })
      map("n", "<leader>sg", builtin.live_grep, { desc = "[S]earch by [G]rep" })
      map("n", "<leader>sh", builtin.help_tags, { desc = "[S]earch [H]elp" })
      map("n", "<leader>sk", builtin.keymaps, { desc = "[S]earch [K]eymaps" })
      map("n", "<leader><leader>", builtin.buffers, { desc = "Find buffers" })
      map("n", "<leader>sd", builtin.diagnostics, { desc = "[S]earch [D]iagnostics" })
    end,
  },

  -- LSP: mason + lspconfig
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      { "williamboman/mason.nvim", opts = {} },
      "williamboman/mason-lspconfig.nvim",
      "WhoIsSethDaniel/mason-tool-installer.nvim",
      { "j-hui/fidget.nvim", opts = {} },
      "hrsh7th/cmp-nvim-lsp",
    },
    config = function()
      vim.api.nvim_create_autocmd("LspAttach", {
        callback = function(event)
          local lmap = function(keys, fn, desc)
            map("n", keys, fn, { buffer = event.buf, desc = "LSP: " .. desc })
          end
          local builtin = require("telescope.builtin")
          lmap("gd", builtin.lsp_definitions, "[G]oto [D]efinition")
          lmap("gr", builtin.lsp_references, "[G]oto [R]eferences")
          lmap("gI", builtin.lsp_implementations, "[G]oto [I]mplementation")
          lmap("gD", vim.lsp.buf.declaration, "[G]oto [D]eclaration")
          lmap("<leader>D", builtin.lsp_type_definitions, "Type [D]efinition")
          lmap("<leader>rn", vim.lsp.buf.rename, "[R]e[n]ame")
          lmap("<leader>ca", vim.lsp.buf.code_action, "[C]ode [A]ction")
          lmap("K", vim.lsp.buf.hover, "Hover Documentation")
        end,
      })

      local capabilities = require("cmp_nvim_lsp").default_capabilities()
      local servers = {
        lua_ls = {
          settings = { Lua = { diagnostics = { globals = { "vim" } } } },
        },
        -- Python: pyright for types/intelligence, ruff for fast lint/format
        pyright = {
          settings = {
            pyright = { disableOrganizeImports = true },
            python = { analysis = { typeCheckingMode = "basic", autoSearchPaths = true } },
          },
        },
        ruff = {},
        -- C / C++
        clangd = {
          cmd = { "clangd", "--background-index", "--clang-tidy", "--header-insertion=never" },
        },
        -- JavaScript / TypeScript
        ts_ls = {},
        eslint = {
          settings = { workingDirectories = { mode = "auto" } },
        },
      }
      require("mason").setup()
      local ensure = vim.tbl_keys(servers)
      vim.list_extend(ensure, {
        "stylua",
        "clang-format",
        "prettierd",
        "codelldb",
      })
      require("mason-tool-installer").setup({ ensure_installed = ensure })
      require("mason-lspconfig").setup({
        automatic_enable = { exclude = { "rust_analyzer" } },
        handlers = {
          function(server_name)
            if server_name == "rust_analyzer" then return end
            local server = servers[server_name] or {}
            server.capabilities = vim.tbl_deep_extend("force", {}, capabilities, server.capabilities or {})
            require("lspconfig")[server_name].setup(server)
          end,
        },
      })
    end,
  },

  -- Autoformat
  {
    "stevearc/conform.nvim",
    event = { "BufWritePre" },
    cmd = { "ConformInfo" },
    keys = {
      { "<leader>f", function() require("conform").format({ async = true, lsp_format = "fallback" }) end, desc = "[F]ormat buffer" },
    },
    opts = {
      notify_on_error = false,
      format_on_save = function(bufnr)
        if vim.api.nvim_buf_line_count(bufnr) > 5000 then return end
        return { timeout_ms = 500, lsp_format = "fallback" }
      end,
      formatters_by_ft = {
        lua = { "stylua" },
        python = { "ruff_organize_imports", "ruff_format" },
        c = { "clang_format" },
        cpp = { "clang_format" },
        rust = { "rustfmt", lsp_format = "fallback" },
        javascript = { "prettierd", "prettier", stop_after_first = true },
        javascriptreact = { "prettierd", "prettier", stop_after_first = true },
        typescript = { "prettierd", "prettier", stop_after_first = true },
        typescriptreact = { "prettierd", "prettier", stop_after_first = true },
        json = { "prettierd", "prettier", stop_after_first = true },
        jsonc = { "prettierd", "prettier", stop_after_first = true },
        css = { "prettierd", "prettier", stop_after_first = true },
        html = { "prettierd", "prettier", stop_after_first = true },
        yaml = { "prettierd", "prettier", stop_after_first = true },
        markdown = { "prettierd", "prettier", stop_after_first = true },
      },
    },
  },

  -- Completion
  {
    "hrsh7th/nvim-cmp",
    event = "InsertEnter",
    dependencies = {
      {
        "L3MON4D3/LuaSnip",
        build = (function()
          if vim.fn.has("win32") == 1 or vim.fn.executable("make") == 0 then return end
          return "make install_jsregexp"
        end)(),
      },
      "saadparwaiz1/cmp_luasnip",
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-path",
      "hrsh7th/cmp-buffer",
    },
    config = function()
      local cmp = require("cmp")
      local luasnip = require("luasnip")
      luasnip.config.setup({})
      cmp.setup({
        snippet = { expand = function(args) luasnip.lsp_expand(args.body) end },
        completion = { completeopt = "menu,menuone,noinsert" },
        mapping = cmp.mapping.preset.insert({
          ["<C-n>"] = cmp.mapping.select_next_item(),
          ["<C-p>"] = cmp.mapping.select_prev_item(),
          ["<C-b>"] = cmp.mapping.scroll_docs(-4),
          ["<C-f>"] = cmp.mapping.scroll_docs(4),
          ["<C-y>"] = cmp.mapping.confirm({ select = true }),
          ["<CR>"] = cmp.mapping.confirm({ select = true }),
          ["<C-Space>"] = cmp.mapping.complete({}),
        }),
        sources = {
          { name = "nvim_lsp" },
          { name = "luasnip" },
          { name = "path" },
          { name = "buffer" },
          { name = "crates" },
        },
      })
    end,
  },

  -- Treesitter
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "master",
    build = ":TSUpdate",
    main = "nvim-treesitter.configs",
    opts = {
      ensure_installed = {
        "bash", "c", "cpp", "diff", "html", "lua", "luadoc", "markdown",
        "markdown_inline", "python", "query", "vim", "vimdoc",
        "json", "jsonc", "yaml", "toml", "javascript", "typescript",
        "tsx", "css", "rust",
      },
      auto_install = true,
      highlight = { enable = true },
      indent = { enable = true },
    },
  },

  -- Statusline
  {
    "nvim-lualine/lualine.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    opts = { options = { theme = "catppuccin", globalstatus = true } },
  },

  -- File explorer
  {
    "nvim-tree/nvim-tree.lua",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("nvim-tree").setup({})
      map("n", "<leader>e", "<cmd>NvimTreeToggle<CR>", { desc = "Toggle file [E]xplorer" })
    end,
  },

  -- Autopairs
  { "windwp/nvim-autopairs", event = "InsertEnter", opts = {} },

  -- Comment toggling (gcc / gc)
  { "numToStr/Comment.nvim", opts = {} },

  -- Indentation guides
  { "lukas-reineke/indent-blankline.nvim", main = "ibl", opts = {} },

  -- Mini utilities (surround, ai textobjects)
  {
    "echasnovski/mini.nvim",
    config = function()
      require("mini.ai").setup({ n_lines = 500 })
      require("mini.surround").setup()
    end,
  },

  -----------------------------------------------------------
  -- Rust: rustaceanvim wraps rust-analyzer with extra features
  -----------------------------------------------------------
  {
    "mrcjkb/rustaceanvim",
    version = "^6",
    lazy = false,
    ft = { "rust" },
    config = function()
      vim.g.rustaceanvim = {
        server = {
          on_attach = function(_, bufnr)
            local lmap = function(keys, fn, desc)
              map("n", keys, fn, { buffer = bufnr, desc = "Rust: " .. desc })
            end
            lmap("<leader>rr", function() vim.cmd.RustLsp("runnables") end, "[R]un [R]unnables")
            lmap("<leader>rt", function() vim.cmd.RustLsp("testables") end, "[R]un [T]estables")
            lmap("<leader>rm", function() vim.cmd.RustLsp("expandMacro") end, "Expand [M]acro")
            lmap("<leader>rc", function() vim.cmd.RustLsp("openCargo") end, "Open [C]argo.toml")
            lmap("K", function() vim.cmd.RustLsp({ "hover", "actions" }) end, "Hover Actions")
            lmap("<leader>ca", function() vim.cmd.RustLsp("codeAction") end, "[C]ode [A]ction")
          end,
          default_settings = {
            ["rust-analyzer"] = {
              cargo = { allFeatures = true },
              checkOnSave = true,
              check = { command = "clippy" },
              procMacro = { enable = true },
            },
          },
        },
      }
    end,
  },

  -- Crates: manage Cargo.toml dependencies
  {
    "saecki/crates.nvim",
    event = { "BufRead Cargo.toml" },
    opts = {
      completion = { cmp = { enabled = true } },
    },
  },

  -- Better TypeScript/JS DX: package.json info + commands
  {
    "vuki656/package-info.nvim",
    dependencies = { "MunifTanjim/nui.nvim" },
    event = { "BufRead package.json" },
    opts = {},
  },
}, {
  ui = { icons = vim.g.have_nerd_font and {} or {
    cmd = "⌘", config = "🛠", event = "📅", ft = "📂", init = "⚙",
    keys = "🗝", plugin = "🔌", runtime = "💻", require = "🌙",
    source = "📄", start = "🚀", task = "📌", lazy = "💤 ",
  } },
})

-- vim: ts=2 sts=2 sw=2 et
