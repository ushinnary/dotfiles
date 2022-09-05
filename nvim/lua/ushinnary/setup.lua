local telescope = require("telescope")
local cmp = require "cmp"
local lspkind = require('lspkind')
--local lga_actions = require("telescope-live-grep-args.actions")

telescope.setup {}
require('lualine').setup()
require("nvim-tree").setup({
    sort_by = "case_sensetive",
    view = {
        adaptive_size = true,
        mappings = {
            list = {{
                key = "u",
                action = "dir_up"
            }}
        },
        side = "left"
    },
    renderer = {
        group_empty = true
    },
    filters = {
        dotfiles = true
    }
})
cmp.setup {
	sources = {
		{ name = 'nvim_lsp' },
		{ name = "path" },
		{ name = "buffer", keyword_length = 3 },
	},
	 mapping = {
       	 ["<C-d>"] = cmp.mapping.scroll_docs(-4),
         ["<C-f>"] = cmp.mapping.scroll_docs(4),
         ["<C-e>"] = cmp.mapping.close(),
         ["<c-y>"] = cmp.mapping.confirm {
            behavior = cmp.ConfirmBehavior.Insert,
            select = true,
         },
      },
      formatting = {
         format = lspkind.cmp_format {
            with_text = true,
            menu = {
               buffer   = "[buf]",
               nvim_lsp = "[LSP]",
               path     = "[path]",
            },
         },
      },
}
-- The nvim-cmp almost supports LSP's capabilities so You should advertise it to LSP servers..
local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = require('cmp_nvim_lsp').update_capabilities(capabilities)

-- The following example advertise capabilities to `clangd`.
require'lspconfig'.clangd.setup {
  capabilities = capabilities,
}
require'lspconfig'.tsserver.setup{}
