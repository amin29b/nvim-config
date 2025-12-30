local jumpfile_path = vim.fn.expand("~/MyJumps.txt")
if vim.fn.filereadable(jumpfile_path) == 0 then
    local f = io.open(jumpfile_path, "w")
    if f then
        f:close()
    end
end
local match_pattern = "^(%d+)|(%d+)|([^|]+)|([^|]+)|(.+)$"

vim.api.nvim_set_hl(0, "JumpSeparator", { fg = "#aa0000", bg = "#000000", bold = true })
vim.api.nvim_set_hl(0, "JumpRow", { fg = "#000000", bg = "#22aa22", bold = false })
vim.api.nvim_set_hl(0, "JumpCol", { bold = false })
vim.api.nvim_set_hl(0, "JumpFile", { fg = "#aaaa55", bold = true, italic = true, underline = true })
vim.api.nvim_set_hl(0, "JumpContent", { fg = "#55ffff", bold = true })
vim.api.nvim_set_hl(0, "JumpFullPath", { fg = "#225522", italic = false, underline = true })

local function open_file_in_float_MyJumps()
    -- line  |col   |                   path                           |                   line_content                                                                               | full_path
    -- --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    --local buf = vim.api.nvim_create_buf(false, true)
    local buf = vim.fn.bufadd(jumpfile_path)
    vim.fn.bufload(buf)

    local width = math.floor(vim.o.columns * 0.98)
    local height = math.floor(vim.o.lines * 0.3)
    local row = math.floor((vim.o.lines - height) / 2)
    -- local col = math.floor((vim.o.columns - width) / 2)

    local opts = {
        relative = "editor",
        width = width,
        height = height,
        row = row,
        col = 1,
        style = "minimal",
        border = "single",
    }


    local win = vim.api.nvim_open_win(buf, true, opts)
    vim.api.nvim_win_set_option(win, "cursorline", true)
    vim.api.nvim_win_set_option(win, "signcolumn", "no")
    vim.cmd("edit " .. vim.fn.fnameescape(jumpfile_path))
    vim.api.nvim_set_current_win(win)

    -- <CR> jumps in previous window, closes float
    vim.keymap.set("n", "<CR>", function()
        local line = vim.api.nvim_get_current_line()
        local row, col, filename, spaces, path = line:match(match_pattern)
        if row and col and filename and spaces and path then
            -- go back to previous window
            vim.cmd("wincmd p")
            -- edit file there
            vim.cmd("edit! " .. vim.fn.fnameescape(vim.fn.expand(path)))
            local success, result = pcall(function()
                -- vim.api.nvim_win_set_cursor(0, { tonumber(row), tonumber(col) - 1 })
                vim.api.nvim_win_set_cursor(0, { tonumber(row), tonumber(col) })
            end)

            if not success then
                vim.api.nvim_win_set_cursor(0, { 1, 1 })
            end

            -- close floating window and buffer
            vim.api.nvim_win_close(win, true)
            vim.api.nvim_buf_delete(buf, { force = true })
            if vim.api.nvim_buf_is_valid(buf) then
                vim.bo[buf].buflisted = false
            end
            -- vim.api.nvim_win_close(win, true)
        else
            print("Invalid jump format!")
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
            local row_s, col_s, file_s, content_s, full_s = l:match(match_pattern)
            -- local row_s, col_s, file_s, content_s, full_s = l:match("^([^|]+)|([^|]+)|([^|]+)|([^|]+)|(.+)$")
            if row_s and col_s and file_s and content_s and full_s then
                local s1 = #row_s + 1
                local s2 = #row_s + 1 + #col_s + 1
                local s3 = #row_s + 1 + #col_s + 1 + #file_s + 1
                local s4 = #row_s + 1 + #col_s + 1 + #file_s + 1 + #content_s + 1

                vim.fn.matchaddpos("JumpRow", { { i, 1, #row_s } })
                vim.fn.matchaddpos("JumpSeparator", { { i, s1, 1 } })
                vim.fn.matchaddpos("JumpCol", { { i, s1 + 1, #col_s } })
                vim.fn.matchaddpos("JumpSeparator", { { i, s2, 1 } })
                vim.fn.matchaddpos("JumpFile", { { i, s2 + 1, #file_s } })
                vim.fn.matchaddpos("JumpSeparator", { { i, s3, 1 } })
                vim.fn.matchaddpos("JumpContent", { { i, s3 + 1, #content_s } })
                vim.fn.matchaddpos("JumpSeparator", { { i, s4, 1 } })
                vim.fn.matchaddpos("JumpFullPath", { { i, s4 + 1, #full_s } })
            end
        end
    end
end

local function truncate_start(s, max_len)
    if #s > max_len then
        return "..." .. s:sub(-max_len + 3) -- prepend … to indicate truncation
    else
        return s
    end
end

function add_jump()
    local filepath = vim.fn.expand("%:p") -- full path of current file
    if filepath == "" then
        print("No file name")
        return
    end

    local pos           = vim.api.nvim_win_get_cursor(0) -- {row, col}
    local row, col      = pos[1], pos[2] + 1             -- col is 0-indexed

    -- zero-padded 5-digit row/col
    local row_str       = string.format("%06d", row)
    local col_str       = string.format("%06d", col)

    -- relative path (from cwd)
    -- local filename      = vim.fn.fnamemodify(filepath, ":t")   -- filename.ext
    -- local folder        = vim.fn.fnamemodify(filepath, ":h:t") -- parent folder
    -- local relpath       = folder .. "/" .. filename
    local relpath       = filepath
    --local relpath  = vim.fn.fnamemodify(filepath, ":.")
    -- current line text
    local line_content  = vim.api.nvim_get_current_line()
    -- trim whitespace from start and end
    line_content        = line_content:gsub("^%s+", ""):gsub("%s+$", "")

    -- fixed-width columns
    local relpath_fixed = truncate_start(relpath, 50)
    relpath_fixed       = string.rep(" ", 50 - #relpath_fixed) .. relpath_fixed

    local content_fixed = line_content:sub(1, 110)
    content_fixed       = content_fixed .. string.rep(" ", 110 - #content_fixed)

    local line          = string.format("%s|%s|%s|%s|%s",
        row_str, col_str, relpath_fixed, content_fixed, filepath)


    -- NOTE: To Insert Line at start of file
    local file_read = io.open(jumpfile_path, "r")
    if not file_read then
        print("Could not open " .. jumpfile_path)
        return
    end

    local newLines = {}
    for l in file_read:lines() do
        table.insert(newLines, l)
    end
    file_read:close()
    table.insert(newLines, 1, line)

    -- NOTE: w+ is for rewrtie all file
    local file_write = io.open(jumpfile_path, "w+")
    if not file_write then
        print("Could not open " .. jumpfile_path)
        return
    end

    for i = 1, #newLines do
        if newLines[i] ~= ".\\" and vim.trim(newLines[i]) ~= "" then
            file_write:write(newLines[i] .. "\n")
        end
    end
    file_write:close()
    print("Jump Added to " .. jumpfile_path)
end

vim.api.nvim_create_user_command('MyJumps', open_file_in_float_MyJumps, { desc = '' })
vim.api.nvim_create_user_command('AddJump', add_jump, { desc = '' })
