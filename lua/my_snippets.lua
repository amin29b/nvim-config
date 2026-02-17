local match_pattern = "^([^|]+)|([^|]+)$"

vim.api.nvim_set_hl(0, "Separator", { fg = "#aa0000", bg = "#000000", bold = true })
vim.api.nvim_set_hl(0, "SnippetName", { fg = "#000000", bg = "#22aa22", bold = false })
vim.api.nvim_set_hl(0, "Snippet", { fg = "#000000", bg = "#888888", bold = false })



local function project_snippet_file_path()
    local utils = require("utils")
    local project_root = utils.FindProjectRoot({ "*.root", ".git" })
    local project_uuid_file = vim.fn.expand(project_root .. "/.project_uuid")

    if vim.fn.filereadable(project_uuid_file) == 0 then
        utils.ensure_file(project_uuid_file);
        local file_write = io.open(project_uuid_file, "w+")
        if not file_write then
            print("Could not open " .. project_uuid_file)
            return
        end
        file_write:write(utils.generate_uuid())
        file_write:close()
    end

    if vim.fn.filereadable(project_uuid_file) ~= 0 then
        local project_uuid = "ABCD"
        local file_read = io.open(project_uuid_file, "r")
        if not file_read then
            print("Could not open " .. project_uuid_file)
            return
        end

        for l in file_read:lines() do
            project_uuid = l
        end
        file_read:close()

        return vim.fn.expand("~/ProjectsSnippets/" .. project_uuid .. ".txt")
    end
end



local function open_file_in_float_MyProjectSnippets()
    local project_snippet_file = project_snippet_file_path();
    require("utils").ensure_file(project_snippet_file);
    -- line  |col   |                   path                           |                   line_content                                                                               | full_path
    -- --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    --local buf = vim.api.nvim_create_buf(false, true)
    if not project_snippet_file then
        return
    end

    local buf = vim.fn.bufadd(project_snippet_file)
    vim.fn.bufload(buf)

    local width = math.floor(vim.o.columns * 0.5)
    local height = math.floor(vim.o.lines * 0.3)
    local row = math.floor((vim.o.lines - height) / 2)
    -- local col = math.floor((vim.o.columns - width) / 2)

    local opts = {
        relative = "editor",
        width = width,
        height = height,
        row = row,
        col = vim.o.columns - 20,
        style = "minimal",
        border = "single",
    }


    local win = vim.api.nvim_open_win(buf, true, opts)
    vim.api.nvim_win_set_option(win, "cursorline", true)
    vim.api.nvim_win_set_option(win, "signcolumn", "no")
    vim.cmd("edit " .. vim.fn.fnameescape(project_snippet_file))
    vim.api.nvim_set_current_win(win)
    -- Force Normal mode
    vim.cmd("stopinsert")


    -- <CR> jumps in previous window, closes float
    vim.keymap.set("n", "<CR>", function()
        local line = vim.api.nvim_get_current_line()
        local snippet_name, snippet = line:match(match_pattern)
        if snippet_name and snippet then
            -- go back to previous window
            vim.cmd("wincmd p")

            -- edit file there
            -- vim.cmd("edit! " .. vim.fn.fnameescape(vim.fn.expand(path)))
            local success, result = pcall(function()
                vim.api.nvim_feedkeys(
                    vim.api.nvim_replace_termcodes(snippet, true, false, true),
                    "n",
                    false
                )
                -- vim.cmd(snippet)
            end)

            -- if not success then
            --     -- vim.api.nvim_win_set_cursor(0, { 1, 1 })
            -- end

            -- close floating window and buffer
            vim.api.nvim_win_close(win, true)
            vim.api.nvim_buf_delete(buf, { force = true })
            if vim.api.nvim_buf_is_valid(buf) then
                vim.bo[buf].buflisted = false
            end
        end
    end, { buffer = true, noremap = true, silent = true })

    vim.keymap.set("n", "q", function()
        vim.api.nvim_win_close(win, true)
        vim.api.nvim_buf_delete(buf, { force = true })
        if vim.api.nvim_buf_is_valid(buf) then
            vim.bo[buf].buflisted = false
        end
    end, { buffer = true, noremap = true, silent = true })

    vim.keymap.set("n", "<esc>", function()
        -- close floating window and buffer
        vim.api.nvim_win_close(win, true)
        vim.api.nvim_buf_delete(buf, { force = true })
        if vim.api.nvim_buf_is_valid(buf) then
            vim.bo[buf].buflisted = false
        end
    end, { buffer = true, noremap = true, silent = true })

    vim.bo[buf].modifiable = true

    -- highlight each line in the floating window
    for i = 1, vim.api.nvim_buf_line_count(buf) do
        local l = vim.api.nvim_buf_get_lines(buf, i - 1, i, false)[1]
        if l then
            local row_s, col_s = l:match(match_pattern)
            if row_s and col_s then
                local s1 = #row_s + 1

                vim.fn.matchaddpos("SnippetName", { { i, 1, #row_s } })
                vim.fn.matchaddpos("Separator", { { i, s1, 1 } })
                vim.fn.matchaddpos("Snippet", { { i, s1 + 1, #col_s } })
            end
        end
    end
end


vim.api.nvim_create_user_command('MyProjectSnippets', open_file_in_float_MyProjectSnippets, { desc = '' })
