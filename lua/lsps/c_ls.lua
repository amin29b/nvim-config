local M = {}
local utils = require("utils");
local keymaps = require("keymaps");

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

local function set_env_vars()
    if vim.g.visual_studio_paths_added then
        return
    else
        vim.g.visual_studio_paths_added = true
    end

    local path = ""
    path = path ..
        ";C:\\Program Files\\Microsoft Visual Studio\\2022\\Enterprise\\VC\\Tools\\MSVC\\14.34.31933\\bin\\HostX64\\x64;"
    path = path .. ";C:\\Program Files\\Microsoft Visual Studio\\2022\\Enterprise\\Common7\\IDE\\VC\\VCPackages;"
    -- path = path .. ";C:\\Program Files (x86)\\Microsoft SDKs\\Windows\\v10.0A\\bin\\NETFX 4.8 Tools\\x64\\;"
    path = path .. ";C:\\Program Files (x86)\\Windows Kits\\10\\bin\\10.0.22000.0\\\\x64;"
    path = path .. ";C:\\Program Files (x86)\\Windows Kits\\10\\bin\\\\x64;"
    path = path .. ";C:\\Program Files\\Microsoft Visual Studio\\2022\\Enterprise\\Common7\\IDE\\;"
    path = path .. ";C:\\Program Files\\Microsoft Visual Studio\\2022\\Enterprise\\Common7\\Tools\\;"

    local include = ""
    include = include ..
        ";C:\\Program Files\\Microsoft Visual Studio\\2022\\Enterprise\\VC\\Tools\\MSVC\\14.34.31933\\include;"
    include = include ..
        ";C:\\Program Files\\Microsoft Visual Studio\\2022\\Enterprise\\VC\\Tools\\MSVC\\14.34.31933\\ATLMFC\\include;"
    include = include .. ";C:\\Program Files\\Microsoft Visual Studio\\2022\\Enterprise\\VC\\Auxiliary\\VS\\include;"
    include = include .. ";C:\\Program Files (x86)\\Windows Kits\\10\\include\\10.0.22000.0\\ucrt;"
    include = include .. ";C:\\Program Files (x86)\\Windows Kits\\10\\\\include\\10.0.22000.0\\\\um;"
    include = include .. ";C:\\Program Files (x86)\\Windows Kits\\10\\\\include\\10.0.22000.0\\\\shared;"
    include = include .. ";C:\\Program Files (x86)\\Windows Kits\\10\\\\include\\10.0.22000.0\\\\winrt;"
    include = include .. ";C:\\Program Files (x86)\\Windows Kits\\10\\\\include\\10.0.22000.0\\\\cppwinrt;"
    include = include .. ";C:\\Program Files (x86)\\Windows Kits\\NETFXSDK\\4.8\\include\\um;"

    local lib = ""
    lib = lib ..
        ";C:\\Program Files\\Microsoft Visual Studio\\2022\\Enterprise\\VC\\Tools\\MSVC\\14.34.31933\\ATLMFC\\lib\\x64;"
    lib = lib .. ";C:\\Program Files\\Microsoft Visual Studio\\2022\\Enterprise\\VC\\Tools\\MSVC\\14.34.31933\\lib\\x64;"
    lib = lib .. ";C:\\Program Files (x86)\\Windows Kits\\NETFXSDK\\4.8\\lib\\um\\x64;"
    lib = lib .. ";C:\\Program Files (x86)\\Windows Kits\\10\\lib\\10.0.22000.0\\ucrt\\x64;"
    lib = lib .. ";C:\\Program Files (x86)\\Windows Kits\\10\\\\lib\\10.0.22000.0\\\\um\\x64;"


    local libpath = ""
    libpath = libpath ..
        ";C:\\Program Files\\Microsoft Visual Studio\\2022\\Enterprise\\VC\\Tools\\MSVC\\14.34.31933\\ATLMFC\\lib\\x64;"
    libpath = libpath ..
        ";C:\\Program Files\\Microsoft Visual Studio\\2022\\Enterprise\\VC\\Tools\\MSVC\\14.34.31933\\lib\\x64;"
    libpath = libpath ..
        ";C:\\Program Files\\Microsoft Visual Studio\\2022\\Enterprise\\VC\\Tools\\MSVC\\14.34.31933\\lib\\x86\\store\\references;"
    libpath = libpath .. ";C:\\Program Files (x86)\\Windows Kits\\10\\UnionMetadata\\10.0.22000.0;"
    libpath = libpath .. ";C:\\Program Files (x86)\\Windows Kits\\10\\References\\10.0.22000.0;"
    libpath = libpath .. ";C:\\Windows\\Microsoft.NET\\Framework64\\v4.0.30319;"

    if vim.env.PATH == nil then
        vim.env.PATH = " "
    end
    if vim.env.INCLUDE == nil then
        vim.env.INCLUDE = " "
    end
    if vim.env.LIB == nil then
        vim.env.LIB = " "
    end
    if vim.env.LIBPATH == nil then
        vim.env.LIBPATH = " "
    end


    vim.env.PATH    = path .. vim.env.PATH
    vim.env.INCLUDE = include .. vim.env.INCLUDE
    vim.env.LIB     = lib .. vim.env.LIB
    vim.env.LIBPATH = libpath .. vim.env.LIBPATH
