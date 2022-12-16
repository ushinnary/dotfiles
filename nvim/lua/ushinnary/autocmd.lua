local cmd = vim.cmd
local api = vim.api

local fmtGroup = api.nvim_create_augroup("fmt", { clear = true })
api.nvim_create_autocmd("BufWritePre", {
	command = "undojoin | Neoformat",
	group = fmtGroup,
})
api.nvim_create_autocmd("LspAttach", {
	callback = function(args)
		vim.notify("LSP Attached", "info", {
			title = "LSP Status",
			timeout = 1000,
		})
	end,
})
