-- ==========================
--  Core Settings
-- ==========================
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
vim.opt.smartindent = true
vim.opt.termguicolors = true
vim.opt.cursorline = true
vim.opt.wrap = false
vim.opt.clipboard = "unnamedplus"

vim.g.mapleader = " "
vim.opt.updatetime = 300
vim.opt.timeoutlen = 400

-- ==========================
--  Plugin Manager: lazy.nvim
-- ==========================
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
    vim.fn.system({
        "git", "clone", "--filter=blob:none",
        "https://github.com/folke/lazy.nvim.git",
        "--branch=stable", lazypath
    })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
    { "morhetz/gruvbox" },

    { "nvim-treesitter/nvim-treesitter", build = ":TSUpdate" },
    { "nvim-tree/nvim-web-devicons", lazy = true },

    -- LSP + tooling
    { "neovim/nvim-lspconfig" },
    { "williamboman/mason.nvim", config = true },
    { "williamboman/mason-lspconfig.nvim" },

    -- Completion
    { "hrsh7th/nvim-cmp" },
    { "hrsh7th/cmp-nvim-lsp" },
    { "L3MON4D3/LuaSnip" },

    -- UI / tools
    { "nvim-tree/nvim-tree.lua" },
    { "nvim-lualine/lualine.nvim" },
    { "nvim-telescope/telescope.nvim", dependencies = { "nvim-lua/plenary.nvim" } },
    { "lewis6991/gitsigns.nvim" },
    { "folke/which-key.nvim" },
    { "numToStr/Comment.nvim", config = true },
})

-- ==========================
--  Colors & UI
-- ==========================
vim.cmd("colorscheme gruvbox")
require("lualine").setup({ options = { theme = "gruvbox" } })

-- ==========================
--  NvimTree
-- ==========================
require("nvim-tree").setup()
vim.keymap.set("n", "<leader>e", ":NvimTreeToggle<CR>", { silent = true })

-- ==========================
--  Telescope
-- ==========================
require("telescope").setup({
    defaults = {
        layout_strategy = "vertical",
        layout_config = { height = 0.9 },
    },
})

-- ==========================
--  Gitsigns
-- ==========================
require("gitsigns").setup({
    current_line_blame = true,
})

-- ==========================
--  Which-key
-- ==========================
local wk = require("which-key")
wk.setup()

wk.add({
    { "<leader>e", "<cmd>NvimTreeToggle<cr>", desc = "Explorer" },
    { "<leader>f", group = "Find" },
    { "<leader>ff", "<cmd>Telescope find_files<cr>", desc = "Files" },
    { "<leader>fg", "<cmd>Telescope live_grep<cr>", desc = "Grep" },
})

-- ==========================
--  Diagnostics UI
-- ==========================
vim.diagnostic.config({
    virtual_text = false,
    signs = true,
    underline = true,
    severity_sort = true,
})

vim.api.nvim_create_autocmd("CursorHold", {
    callback = function()
        vim.diagnostic.open_float(nil, { border = "rounded", focusable = false })
    end,
})

-- ==========================
--  Mason (tool install)
-- ==========================
require("mason-lspconfig").setup({
    ensure_installed = {
        "pyright",
        "ruff",
        "ts_ls",
        "jsonls",
    },
})

-- ==========================
--  LSP Setup (modern API)
-- ==========================
local capabilities = require("cmp_nvim_lsp").default_capabilities()

-- global defaults
vim.lsp.config("*", {
    capabilities = capabilities,
})

-- python: use ruff for formatting, pyright for types
vim.lsp.config("pyright", {
    settings = {
        python = {
            analysis = {
                typeCheckingMode = "basic",
            },
        },
    },
})

-- enable servers
vim.lsp.enable({
    "ruff",
    "pyright",
    "ts_ls",
    "jsonls",
})

-- ==========================
--  LSP Keymaps
-- ==========================
vim.api.nvim_create_autocmd("LspAttach", {
    callback = function(args)
        local map = function(lhs, rhs)
            vim.keymap.set("n", lhs, rhs, { buffer = args.buf })
        end

        map("gd", vim.lsp.buf.definition)
        map("gr", vim.lsp.buf.references)
        map("K", vim.lsp.buf.hover)
        map("<leader>rn", vim.lsp.buf.rename)
        map("<leader>ca", vim.lsp.buf.code_action)
    end,
})

-- ==========================
--  Completion (cmp)
-- ==========================
local cmp = require("cmp")

cmp.setup({
    snippet = {
        expand = function(args)
            require("luasnip").lsp_expand(args.body)
        end,
    },
    mapping = cmp.mapping.preset.insert({
        ["<CR>"] = cmp.mapping.confirm({ select = true }),
        ["<Tab>"] = cmp.mapping.select_next_item(),
        ["<S-Tab>"] = cmp.mapping.select_prev_item(),
        ["<C-Space>"] = cmp.mapping.complete(),
    }),
    sources = {
        { name = "nvim_lsp" },
    },
})

-- ==========================
--  Format on Save (native)
-- ==========================
vim.api.nvim_create_autocmd("BufWritePre", {
    callback = function(args)
        vim.lsp.buf.format({
            bufnr = args.buf,
            timeout_ms = 2000,
            filter = function(client)
                if vim.bo[args.buf].filetype == "python" then
                    return client.name == "ruff"
                end
                return true
            end,
        })
    end,
})
