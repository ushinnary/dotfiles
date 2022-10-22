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
		config = function()
			require("telescope").load_extension("live_grep_args")
		end,
	})
	use("sbdchd/neoformat")
	-- Themes
	use("folke/tokyonight.nvim")
	use({ "shaunsingh/oxocarbon.nvim", branch = "fennel" })
	--use("Shatur/neovim-ayu")
	-- Coding plug-ins
	use("onsails/lspkind.nvim")
	use("neovim/nvim-lspconfig")
	use("hrsh7th/cmp-nvim-lsp")
	use("hrsh7th/cmp-buffer")
	use("hrsh7th/cmp-path")
	use("hrsh7th/cmp-cmdline")
	use("hrsh7th/nvim-cmp")
	use("nvim-treesitter/nvim-treesitter")
	-- Bottom status line
	use({
		"nvim-lualine/lualine.nvim",
		requires = {
			"kyazdani42/nvim-web-devicons",
			opt = true,
		},
	})
	-- Tree
	use({
		"nvim-tree/nvim-tree.lua",
		requires = { "nvim-tree/nvim-web-devicons" },
	})
	-- Terminal
	use("akinsho/toggleterm.nvim")
	-- Tools
	use("windwp/nvim-autopairs")
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
	use({ "sindrets/diffview.nvim", requires = "nvim-lua/plenary.nvim" })
end)
