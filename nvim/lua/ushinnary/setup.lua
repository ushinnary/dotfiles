local telescope = require("telescope")
local lga_actions = require("telescope-live-grep-args.actions")
local cmp = require("cmp")
local remapper = require("ushinnary.remapper")
local lspkind = require("lspkind")
local nnoremap = remapper.nnoremap
local luasnip = require("luasnip")
--local lga_actions = require("telescope-live-grep-args.actions")
require("luasnip.loaders.from_vscode").lazy_load()
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
require("lualine").setup({
	sections = {
		lualine_a = { "mode" },
		lualine_b = { "branch", "diff", "diagnostics" },
		lualine_c = { "filename", "filesize" },
		lualine_x = { "encoding", "fileformat", "filetype" },
		lualine_y = { "searchcount" },
		lualine_z = { "location" },
	},
})
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
		{ name = "nvim_lsp", keyword_length = 3 },
		{ name = "nvim_lsp_signature_help" },
		{ name = "path" },
		{ name = "luasnip", keyword_length = 2 },
		{ name = "buffer", keyword_length = 5 },
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
	snippet = {
		expand = function(args)
			luasnip.lsp_expand(args.body)
		end,
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
require("mason").setup({
	ui = {
		icons = {
			package_installed = "???",
			package_pending = "???",
			package_uninstalled = "???",
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
		"angularls",
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
require("bufferline").setup({
	options = {
		diagnostics = "nvim_lsp",
		diagnostics_indicator = function(count, level, diagnostics_dict, context)
			local icon = level:match("error") and "??? " or "??? "
			return " " .. icon .. count
		end,
	},
})
require("trouble").setup()
require("package-info").setup()
require("toggleterm").setup()
require("nvim-autopairs").setup({})
require("which-key").setup()
require("crates").setup()
require("telescope").load_extension("live_grep_args")
require("scrollbar").setup()
require("todo-comments").setup({})
require("colorizer").setup()
require("neoscroll").setup()
