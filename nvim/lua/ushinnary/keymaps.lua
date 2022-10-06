local remapper = require("ushinnary.remapper")
local nnoremap = remapper.nnoremap
local tnoremap = remapper.tnoremap
-- Actual remaps
nnoremap("<C-p>", "<cmd>Telescope find_files<CR>")
nnoremap("<leader>fg", "<cmd>Telescope live_grep<CR>")
-- Neogit
local neogit = require("neogit")
neogit.setup({})

nnoremap("<leader>ng", function()
	neogit.open({})
end)

nnoremap("<leader>gf", "<cmd>!git fetch --all<CR>")
-- nnoremap("<leader>t", "<cmd>exe v:count1 . \"ToggleTerm\"<CR>")
nnoremap("<leader>b", "<cmd>NvimTreeToggle<CR>")
nnoremap("<leader>t", "<cmd>ToggleTerm<CR>")
tnoremap("<esc>", "<cmd>ToggleTerm<CR>")
-- Rust related
--nnoremap("<leader>T", "<cmd>lua require'lsp_extensions'.inlay_hints()<CR>")

-- Code related
nnoremap("gd", "<cmd>lua vim.lsp.buf.definition()<CR>")
nnoremap("gD", "<cmd>lua vim.lsp.buf.implementation()<CR>")
nnoremap("gr", "<cmd>lua vim.lsp.buf.references()<CR>")
nnoremap("ga", "<cmd>lua vim.lsp.buf.code_action()<CR>")
nnoremap("K", "<cmd>lua vim.lsp.buf.hover()<CR>")
