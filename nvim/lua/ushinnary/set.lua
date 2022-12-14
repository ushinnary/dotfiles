vim.g.mapleader = " "
vim.opt.relativenumber = true
vim.opt.number = true
vim.opt.ignorecase = true

vim.opt.smartindent = true

vim.opt.wrap = false
vim.opt.cursorline = true

-- vim.opt.hlsearch = false
vim.opt.termguicolors = true
vim.opt.updatetime = 50

vim.opt.colorcolumn = "80"
vim.opt.listchars = { eol = "↲", tab = "▸ ", trail = "·" }
vim.opt.list = true

vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
-- Theming
--local handle = io.popen("gsettings get org.gnome.desktop.interface color-scheme")
--local result = handle:read("*a")
---- Gnome 42+
--if string.find(result, "default") then
--	vim.o.background = "light"
--else
--	vim.o.background = "dark"
--end
--handle:close()

vim.cmd.colorscheme("tokyonight-night")
--vim.api.nvim_set_hl(0, "Normal", { bg = "none" })
--vim.api.nvim_set_hl(0, "NormalFloat", { bg = "none" })

vim.g.neoformat_try_node_exe = 1
vim.g.neoformat_try_formatprg = 1

--vim.opt.foldmethod = "expr"
vim.opt.foldexpr = "nvim_treesitter#foldexpr()"
vim.opt.termguicolors = true
vim.notify = require("notify")
-- Virtual text
vim.lsp.handlers["textDocument/publishDiagnostics"] = vim.lsp.with(vim.lsp.diagnostic.on_publish_diagnostics, {
	virtual_text = false,
})

local signs = {
	Error = " ",
	Warning = " ",
	Hint = " ",
	Information = " ",
}

for type, icon in pairs(signs) do
	local hl = "LspDiagnosticsSign" .. type
	vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = "" })
end
