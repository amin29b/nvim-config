local test = [[
    test 0   abc - -  -  00 0  dee      -0  -gh       0  ddde
    sst          -aaaaac0  r -c2   0  de-0  zxc       0  r-v 0  bbz
    vvvv     0  r-c3 0  de   -0  zxc       0  r-v 0  bbz 0    da -   -a
    sss
    tttax   0  r -c4   0  de -0  zxc       0  r-v 0  bbz
    ]]

local test2 = [[
    test 0   abc -           -                 -  00 0  dee      -0       -gh       0  ddde
    test 0   abc -           -                 -  00 0  dee      -0       -gh       0  ddde
    sst          -aaaaaac0  r-c2   0  de       -0  zxc       0  r-v 0  bbz
    sst          -aaaaaac0  r-c2   0  de       -0  zxc       0  r-v 0  bbz
    vvvv     0  r-c3   0  de -0  zxc       0  r-v 0  bbz 0    da -        -a
    vvvv     0  r-c3   0  de -0  zxc       0  r-v 0  bbz 0    da -        -a
    sss
    sss
    tttax   0  r -c4   0  de -0  zxc       0  r-v 0  bbz
    tttax   0  r -c4   0  de -0  zxc       0  r-v 0  bbz
    ]]

local function get_spaces(n)
    local spaces = ""
    for j = 1, n do
        spaces = spaces .. " "
    end
    return spaces
end

local function get_visual_selection()
    -- start of current visual selection
    local vstart     = vim.fn.getpos("v")
    -- cursor position
    local vend       = vim.fn.getpos(".")

    local start_line = math.min(vstart[2], vend[2])
    local end_line   = math.max(vstart[2], vend[2])

    -- print("start: " .. start_line .. "    end: " .. end_line)
    local lines      = vim.api.nvim_buf_get_lines(
        0,
        start_line - 1,
        end_line,
        false
    )

    -- local text       = table.concat(lines, "\n")
    -- return text, start_line, end_line
    return lines, start_line, end_line
end

local function split_by(line, sep)
    local splits = {}
    local start_index = 1
    local end_index = #line
    for i = 1, #line do
        local char = string.char(string.byte(line, i))
        if (char == sep) then
            end_index = i
            local news = (string.sub(line, start_index, end_index):gsub(sep, ""))
            table.insert(splits, news)
            start_index = i
        end

        if (i == #line) then
            local news = (string.sub(line, start_index):gsub(sep, ""))
            table.insert(splits, news)
        end
    end

    -- for i = 1, #splits do
    --     splits[i] = splits[i]:gsub("[ ]*$", "")
    -- end

    return splits
end

local function make_tabular(lines, split_string)
    -- for i = 1, #lines do
    --     print(lines[i])
    -- end


    if (not lines) or (#lines < 2) then
        return nil
    end

    -- local split_char = "-"

    local matches = {}
    -- local split_string_trim = vim.trim(split_string)
    for i = 1, #lines do
        -- table.insert(matches, split_by(lines[i], split_char))
        -- table.insert(matches, vim.split(lines[i], split_string_trim, { plain = true }))
        table.insert(matches, vim.split(lines[i], split_string, { plain = true }))
    end


    local columns = {}
    local columns_count = 0
    for i = 1, #matches do
        local n = #matches[i]
        if n > columns_count then
            columns_count = n
        end
    end
    -- print(columns_count)



    for i = 1, #matches do
        for j = 1, columns_count do
            if not columns[j] then
                columns[j] = {}
            end

            if j <= #matches[i] then
                local m = matches[i][j]
                table.insert(columns[j], m)
            else
                table.insert(columns[j], "")
            end
        end
    end


    for i = 1, columns_count do
        local col = columns[i]
        local col_max = 0
        local poses = {}

        for j = 1, #col do
            poses[j] = #col[j]
            if col_max < #col[j] then
                col_max = #col[j]
            end
        end
        -- print(col_max)



        for j = 1, #poses do
            if (poses[j] ~= -1) and (poses[j] ~= col_max) then
                local spaces = get_spaces(col_max - poses[j])
                col[j] =
                    string.sub(col[j], 1, poses[j]) ..
                    spaces
            end
        end



        -- for j = 1, #poses do
        --     print(poses[j] .. "\n")
        -- end



        -- for j = 1, #col do
        --     print(col[j] .. "\n")
        -- end
        -- print("--------------")
    end

    local newLines = {}
    for i = 1, #columns do
        for j = 1, #columns[i] do
            if not newLines[j] then
                newLines[j] = ""
            end
        end

        -- for j = 1, 2 do
        --     newLines[j] = columns[i][j]
        -- end

        for j = 1, #columns[i] do
            if (i == 1) then
                if i <= #matches[j] then
                    newLines[j] = columns[i][j]
                end
            else
                if i <= #matches[j] then
                    newLines[j] = newLines[j] .. split_string .. columns[i][j]
                end
            end
        end
    end


    for i = 1, #newLines do
        newLines[i] = newLines[i]:gsub("%s+$", "")
    end

    return newLines
end

local function tabular()
    local text, start_line, end_line = get_visual_selection()
    if not text or text == "" then
        return
    end

    local new_lines = make_tabular(text, "=")
    if new_lines then
        vim.api.nvim_buf_set_lines(
            0,
            start_line - 1,
            end_line,
            false,
            new_lines
        )
    end
end

local function ex_tab(opts, split_string)
    local start_line = opts.line1
    local end_line   = opts.line2

    local lines      = vim.api.nvim_buf_get_lines(
        0,
        start_line - 1,
        end_line,
        false
    )



    local new_lines = make_tabular(lines, split_string)

    if new_lines then
        vim.api.nvim_buf_set_lines(
            0,
            start_line - 1,
            end_line,
            false,
            new_lines
        )
    end
end

local function setup()
    vim.api.nvim_create_user_command("Tabularize",
        function(opts)
            -- arguments as array
            local args = opts.fargs -- { "arg1", "arg2", ... }

            local arg_all = ""
            for i = 1, #args do
                arg_all = arg_all .. args[i]
            end


            -- print("[" .. arg_all .. "]")
            local arg_splits = vim.split(arg_all, "/", { plain = true })

            local new_args = {}
            for i = 1, #arg_splits do
                if (i % 2 == 0) then
                    table.insert(new_args, arg_splits[i])
                    -- print(arg_splits[i])
                end
            end

            for i = 1, #new_args do
                new_args[i] = new_args[i]:gsub("\\s", " ")
                -- print("[" .. new_args[i] .. "]")
            end




            args = new_args


            if args and #args > 0 then
                for i = 1, #args do
                    ex_tab(opts, args[i])
                end
            else
                ex_tab(opts, "  =  ")
            end
        end
        , {
            range = true,
            nargs = "*", -- 0 or more arguments
        })
end


return {
    setup = setup,
    tabular = tabular
}

-- tabular(test)
