local remapper = require("remapper")
local nnoremap = remapper.nnoremap
-- Actual remaps
nnoremap("<leader>ff", '<cmd>Telescope find_files<CR>')
-- Neogit
local neogit = require('neogit')
neogit.setup {}

nnoremap("<leader>gs", function()
    neogit.open({})
end);

-- nnoremap("<leader>ga", "<cmd>!git fetch -all<CR>");
-- nnoremap("<leader>t", "<cmd>exe v:count1 . \"ToggleTerm\"<CR>")
nnoremap("<leader>b", "<cmd>NvimTreeToggle<CR>")
nnoremap("<leader>t", "<cmd>ToggleTerm<CR>")
