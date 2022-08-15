require('telescope').setup {
    defaults = {
        mappings = {
            i = {
                ["<C-h>"] = "which_key"
            }
        }
    }
}
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
-- Languages support
local nvim_lsp = require'lspconfig'
local on_attach = function(client)
    require'completion'.on_attach(client)
end

nvim_lsp.rust_analyzer.setup({
    on_attach = on_attach,
    settings = {
        ["rust-analyzer"] = {
            imports = {
                granularity = {
                    group = "module"
                },
                prefix = "self"
            },
            cargo = {
                buildScripts = {
                    enable = true
                }
            },
            procMacro = {
                enable = true
            },
	    checkOnSave = {
		    command = "clippy"
	    },
        }
    }
})
