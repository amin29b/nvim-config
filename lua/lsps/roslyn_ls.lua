local function BuildCSharpProject()
    local now = os.date("%Y-%m-%d %H:%M:%S")
    local root_markers = { '*.root', '*.sln', '.git' }
    local project_root = require("utils").FindProjectRoot(root_markers)
    project_root = vim.fn.shellescape(project_root)
    require("utils").save_csharp_buffers()
    vim.cmd [[
        set cmdheight=4
        highlight BuildS guifg=#00FF00
        highlight BuildF guifg=#FF0000
    ]]

    local messages = {}
    local m1 = "==========  " .. now .. "   =========="
    local m2 = "==========  Building ...          =========="
    table.insert(messages, m1);
    table.insert(messages, m2);
    vim.api.nvim_echo({ { table.concat(messages, "\n"), "" } }, false, {})

    vim.fn.jobstart(
        "msbuild  /m  " ..
        project_root .. "   /p:WarningLevel=0" .. "   /clp:ErrorsOnly" .. "   /nologo " .. "/verbosity:quiet"
        , {
            stdout_buffered = true,
            stderr_buffered = true,
            on_stdout = function(_, data)
                vim.cmd('set cmdheight=4')
                if #data == 1 and data[1] == "" then
                    local now = os.date("%Y-%m-%d %H:%M:%S")
                    local message1 = "==========  " .. now .. "   =========="
                    local message2 = "==========  🗹  Build succeeded.   =========="
                    table.insert(messages, message1);
                    table.insert(messages, message2);
                    -- table.insert(messages, vim.inspect(data));
                    vim.api.nvim_echo({ { table.concat(messages, "\n"), "BuildS" } }, false, {})
                    vim.fn.setqflist({}, "r")
                    vim.cmd('cwindow')
                else
                    local now = os.date("%Y-%m-%d %H:%M:%S")
                    local message1 = "==========  " .. now .. "   =========="
                    local message2 = "==========  ⮽ Build failed        ==========" ..
                        "   Error Count : " .. (#data - 1)
                    table.insert(messages, message1);
                    table.insert(messages, message2);
                    -- table.insert(messages, vim.inspect(data));
                    vim.api.nvim_echo({ { table.concat(messages, "\n"), "BuildF" } }, false, {})


                    local qf_lines = {}
                    for _, line in ipairs(data) do
                        if line ~= "" then
                            line = line:gsub("%s*%[.-%]%s*$", "")
                            table.insert(qf_lines, line)
                        end
                    end

                    local efm = '%f(%l\\,%c):\\ %t%*[^\\ ]%m'
                    vim.fn.setqflist({}, "r", {
                        lines = qf_lines,
                        efm = efm
                    })


                    vim.api.nvim_create_augroup("GroupChangeCmdHeight", { clear = true })
                    vim.cmd('copen')
                    vim.cmd('setlocal wrap')
                    vim.cmd('wincmd p')
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
            end,
            on_stderr = function(_, data)
            end,
            on_exit = function(_, code)
            end
        })
end

return {
    setup = function()
        local roslyn_path = vim.fn.stdpath("config") .. "/lsp/roslyn-lsp/Microsoft.CodeAnalysis.LanguageServer.exe"
        roslyn_path = vim.fn.expand(roslyn_path)
        -- print(roslyn_path)
        vim.lsp.config('roslyn_ls', {
            name = "roslyn_ls",
            cmd = { roslyn_path, '--stdio', '--logLevel', 'Information', '--extensionLogDirectory', vim.fn.expand('~/roslyn/logs') },
            filetypes = { 'cs' },
            on_attach = function(client, bufnr)
                vim.api.nvim_create_user_command("Build", BuildCSharpProject, {})
                vim.keymap.set("n", "<leader>bb", "<CMD>Build<CR>", {})
                require("keymaps").lsp_mappings(bufnr)
            end
        })
        vim.g.dotnet_errors_only = true
        vim.g.dotnet_show_project_file = false
        vim.lsp.enable('roslyn_ls')
    end,
}
