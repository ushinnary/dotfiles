vim.g.mapleader = " "
vim.opt.relativenumber = true
vim.opt.number = true

vim.opt.smartindent = true

vim.opt.wrap = false

-- vim.opt.hlsearch = false
vim.opt.termguicolors = true
vim.opt.updatetime = 50

vim.opt.colorcolumn = "80"
vim.cmd [[colorscheme tokyonight]]
vim.g.nord_contrast = true
vim.g.nord_borders = true
vim.g.nord_italic = false

-- require('nord').set()
vim.g.neoformat_try_node_exe = 1
--vim.g.neoformat_run_all_formatters = 1
vim.g.neoformat_try_formatprg = 1
--vim.g.neoformat_enabled_lua = { "luaformatter" }
vim.g.neoformat_enabled_typescript = { "prettier", "eslint_d" }
vim.g.neoformat_enabled_vue = { "prettier" }

