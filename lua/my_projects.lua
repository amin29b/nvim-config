local projectfile_path = vim.fn.expand("~/MyProjects.txt")
if vim.fn.filereadable(projectfile_path) == 0 then
    local f = io.open(projectfile_path, "w")
    if f then
        f:close()
    end
end


vim.api.nvim_set_hl(0, "ProjectFullPath",
    { fg = "#999900", bg = "NONE", italic = false, underline = true, bold = true })


local function open_file_in_float_MyProjects()
    -- line  ⋮col   ⋮                   path                           ⋮                   line_content                                                                               ⋮ full_path
    -- --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    --local buf = vim.api.nvim_create_buf(false, true)
    local buf = vim.fn.bufadd(projectfile_path)
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
    vim.cmd("edit " .. vim.fn.fnameescape(projectfile_path))
    vim.api.nvim_set_current_win(win)

    vim.keymap.set("n", "<CR>", function()
        local line = vim.api.nvim_get_current_line()
        if vim.fn.isdirectory(line) == 1 then
            local path = line
            -- go back to previous window
            vim.cmd("wincmd p")
            -- edit file there
            vim.cmd("edit! " .. vim.fn.fnameescape(vim.fn.expand(path)))

            -- close floating window and buffer
            vim.api.nvim_win_close(win, true)
            vim.api.nvim_buf_delete(buf, { force = true })
            if vim.api.nvim_buf_is_valid(buf) then
                vim.bo[buf].buflisted = false
            end
            -- vim.api.nvim_win_close(win, true)
        else
            print("Invalid project format!")
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
            local full_s = l
            if full_s then
                local s1 = 1
                vim.fn.matchaddpos("ProjectFullPath", { { i, s1, #full_s } })
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

-- local counter = 0
function add_project()
    -- print("add_project" .. counter)
    -- counter = counter + 1
    local root_markers = { '*.sln', '.git', 'package.json', 'Makefile', '*.root' }
    local project_root = require("utils").FindProjectRoot(root_markers)
    if (#project_root <= 0) then
        return
    end

    local prjectDir = vim.fn.expand(project_root) -- full path of current file
    if prjectDir == "" then
        print("No file name")
        return
    end

    local line = string.format("%s", prjectDir)
    line = line:gsub("\\$", "") .. "\\"



    local file_read = io.open(projectfile_path, "r")
    if not file_read then
        print("Could not open " .. projectfile_path)
        return
    end

    local exists = false
    local newLines = {}

    for l in file_read:lines() do
        if string.lower(l) == string.lower(line) then
            exists = true
        else
            table.insert(newLines, l)
        end
    end
    file_read:close()

    table.insert(newLines, 1, line)

    if not exists then
        print("Project Added to " .. projectfile_path)
    end



    local file_write = io.open(projectfile_path, "w+")
    if not file_write then
        print("Could not open " .. projectfile_path)
        return
    end

    for i = 1, #newLines do
        if newLines[i] ~= ".\\" and vim.trim(newLines[i]) ~= "" then
            file_write:write(newLines[i] .. "\n")
        end
    end
    file_write:close()
end

vim.api.nvim_create_user_command('MyProjects', open_file_in_float_MyProjects, { desc = '' })
vim.api.nvim_create_user_command('AddMyProject', add_project, { desc = '' })

vim.api.nvim_create_autocmd({ "BufRead" }, { callback = add_project, })
