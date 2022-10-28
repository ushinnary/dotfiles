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

vim.cmd.colorscheme("catppuccin")

vim.g.neoformat_try_node_exe = 1
vim.g.neoformat_try_formatprg = 1

--vim.opt.foldmethod = "expr"
vim.opt.foldexpr = "nvim_treesitter#foldexpr()"

-- Disable virtual_text since it's redundant due to lsp_lines.
vim.diagnostic.config({
	virtual_text = false,
})
