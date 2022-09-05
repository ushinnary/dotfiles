require('telescope').setup {}
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