end


local function FindProjectRoot()
    local root_markers = { '*.root', '.git', 'package.json', 'Makefile' }
    local project_root = utils.FindProjectRoot(root_markers)
    return project_root;
end

local function set_errors_quickfix_list(data)
    local quickfix_list_lines = {}
    for _, line in ipairs(data) do
        if line ~= "" then
            -- line = line:gsub("%s*%[.-%]%s*$", "")
            line = line:gsub("\r$", "")
            if string.find(line, " error ") and (not string.find(line, " error C2220")) then
                table.insert(quickfix_list_lines, line)
            end
        end
    end

    return quickfix_list_lines
end

local function set_warnings_quickfix_list(data)
    local quickfix_list_lines = {}
    for _, line in ipairs(data) do
        if line ~= "" then
            -- line = line:gsub("%s*%[.-%]%s*$", "")
            line = line:gsub("\r$", "")
            if string.find(line, " warning ") and (not string.find(line, " error C2220")) then
                table.insert(quickfix_list_lines, line)
            end
        end
    end


    return quickfix_list_lines
end

local function set_qucikfix(quickfix_list_lines)
    -- local error_format = '%f(%l):\\ %t%*[^:]:\\ %m'
    -- local error_format = '%f(%l):\\ %t%*[^:]:\\ %m'
    vim.fn.setqflist({}, "r", {
        lines = quickfix_list_lines,
        -- efm = error_format
    })
end

