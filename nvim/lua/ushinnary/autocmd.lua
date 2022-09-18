local cmd = vim.cmd
local api = vim.api

  local fmtGroup = api.nvim_create_augroup("fmt", { clear = true })
api.nvim_create_autocmd("BufWritePre", {
	command = "undojoin | Neoformat",
	group = fmtGroup,
})

--autocmd BufEnter,BufWinEnter,TabEnter *.rs :lua require'lsp_extensions'.inlay_hints{}
--api.nvim_create_autocmd({"BufEnter", "BufWinEnter", "TabEnter"}, {
--	pattern = { "rs" },
--	command = "lua require'lsp_extensions'.inlay_hints{}"
--})

