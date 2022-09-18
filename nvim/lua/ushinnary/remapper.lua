
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
local tnoremap = bind("t")
local M = {
	nmap = nmap,
	nnoremap = nnoremap,
	vnoremap = vnoremap,
	xnoremap = xnoremap,
	inoremap = inoremap,
	tnoremap = tnoremap,
	}

return M
