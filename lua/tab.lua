local test = [[
    test 0   abc ---  00 0  dee-0  -gh       0  ddde
    sst-aaaaaac0  r-c2   0  de-0  zxc       0  r-v 0  bbz
    vvvv     0  r-c3   0  de-0  zxc       0  r-v 0  bbz 0    da--a
    sss
    tttax   0  r-c4   0  de-0  zxc       0  r-v 0  bbz
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

local function tabular(text)
    -- local v_selection = require("utils").get_visual_selection()
    -- local v_selection = test
    -- print(v_selection)
    -- if v_selection == "" then
    --     return
    -- end
    -- local line_start = 2
    -- local line_end = 6

    -- print(test)
    -- local lines = vim.api.nvim_buf_get_lines(0, line_start - 1, line_end, false)
    -- local lines = require("utils").get_visual_selection()
    -- lines = nil

    local lines = {}
    table.insert(lines, "test")
    table.insert(lines, "test2")

    local start_index = 1
    local end_index = #text
    for i = 1, #text do
        -- local char = string.byte(text, i)
        local char = string.char(string.byte(text, i))
        if (char == nil) then
            -- i = i + 3
            end_index = i
            local news = (string.sub(text, start_index, end_index))
            table.insert(lines, news)
            start_index = i
        end

        if (i >= #text) then
            local news = (string.sub(text, start_index))
            table.insert(lines, news)
        end
    end
    -- print("line count : " .. #lines)
    -- print(lines)

    table.insert(lines, "test3")
    table.insert(lines, "test4")
    if (not lines) or (#lines < 2) then
        return
    end

    local split_char = "="

    local matches = {}
    for i = 1, #lines do
        table.insert(matches, split_by(lines[i], split_char))
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
                    newLines[j] = newLines[j] .. "" .. split_char .. "" .. columns[i][j]
                end
            end
        end
    end

    -- NOTE: I dont know which one to use
    for j = 1, #newLines do
        print(newLines[j] .. "\n")
    end

    return newLines
    -- or

    -- local ss = ""
    -- for i = 1, #newLines do
    --     ss = ss .. newLines[i] .. "\n"
    -- end
    -- -- print(ss)
    -- return ss
end

return {
    tabular = tabular
}

-- tabular(test)