local function Build(callback, hotReload)
    local now = os.date("%Y-%m-%d %H:%M:%S")
    local project_root = FindProjectRoot()
    save_c_buffers()
    vim.cmd [[
                        set cmdheight=4
                        highlight BuildS guifg=#00FF00
                        highlight BuildF guifg=#FF0000
                    ]]

    vim.cmd('cd ' .. vim.fn.printf(project_root))
    local messages = {}
    local m1 = "==========  " .. now .. "   =========="
    local m2 = "==========  Building ...          =========="
    table.insert(messages, m1);
    table.insert(messages, m2);
    vim.api.nvim_echo({ { table.concat(messages, "\n"), "" } }, false, {})


    local build_bat = vim.fn.printf(project_root .. "\\build.bat")
    vim.fn.jobstart(
        { build_bat, project_root, hotReload }
        , {
            stdout_buffered = true,
            stderr_buffered = true,
            on_stdout = function(_, data)
                local result = false
                local now = os.date("%Y-%m-%d %H:%M:%S")
                local message1 = "==========  " .. now .. "   =========="
                vim.cmd('set cmdheight=4')
                vim.cmd('set cmdheight=4')



                -- print("OUT2(0): " .. data[#data])
                -- print("OUT(-1): " .. data[#data - 1])
                -- print("OUT(-2): " .. data[#data - 2])
                -- print("OUT(-3): " .. data[#data - 3])
                if data[#data - 1] == "Build successful\r" then
                    --======================================================================================================================================
                    local qf_lines_warnings = set_warnings_quickfix_list(data)
                    set_qucikfix(qf_lines_warnings)
                    local message2 = "==========  🗹  Build succeeded.   ==========" ..
                        "   Warning Count: " .. (#qf_lines_warnings)

                    table.insert(messages, message1);
                    table.insert(messages, message2);
                    -- table.insert(messages, vim.inspect(data));
                    vim.api.nvim_echo({ { table.concat(messages, "\n"), "BuildS" } }, false, {})



                    if #qf_lines_warnings > 0 then
                        vim.api.nvim_create_augroup("GroupChangeCmdHeight", { clear = true })
                        vim.cmd('copen')
                        vim.cmd('setlocal wrap')
                        vim.cmd('wincmd p')
                    else
                        vim.fn.setqflist({}, "r")
                        vim.cmd('cwindow')
                    end


                    result = true
                    --======================================================================================================================================
                else
                    --======================================================================================================================================
                    local qf_lines_errors = set_errors_quickfix_list(data)
                    local qf_lines_warnings = set_warnings_quickfix_list(data)
                    local qf_lines = {}
                    for _, v in ipairs(qf_lines_errors) do
                        table.insert(qf_lines, v)
                    end
                    for _, v in ipairs(qf_lines_warnings) do
                        table.insert(qf_lines, v)
                    end
                    set_qucikfix(qf_lines)

                    local message2 = "==========  ⮽ Build failed        ==========" ..
                        "   Error Count: " .. (#qf_lines_errors) ..
                        "   Warning Count: " .. (#qf_lines_warnings)
                    table.insert(messages, message1);
                    table.insert(messages, message2);
                    -- table.insert(messages, vim.inspect(data));
                    vim.api.nvim_echo({ { table.concat(messages, "\n"), "BuildF" } }, false, {})



                    vim.api.nvim_create_augroup("GroupChangeCmdHeight", { clear = true })
                    vim.cmd('copen')
                    vim.cmd('setlocal wrap')
                    vim.cmd('wincmd p')


                    result = false
                    --======================================================================================================================================
                end

                local group = vim.api.nvim_create_augroup("GroupChangeCmdHeight", { clear = true })
                -- Create the autocmd in this group
                vim.api.nvim_create_autocmd("CursorMoved", {
                    group = group,
                    pattern = "*",
                    callback = function()
                        vim.cmd('set cmdheight=2')
                        vim.cmd('redraw!')
                        vim.api.nvim_create_augroup("GroupChangeCmdHeight", { clear = true })
                    end,
                })


                if type(callback) == "function" then
                    callback(result)
                end
            end,
            on_stderr = function(_, data)
            end,
            on_exit = function(_, code)
            end
        })
end

local function Debug()
    Build(function(result)
        if result then
            local project_root = FindProjectRoot()
            local debug_bat = vim.fn.printf(project_root .. "\\debug.bat")
            vim.fn.jobstart(
                { debug_bat, project_root }
                , {
                    stdout_buffered = true,
                    stderr_buffered = true,
                    on_stdout = function(_, data)
                    end,
                    on_stderr = function(_, data)
                    end,
                    on_exit = function(_, code)
                    end
                })
        end
    end)
end

local function HotRelaod()
    Build(nil, "HotReload")
end



M.setup = function()
    -- moved to build.bat file
    -- set_env_vars()
    vim.lsp.config('clangd', {
        name = "clangd",
        cmd = { "clangd",
            "--enable-config",
            "--header-insertion=never",
            "--header-insertion-decorators=0",
            "--function-arg-placeholders=false",
            "--limit-results=10",
            "--completion-style=bundled" },
        -- cmd = { "clangd"},



        filetypes = { 'c', 'cpp' },
        -- capabilities = require('skBlinkCmp').get_lsp_capabilities(),
        on_attach = function(client, bufnr)
            -- vim.lsp.semantic_tokens.enable(true)
            -- set_env_vars()
            --vim.bo.omnifunc = "v:lua.my_fuzzy_omni_complition"
            -- vim.fn.Lsp_mappings()

            keymaps.lsp_mappings(bufnr)
            local project_root = FindProjectRoot()
            -- print("PROOT: " .. project_root)
            project_root = vim.fn.shellescape(project_root)
            local path = project_root .. "\\misc\\nvim_config.lua"
            if vim.fn.filereadable(path) == 1 then
                --print("File exists: " .. path)
                dofile(path)
            end

            vim.api.nvim_create_user_command("Build", Build, {})
            vim.api.nvim_create_user_command("Debug", Debug, {})
            vim.api.nvim_create_user_command("HotRelaod", HotRelaod, {})

            vim.opt.formatoptions:remove({ "c", "r", "o" })
            -- vim.cmd [[let g:c_syntax_for_h = 1]]
        end
    })

    vim.lsp.enable('clangd')
end


return M
