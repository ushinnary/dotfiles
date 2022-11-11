local remapper = require("ushinnary.remapper")
local nnoremap = remapper.nnoremap
local nmap = remapper.nmap
local vnoremap = remapper.vnoremap
local tnoremap = remapper.tnoremap
-- Actual remaps
nnoremap("<C-p>", "<cmd>Telescope find_files<CR>")
nnoremap("<leader>fg", "<cmd>Telescope live_grep<CR>")
nnoremap("<leader>nf", ":NvimTreeFindFile<CR>")
nnoremap("<leader>rr", "<cmd>lua vim.lsp.buf.rename()<CR>")
nnoremap("<C-s>", "<cmd>write<CR>")
nnoremap("<C-S>", "<cmd>wa<CR>")
nnoremap("<leader>s", "<cmd>source %<CR>")
nnoremap("<leader>e", "<cmd>lua vim.diagnostic.open_float()<CR>")
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
nnoremap("<leader>tt", "<cmd>TroubleToggle<CR>")
tnoremap("<esc>", "<cmd>ToggleTerm<CR>")
-- Rust related
--nnoremap("<leader>T", "<cmd>lua require'lsp_extensions'.inlay_hints()<CR>")

-- Code related
nnoremap("gd", "<cmd>lua vim.lsp.buf.definition()<CR>")
nnoremap("gD", "<cmd>lua vim.lsp.buf.implementation()<CR>")
nnoremap("gr", "<cmd>lua vim.lsp.buf.references()<CR>")
nnoremap("ga", "<cmd>lua vim.lsp.buf.code_action()<CR>")
nnoremap("K", "<cmd>lua vim.lsp.buf.hover()<CR>")
nnoremap("<C-k>", "<cmd>lua vim.lsp.buf.signature_help()<CR>")

-- VonHeikemen
-- Moving lines and preserving indentation
nnoremap("<A-j>", ":move .+1<CR>==")
nnoremap("<A-k>", ":move .-2<CR>==")
vnoremap("<A-j>", ":move '>+1<CR>gv=gv")
vnoremap("<A-k>", ":move '<-2<CR>gv=gv")
-- Open new tabpage
nnoremap("<Leader>tn", ":tabnew<CR>")

-- Navigate between tabpages
nnoremap("<A-<>", ":BufferLineCyclePrev<CR>")
nnoremap("<A->>", ":BufferLineCycleNext<CR>")
nnoremap("<C-c>t", ":BufferLinePickClose<CR>")
--
-- Navigate between buffers
nnoremap("[b", ":bprevious<CR>")
nnoremap("]b", ":bnext<CR>")
--
-- Search symbols in buffer
nnoremap("<leader>fs", ":Telescope treesitter<CR>")
-- Git file history
nnoremap("<leader>fh", ":DiffviewFileHistory<CR>")

-- Debug
nmap("<F9>", ":lua require'dap'.repl.open()<CR>")
nmap("<F10>", ":lua require'dap'.continue()<CR>")
nmap("<F11>", ":lua require'dap'.step_into()<CR>")
nmap("<F12>", ":lua require'dap'.step_over()<CR>")
nmap("Db", ":lua require'dap'.toggle_breakpoint()<CR>")

-- Package.json
nnoremap("<leader>nu", ":lua require('package-info').update()<CR>")
nnoremap("<leader>nd", ":lua require('package-info').delete()<CR>")

-- Commenting
