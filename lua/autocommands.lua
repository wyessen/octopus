local autocmd = vim.api.nvim_create_autocmd

-- File Tree Toggle logic
function _G.toggle_tree()
    if vim.bo.filetype == "NvimTree" then 
        vim.cmd("wincmd p") 
    else 
        vim.cmd("NvimTreeFocus") 
    end
end
vim.keymap.set("n", "<leader>e", _G.toggle_tree)

-- End of file newline enforcement
autocmd("BufWritePre", {
    callback = function()
        local cursor_pos = vim.api.nvim_win_get_cursor(0)
        local last_line_idx = vim.api.nvim_buf_line_count(0) - 1
        local last_line_content = vim.api.nvim_buf_get_lines(0, last_line_idx, -1, false)[1]

        if last_line_content ~= "" then
            pcall(vim.cmd, "undojoin")
            vim.api.nvim_buf_set_lines(0, last_line_idx + 1, -1, false, {""})

            vim.schedule(function()
                if vim.api.nvim_win_is_valid(0) then
                    pcall(vim.api.nvim_win_set_cursor, 0, cursor_pos)
                end
            end)
        end
    end,
})

-- Session Management
local session_file = vim.fn.getcwd() .. "/.workspace/last_session.vim"

autocmd("VimLeavePre", {
    callback = function()
        -- Ensure .workspace exists before saving
        if vim.fn.isdirectory(".workspace") == 1 then
            local ok, nvim_tree = pcall(require, "nvim-tree.api")
            if ok then nvim_tree.tree.close() end

            vim.cmd("mksession! " .. vim.fn.fnameescape(session_file))
        end
    end,
})

-- We want Makefile to be picked up every time one exists,
-- regardless of the file type.
vim.api.nvim_create_autocmd("FileType", {
    pattern = "sh",
    callback = function()
        -- Only use bash -n if a Makefile DOES NOT exist
        if vim.fn.filereadable("Makefile") == 0 then
            vim.opt_local.makeprg = "bash -n"
        else
            vim.opt_local.makeprg = "make"
        end
    end,
})

-- Enter into default layout:
--   file exporer on the left
--   terminal on bottom left
--   quickfix window on bottom right
vim.api.nvim_create_autocmd("VimEnter", {
  callback = function()
    -- 1. Open NvimTree first
    require("nvim-tree.api").tree.open()

    -- 2. Switch focus back to the main buffer (the center)
    -- This is crucial so the bottom splits don't get 'trapped' under the tree
    vim.cmd("wincmd l")

    -- 3. Open Quickfix window
    vim.cmd("botright copen 10")

    -- 4. Split vertically and launch terminal
    vim.cmd("vsplit | term")

    -- 5. Take focus back to the center window
    -- Jump to top-left (Tree), then one right (Main Buffer)
    vim.cmd("wincmd t")
    vim.cmd("wincmd l")
  end,
})

