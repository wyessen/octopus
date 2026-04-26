require("neogit").setup({
    disable_commit_confirmation = true,
    integrations = {
        diffview = true,
        telescope = true, 
    },
    kind = "tab", 
    diff_view = "side_by_side",
})

require("diffview").setup({
    hooks = {
        diff_buf_read = function(bufnr)
            local name = "DiffView_" .. bufnr
            pcall(vim.api.nvim_buf_set_name, bufnr, name)
        end,
    },
})

