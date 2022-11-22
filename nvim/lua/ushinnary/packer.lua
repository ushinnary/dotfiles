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
		config = function()
			require("telescope").load_extension("live_grep_args")
		end,
	})
	use("sbdchd/neoformat")
	-- Look and feel
	--use("folke/tokyonight.nvim")
	--use("Shatur/neovim-ayu")
	use({ "shaunsingh/oxocarbon.nvim", run = "./install.sh" })
	use("rcarriga/nvim-notify")
	use({
		"petertriho/nvim-scrollbar",
		config = function()
			require("scrollbar").setup()
		end,
	})
	use("akinsho/bufferline.nvim")
	use({
		"folke/todo-comments.nvim",
		requires = "nvim-lua/plenary.nvim",
		config = function()
			require("todo-comments").setup({})
		end,
	})
	use({
		"NvChad/nvim-colorizer.lua",
		config = function()
			require("colorizer").setup()
		end,
	})
	use({
		"karb94/neoscroll.nvim",
		config = function()
			require("neoscroll").setup()
		end,
	})
	-- Coding plug-ins
	use("onsails/lspkind.nvim")
	use("neovim/nvim-lspconfig")
	use("hrsh7th/cmp-nvim-lsp")
	use("hrsh7th/cmp-buffer")
	use("hrsh7th/cmp-path")
	use("hrsh7th/cmp-cmdline")
	use("hrsh7th/nvim-cmp")
	use("hrsh7th/cmp-nvim-lsp-signature-help")
	use("nvim-treesitter/nvim-treesitter")
	use("nvim-treesitter/nvim-treesitter-context")
	-- Debug
	use("mfussenegger/nvim-dap")
	-- Lua
	use({
		"folke/trouble.nvim",
		requires = "kyazdani42/nvim-web-devicons",
		config = function()
			require("trouble").setup()
		end,
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
		config = function()
			require("package-info").setup()
		end,
	})
	-- Tree
	use({
		"nvim-tree/nvim-tree.lua",
		requires = { "nvim-tree/nvim-web-devicons" },
	})
	-- Terminal
	use({
		"akinsho/toggleterm.nvim",
		config = function()
			require("toggleterm").setup()
		end,
	})
	-- Tools
	use({
		"windwp/nvim-autopairs",
		config = function()
			require("nvim-autopairs").setup({})
		end,
	})
	use("tpope/vim-surround")
	use("RRethy/vim-illuminate")
	use("lewis6991/impatient.nvim")
	-- Lua
	use({
		"folke/which-key.nvim",
		config = function()
			require("which-key").setup()
		end,
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
		config = function()
			require("crates").setup()
		end,
	})
end)
