local cmd = vim.cmd
local api = vim.api

local fmtGroup = api.nvim_create_augroup("fmt", { clear = true })
api.nvim_create_autocmd("BufWritePre", {
	command = "undojoin | Neoformat",
	group = fmtGroup,
})
local ntreeGroup = api.nvim_create_augroup("ntree_group", { clear = true })
api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
	callback = function()
		cmd("NvimTreeFindFile")
		cmd("norm! zz")
		cmd("wincmd p")
	end,
	group = ntreeGroup,
	desc = "Focus nvimtree to current file",
})
