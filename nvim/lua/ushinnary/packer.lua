-- ensure the packer plugin manager is installed
local ensure_packer = function()
	local fn = vim.fn
	local install_path = fn.stdpath("data") .. "/site/pack/packer/start/packer.nvim"
	if fn.empty(fn.glob(install_path)) > 0 then
		fn.system({ "git", "clone", "--depth", "1", "https://github.com/wbthomason/packer.nvim", install_path })
		vim.cmd([[packadd packer.nvim]])
		return true
	end
	return false
end

local packer_bootstrap = ensure_packer()

-- the first run will install packer and our plugins
if packer_bootstrap then
	require("packer").sync()
	return
end

return require("packer").startup(function(use)
	use("wbthomason/packer.nvim")
	use("williamboman/mason.nvim")
	use("williamboman/mason-lspconfig.nvim")
	use("nvim-lua/plenary.nvim")
	use({
		"nvim-telescope/telescope.nvim",
		requires = {
			{ "nvim-telescope/telescope-live-grep-args.nvim" },
		},
	})
	use("sbdchd/neoformat")
	-- Look and feel
	use("folke/tokyonight.nvim")
	use({
		"https://git.sr.ht/~whynothugo/lsp_lines.nvim",
		config = function()
			require("lsp_lines").setup()
		end,
	})
	use("rcarriga/nvim-notify")
	use({
		"petertriho/nvim-scrollbar",
	})
	use("akinsho/bufferline.nvim")
	use({
		"folke/todo-comments.nvim",
		requires = "nvim-lua/plenary.nvim",
	})
	use({
		"NvChad/nvim-colorizer.lua",
	})
	use({
		"karb94/neoscroll.nvim",
	})
	-- Coding plug-ins
	use("onsails/lspkind.nvim")
	use("neovim/nvim-lspconfig")
	use("hrsh7th/cmp-nvim-lsp")
	use("hrsh7th/cmp-buffer")
	use("hrsh7th/cmp-path")
	use("hrsh7th/cmp-cmdline")
	use("hrsh7th/nvim-cmp")
	use("L3MON4D3/LuaSnip")
	use("hrsh7th/cmp-nvim-lsp-signature-help")
	use("nvim-treesitter/nvim-treesitter")
	use("nvim-treesitter/nvim-treesitter-context")
	-- Debug
	use("mfussenegger/nvim-dap")
	-- Lua
	use({
		"folke/trouble.nvim",
		requires = "kyazdani42/nvim-web-devicons",
	})
	-- Bottom status line
	use({
		"nvim-lualine/lualine.nvim",
		requires = {
			"kyazdani42/nvim-web-devicons",
			opt = true,
		},
	})
	-- NodeJS
	use({
		"vuki656/package-info.nvim",
		requires = "MunifTanjim/nui.nvim",
	})
	-- Tree
	use({
		"nvim-tree/nvim-tree.lua",
		requires = { "nvim-tree/nvim-web-devicons" },
	})
	-- Terminal
	use({
		"akinsho/toggleterm.nvim",
	})
	-- Tools
	use({
		"windwp/nvim-autopairs",
	})
	use("tpope/vim-surround")
	use("RRethy/vim-illuminate")
	use("lewis6991/impatient.nvim")
	-- Lua
	use({
		"folke/which-key.nvim",
	})
	-- Git
	use({ "TimUntersberger/neogit" })
	use({
		"lewis6991/gitsigns.nvim",
	})
	-- Rust
	use({
		"saecki/crates.nvim",
		event = { "BufRead Cargo.toml" },
		requires = { { "nvim-lua/plenary.nvim" } },
	})
end)
