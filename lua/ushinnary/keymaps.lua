-- Settings setup 
-- Thx to ThePrimeagen
local function bind(op, outer_opts)
    outer_opts = outer_opts or {
        noremap = true
    }
    return function(lhs, rhs, opts)
        opts = vim.tbl_extend("force", outer_opts, opts or {})
        vim.keymap.set(op, lhs, rhs, opts)
    end
end
local nmap = bind("n", {
    noremap = false
})
local nnoremap = bind("n")
local vnoremap = bind("v")
local xnoremap = bind("x")
local inoremap = bind("i")

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
