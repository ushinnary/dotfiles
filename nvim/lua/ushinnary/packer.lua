vim.cmd([[packadd packer.nvim]])
return require("packer").startup(function(use)
	use("wbthomason/packer.nvim")
	use("williamboman/mason.nvim")
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
	use({ "TimUntersberger/neogit" })
	use("sbdchd/neoformat")
	-- Themes
	--use("folke/tokyonight.nvim")
	use("Shatur/neovim-ayu")
	--use("Mofiqul/vscode.nvim")
	-- use("gruvbox-community/gruvbox")
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
