return require("packer").startup(function()
	use("wbthomason/packer.nvim")
	use("nvim-lua/plenary.nvim")
	use({
		"nvim-telescope/telescope.nvim",
		tag = "0.1.0",
	})
	use({ "TimUntersberger/neogit" })
	use("sbdchd/neoformat")
	-- Themes
	-- use("shaunsingh/nord.nvim")
	use("folke/tokyonight.nvim")
	--use("Mofiqul/vscode.nvim")
	-- use("gruvbox-community/gruvbox")
	-- Coding plug-ins
	use("nvim-lua/completion-nvim")
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
		"kyazdani42/nvim-tree.lua",
		requires = { "kyazdani42/nvim-web-devicons" },
	})
	-- Terminal
	use("akinsho/toggleterm.nvim")
	-- Tools
	use("windwp/nvim-autopairs")
	use("tpope/vim-surround")
	use("RRethy/vim-illuminate")
	use("lewis6991/impatient.nvim")
end)
