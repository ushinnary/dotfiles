local telescope = require("telescope")
local lga_actions = require("telescope-live-grep-args.actions")
local cmp = require("cmp")
local remapper = require("ushinnary.remapper")
local lspkind = require("lspkind")
local nnoremap = remapper.nnoremap
--local lga_actions = require("telescope-live-grep-args.actions")

telescope.setup({
	defaults = {
		file_ignore_patterns = { "node_modules/.*" },
	},
	extensions = {
		live_grep_args = {
			auto_quoting = true,
			mappings = {
				i = {
					["<C-k"] = lga_actions.quote_prompt(),
				},
			},
		},
	},
})
require("lualine").setup()
require("nvim-tree").setup({
	sort_by = "case_sensetive",
	view = {
		adaptive_size = true,
		mappings = {
			list = { {
				key = "u",
				action = "dir_up",
			} },
		},
		side = "left",
	},
	renderer = {
		group_empty = true,
	},
	filters = {
		dotfiles = true,
	},
})
cmp.setup({
	sources = {
		{ name = "nvim_lsp" },
		{ name = "nvim_lsp_signature_help" },
		{ name = "path" },
		{ name = "buffer", keyword_length = 3 },
	},
	mapping = {
		["<C-d>"] = cmp.mapping.scroll_docs(-4),
		["<C-f>"] = cmp.mapping.scroll_docs(4),
		["<C-e>"] = cmp.mapping.close(),
		["<C-Space>"] = cmp.mapping.complete(),
		["<C-n>"] = cmp.mapping.select_next_item(),
		["<C-p>"] = cmp.mapping.select_prev_item(),
		["<Tab>"] = cmp.mapping(function(fallback)
			if cmp.visible() then
				cmp.confirm({
					behavior = cmp.ConfirmBehavior.Insert,
					select = true,
				})
			else
				fallback()
			end
		end, { "i", "s" }),
	},
	formatting = {
		format = lspkind.cmp_format({
			with_text = true,
			menu = {
				buffer = "[buf]",
				nvim_lsp = "[LSP]",
				path = "[path]",
			},
		}),
	},
})
require("treesitter-context").setup()
require("nvim-treesitter.configs").setup({
	ensure_installed = { "rust" },
	sync_install = false,
	auto_install = false,
	highlight = {
		enable = true,
		additional_vim_regex_highlighting = false,
	},
})
require("toggleterm").setup()
require("nvim-autopairs").setup({})
require("mason").setup({
	ui = {
		icons = {
			package_installed = "✓",
			package_pending = "➜",
			package_uninstalled = "✗",
		},
	},
})

require("mason-lspconfig").setup({
	ensure_installed = {
		"sumneko_lua",
		"rust_analyzer",
		"omnisharp",
		"dockerls",
		"sqlls",
		"taplo",
		"tailwindcss",
		"volar",
		"tsserver",
		"bashls",
		"jsonls",
		"cssls",
		"svelte",
	},
	automatic_installation = true,
})
require("gitsigns").setup({
	on_attach = function()
		-- Actions
		nnoremap("<leader>hp", "<cmd>Gitsigns preview_hunk<CR>")
		nnoremap("<leader>ht", "<cmd>Gitsigns toggle_current_line_blame<CR>")
		nnoremap("<leader>hu", "<cmd>Gitsigns undo_stage_hunk<CR>")
		nnoremap("<leader>hs", "<cmd>Gitsigns stage_hunk<CR>")
	end,
})
require("which-key").setup()
require("catppuccin").setup({
	flavour = "macchiato",
	integrations = {
		cmp = true,
		gitsigns = true,
		nvimtree = true,
		telescope = true,
		treesitter = true,
		mason = true,
		neogit = true,
		which_key = true,
	},
	native_lsp = {
		enabled = true,
		virtual_text = {
			errors = { "italic" },
			hints = { "italic" },
			warnings = { "italic" },
			information = { "italic" },
		},
		underlines = {
			errors = { "underline" },
			hints = { "underline" },
			warnings = { "underline" },
			information = { "underline" },
		},
	},
})
require("bufferline").setup()
require("trouble").setup()
require("package-info").setup()
