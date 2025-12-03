-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
local map = vim.keymap.set

-- Keep cursor in the middle when searching
map("n", "n", "nzzzv", { desc = "Next search result centered" })
map("n", "N", "Nzzzv", { desc = "Prev search result centered" })

-- Paste without yanking in visual mode
map("v", "p", '"_dP', { desc = "Paste without yanking" })

-- Terminal go to vi normal mode
map("t", "<C-Space>", [[<C-\><C-n>]], { desc = "Terminal Normal Mode" })
