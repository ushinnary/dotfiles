local cmd = vim.cmd
local api = vim.api

local fmtGroup = api.nvim_create_augroup("fmt", { clear = true })
api.nvim_create_autocmd("BufWritePre", {
	command = "undojoin | Neoformat",
	group = fmtGroup,
})

vim.api.nvim_create_autocmd("BufWinEnter", {
	pattern = "*",
	callback = function()
		if vim.bo.filetype == "NvimTree" then
			require("bufferline.api").set_offset(31, "FileTree")
		end
	end,
})

vim.api.nvim_create_autocmd("BufWinLeave", {
	pattern = "*",
	callback = function()
		if vim.fn.expand("<afile>"):match("NvimTree") then
			require("bufferline.api").set_offset(0)
		end
	end,
})
