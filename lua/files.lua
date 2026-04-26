require('nvim-tree').setup({
    sync_root_with_cwd = true,
    view = { width = 40, side = 'left' },
    update_focused_file = { enable = true },
    git = { ignore = false },
})

