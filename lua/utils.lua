local function FindProjectRoot(root_markers)
    -- Start from the directory of the current file or current working directory
    local current_dir = vim.fn.expand('%:p:h')
    -- print(current_dir)

    local drive_letter = current_dir:match("^oil:///([A-Z])")
    -- print(drive_letter)
    if drive_letter then
        current_dir = current_dir:gsub("oil:///" .. drive_letter, drive_letter .. ":")
        -- print(current_dir)
    end

    -- if current_dir:match("^oil:///.*") then
    --     current_dir = current_dir:gsub("oil:///", "")
    --     print("matched oil :  " .. current_dir)
    --
    --     local firstChar = current_dir:match("^[ ]*([A-Z])[/]")
    --     print("firstChar :  [" .. firstChar .. "]")
    --     current_dir = current_dir:gsub(firstChar, firstChar .. ":")
    -- end
    -- print(current_dir)
    if (current_dir == '') then
        current_dir = vim.fn.getcwd()
    end

    -- Convert to absolute path and normalize
    current_dir = vim.fn.fnamemodify(current_dir, ':p')

    -- Traverse upwards until we find a marker
    local root = ''
    local dir = current_dir

    while (dir ~= '/') do
        -- Check for any marker in current directory
        for _, marker in ipairs(root_markers) do
            local marker_files = vim.fn.glob(dir .. '\\' .. marker, true, true)

            if vim.fn.filereadable(dir .. '\\' .. marker:gsub("*", "")) == 1 then
                root = dir
                break;
            end

            if vim.fn.len(marker_files) > 0 then
                root = dir
                break
            end

            if vim.fn.isdirectory(dir .. '\\' .. marker) == 1 then
                root = dir
                break
            end
        end

        if (root ~= '') then
            break
        end

        -- Move to parent directory
        local parent = vim.fn.fnamemodify(dir, ':h')
        if (parent == dir) then -- We've reached the filesystem root
            break
        end

        dir = parent
    end

    -- print(root)
    return root
end


local function save_csharp_buffers()
    for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
        if vim.api.nvim_buf_is_loaded(bufnr) then
            local name = vim.api.nvim_buf_get_name(bufnr)
            if name:match("%.cs$") then
                if vim.api.nvim_buf_get_option(bufnr, "modified") then
                    vim.api.nvim_buf_call(bufnr, function()
                        vim.cmd("update")
                    end)
                end
            end
        end
    end
end

local function save_c_buffers()
    for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
        if vim.api.nvim_buf_is_loaded(bufnr) then
            local name = vim.api.nvim_buf_get_name(bufnr)
            if name:match("%.c$") then
                if vim.api.nvim_buf_get_option(bufnr, "modified") then
                    vim.api.nvim_buf_call(bufnr, function()
                        vim.cmd("update")
                    end)
                end
            end
            if name:match("%.h$") then
                if vim.api.nvim_buf_get_option(bufnr, "modified") then
                    vim.api.nvim_buf_call(bufnr, function()
                        vim.cmd("update")
                    end)
                end
            end
        end
    end
end

local function uuid_v4_()
    local bytes = vim.loop.random(16)
    bytes = { bytes:byte(1, 16) }

    -- bytes[7] = (bytes[7] & 0x0f) | 0x40 -- version 4
    -- bytes[9] = (bytes[9] & 0x3f) | 0x80 -- variant
    bytes[7] = bit.bor(bit.band(bytes[7], 0x0f), 0x40)
    bytes[9] = bit.bor(bit.band(bytes[9], 0x3f), 0x80)

    return string.format("%02x%02x%02x%02x-%02x%02x-%02x%02x-%02x%02x-%02x%02x%02x%02x%02x%02x", unpack(bytes)
    )
end

local function ensure_file_(path)
    -- print(path)
    if path == nil or vim.startswith(path, "\\") then
        return
    end

    local dir = vim.fn.fnamemodify(path, ":h")

    -- create directories
    if vim.fn.isdirectory(dir) == 0 then
        vim.fn.mkdir(dir, "p")
    end

    -- create file
    if vim.fn.filereadable(path) == 0 then
        vim.fn.writefile({}, path)
    end
end

local function get_visual_selection()
    -- save register
    local reg = vim.fn.getreg('"')
    local regtype = vim.fn.getregtype('"')

    -- yank visual selection
    vim.cmd('silent normal! "vy')

    local visual_selection = vim.fn.getreg('"')

    -- restore register
    vim.fn.setreg('"', reg, regtype)

    -- print(visual_selection)
    return visual_selection
end

return {
    FindProjectRoot = FindProjectRoot,
    save_csharp_buffers = save_csharp_buffers,
    save_c_buffers = save_c_buffers,
    generate_uuid = uuid_v4_,
    ensure_file = ensure_file_,
    get_visual_selection = get_visual_selection,
}
