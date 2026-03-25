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
vim.opt.clipboard = "unnamedplus"  -- Integrate with Windows clipboard

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
    -- Theme
    { "morhetz/gruvbox" },

    -- Treesitter
    { "nvim-treesitter/nvim-treesitter", build = ":TSUpdate" },
    -- Icons
    { "nvim-tree/nvim-web-devicons", lazy = true },
    { "echasnovski/mini.icons", version = false },
    -- LSP + Completion
    { "neovim/nvim-lspconfig" },
    { "hrsh7th/nvim-cmp" },
    { "hrsh7th/cmp-nvim-lsp" },
    { "L3MON4D3/LuaSnip" },

    -- Formatting & Linting
    { "nvimtools/none-ls.nvim" },

    -- File Explorer
    { "nvim-tree/nvim-tree.lua" },

    -- Status Line
    { "nvim-lualine/lualine.nvim" },

    -- Telescope (Fuzzy Finder + Live Grep)
    { "nvim-telescope/telescope.nvim", dependencies = { "nvim-lua/plenary.nvim" } },

    -- Git Integration
    { "lewis6991/gitsigns.nvim" },

    -- Which-key for leader hints
    { "folke/which-key.nvim" },

    -- Commenting
    { "numToStr/Comment.nvim", config = true },
})

-- ==========================
--  Colors & UI
-- ==========================
vim.cmd("colorscheme gruvbox")
require("lualine").setup({ options = { theme = "gruvbox" } })

-- ==========================
--  NvimTree Setup
-- ==========================
require("nvim-tree").setup()
vim.keymap.set("n", "<leader>e", ":NvimTreeToggle<CR>", { noremap = true, silent = true })

-- ==========================
--  Telescope Setup
-- ==========================
local telescope = require("telescope")
telescope.setup({
    defaults = { layout_strategy = "vertical", layout_config = { height = 0.9 } },
})

-- ==========================
--  Gitsigns Setup
-- ==========================
require("gitsigns").setup({
    signs = {
        add          = { text = "▎" },
        change       = { text = "▎" },
        delete       = { text = "契" },
        topdelete    = { text = "契" },
        changedelete = { text = "▎" },
    },
    current_line_blame = true,
    current_line_blame_opts = { delay = 400, virt_text_pos = "eol" },
})

-- ==========================
--  Which-key Setup (Latest Spec)
-- ==========================
local wk = require("which-key")
wk.setup({})

wk.add({ -- using add() is preferred in 1.6+
    { "<leader>e", "<cmd>NvimTreeToggle<cr>", desc = "File Explorer" },
    { "<leader>f", group = "Find" },
    { "<leader>ff", "<cmd>Telescope find_files<cr>", desc = "Files" },
    { "<leader>fg", "<cmd>Telescope live_grep<cr>", desc = "Live Grep" },
    { "<leader>fb", "<cmd>Telescope buffers<cr>", desc = "Buffers" },
    { "<leader>fh", "<cmd>Telescope help_tags<cr>", desc = "Help" },
})

-- ==========================
--  Diagnostics Setup
-- ==========================
vim.diagnostic.config({
    virtual_text = false,
    signs = true,
    underline = true,
    update_in_insert = false,
    severity_sort = true,
})

vim.api.nvim_create_autocmd("CursorHold", {
    callback = function()
        vim.diagnostic.open_float(nil, { focusable = false, border = "rounded" })
    end,
})

-- ==========================
--  LSP Setup
-- ==========================
local lspconfig = require("lspconfig")
local capabilities = require("cmp_nvim_lsp").default_capabilities()

-- Python
lspconfig.pyright.setup({ capabilities = capabilities })

-- JavaScript / TypeScript
lspconfig.ts_ls.setup({ capabilities = capabilities })

-- JSON
lspconfig.jsonls.setup({ capabilities = capabilities })

-- ==========================
--  Completion Setup
-- ==========================
local cmp = require("cmp")
cmp.setup({
    snippet = { expand = function(args) require("luasnip").lsp_expand(args.body) end },
    mapping = cmp.mapping.preset.insert({
        ["<CR>"] = cmp.mapping.confirm({ select = true }),
        ["<Tab>"] = cmp.mapping.select_next_item(),
        ["<S-Tab>"] = cmp.mapping.select_prev_item(),
    }),
    sources = cmp.config.sources({ { name = "nvim_lsp" } }),
})

-- ==========================
--  Auto Formatting (none-ls)
-- ==========================
local null_ls = require("null-ls")
null_ls.setup({
    sources = {
        null_ls.builtins.formatting.black,      -- Python
        null_ls.builtins.formatting.prettier,   -- JS / TS / JSON
    },
    on_attach = function(client, bufnr)
        if client.supports_method("textDocument/formatting") then
            vim.api.nvim_create_autocmd("BufWritePre", {
                buffer = bufnr,
                callback = function() vim.lsp.buf.format({ async = false }) end,
            })
        end
    end,
})

