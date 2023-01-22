return {
	"williamboman/mason.nvim",
	"williamboman/mason-lspconfig.nvim",
	"nvim-lua/plenary.nvim",
	{
		"nvim-telescope/telescope.nvim",
		dependencies = {
			{ "nvim-telescope/telescope-live-grep-args.nvim" },
		},
	},
	"sbdchd/neoformat",
	"folke/tokyonight.nvim",
	{
		"https://git.sr.ht/~whynothugo/lsp_lines.nvim",
		config = function()
			require("lsp_lines").setup()
		end,
	},
	"rcarriga/nvim-notify",
	{
		"petertriho/nvim-scrollbar",
	},
	"akinsho/bufferline.nvim",
	{
		"folke/todo-comments.nvim",
		dependencies = "nvim-lua/plenary.nvim",
	},
	{
		"NvChad/nvim-colorizer.lua",
	},
	{
		"karb94/neoscroll.nvim",
	},
	"onsails/lspkind.nvim",
	"neovim/nvim-lspconfig",
	"hrsh7th/cmp-nvim-lsp",
	"hrsh7th/cmp-buffer",
	"hrsh7th/cmp-path",
	"hrsh7th/cmp-cmdline",
	"hrsh7th/nvim-cmp",
	"L3MON4D3/LuaSnip",
	"hrsh7th/cmp-nvim-lsp-signature-help",
	"nvim-treesitter/nvim-treesitter",
	"nvim-treesitter/nvim-treesitter-context",
	"mfussenegger/nvim-dap",
	-- Lua
	{
		"folke/trouble.nvim",
		dependencies = "kyazdani42/nvim-web-devicons",
	},
	-- Bottom status line
	{
		"nvim-lualine/lualine.nvim",
		dependencies = {
			"kyazdani42/nvim-web-devicons",
			opt = true,
		},
	},
	-- NodeJS
	{
		"vuki656/package-info.nvim",
		dependencies = "MunifTanjim/nui.nvim",
	},
	-- Tree
	{
		"nvim-tree/nvim-tree.lua",
		dependencies = { "kyazdani42/nvim-web-devicons" },
	},
	-- Terminal
	{
		"akinsho/toggleterm.nvim",
	},
	-- Tools
	{
		"windwp/nvim-autopairs",
	},
	"tpope/vim-surround",
	"RRethy/vim-illuminate",
	-- Lua
	{
		"folke/which-key.nvim",
	},
	-- Git
	{ "TimUntersberger/neogit" },
	{
		"lewis6991/gitsigns.nvim",
	},
	-- Rust
	{
		"saecki/crates.nvim",
		event = { "BufRead Cargo.toml" },
		dependencies = { { "nvim-lua/plenary.nvim" } },
	},
}
