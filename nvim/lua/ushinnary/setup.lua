local telescope = require("telescope")
local lga_actions = require("telescope-live-grep-args.actions")
local cmp = require("cmp")
local lspkind = require("lspkind")
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
require("nvim-treesitter.configs").setup({
	ensure_installed = { "lua", "rust", "typescript", "javascript", "markdown", "json", "css", "scss", "sql", "regex" },
	sync_install = false,
	auto_install = false,
	highlight = {
		enable = true,
	},
	indent = {
		enable = false,
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
		-- LSPs
		"rust_analyzer",
		"bash-language-server",
		"vue-language-server",
		"css-lsp",
		"json-lsp",
		"lua-language-server",
		"sqlls",
		"taplo",
		-- Linters
		"typescript-language-server",
		"cfn-lint",
		"erb-lint",
		"eslint_d",
		"selene",
		"shellcheck",
		-- Formatters
		"sqlfluff",
		"beautysh",
		"prettierd",
		"sql-formatter",
		"stylua",
	},
})
