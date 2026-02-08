local M = {}

local uv = vim.uv
local fs = vim.fs

local function FindProjectSlnFile(filepath)
    local root_markers = { '*.sln' }
    -- Start from the directory of the current file or current working directory
    local current_dir = vim.fn.expand(filepath)
    -- print(current_dir)

    -- Convert to absolute path and normalize
    current_dir = vim.fn.fnamemodify(current_dir, ':p')

    -- Traverse upwards until we find a marker
    local root = ''
    local dir = current_dir

    while (dir ~= '/') do
        -- Check for any marker in current directory
        for _, marker in ipairs(root_markers) do
            local marker_files = vim.fn.glob(dir .. '\\' .. marker, true, true)
            if vim.fn.len(marker_files) > 0 then
                root = marker_files[1]
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


-- local configs = {}
local name = "roslyn_ls"
local offset_encoding = 'utf-8'
local filetypes = { 'cs' }

local function get_cmd()
    -- vim.lsp.config['roslyn_ls'].cmd_env = get_env()
    local roslyn_path = vim.fn.stdpath("config") .. "/lsp/roslyn-lsp/Microsoft.CodeAnalysis.LanguageServer.exe"
    roslyn_path = vim.fn.expand(roslyn_path)
    -- print(roslyn_path)

    return { roslyn_path
    , '--stdio', '--logLevel', 'Information', '--extensionLogDirectory'
    , vim.fn.expand('~/roslyn/logs')
    }
end

local function get_configs_from_sln(sln)
    local configs = {}
    for line in io.lines(sln) do
        -- print(line)
        local cfg = line:match("^%s*([^|]+)|Any CPU%s*=")
        if cfg then
            -- print(cfg)
            configs[cfg] = true
        end
    end
    return vim.tbl_keys(configs)
end

local function select_build_config(callback, filepath)
    local slnfile = FindProjectSlnFile(filepath)
    -- print(slnfile)
    local configs = get_configs_from_sln(slnfile)
    -- local configs =
    -- {
    --     "Debug"
    --     , "Release"
    -- } -- put your custom ones here

    vim.ui.select(configs, {
        prompt = "Select build configuration:",
    }, function(choice)
        if not choice then
            return
        end
        callback(choice)
    end)
end

local function get_env(filepath)
    local configuration = ""
    local platform = "AnyCPU"
    select_build_config(function(config)
        configuration = config
    end, filepath)
    -- print(configuration)

    return {
        Configuration = configuration,
        Platform = platform,
    }
end



local function on_init_sln(client, target)
    vim.notify('Initializing: ' .. target, vim.log.levels.TRACE, { title = 'roslyn_ls' })
    ---@diagnostic disable-next-line: param-type-mismatch
    client:notify('solution/open', {
        solution = vim.uri_from_fname(target),
    })
end

local function on_init_project(client, project_files)
    vim.notify('Initializing: projects', vim.log.levels.TRACE, { title = 'roslyn_ls' })
    ---@diagnostic disable-next-line: param-type-mismatch
    client:notify('project/open', {
        projects = vim.tbl_map(function(file)
            return vim.uri_from_fname(file)
        end, project_files),
    })
end

local function roslyn_handlers()
    return {
        ["textDocument/publishDiagnostics"] = vim.lsp.with(
            vim.lsp.diagnostic.on_publish_diagnostics, {
                virtual_text = false,
                signs = true,
                underline = true,
                update_in_insert = false,
            }),
        ['workspace/projectInitializationComplete'] = function(_, _, ctx)
            vim.notify('Roslyn project initialization complete', vim.log.levels.INFO, { title = 'roslyn_ls' })

            local buffers = vim.lsp.get_buffers_by_client_id(ctx.client_id)
            local client = assert(vim.lsp.get_client_by_id(ctx.client_id))
            for _, buf in ipairs(buffers) do
                client:request(vim.lsp.protocol.Methods.textDocument_diagnostic, {
                    textDocument = vim.lsp.util.make_text_document_params(buf),
                }, nil, buf)
            end
        end,
        ['workspace/_roslyn_projectHasUnresolvedDependencies'] = function()
            vim.notify('Detected missing dependencies. Run `dotnet restore` command.', vim.log.levels.ERROR, {
                title = 'roslyn_ls',
            })
            return vim.NIL
        end,
        ['workspace/_roslyn_projectNeedsRestore'] = function(_, result, ctx)
            local client = assert(vim.lsp.get_client_by_id(ctx.client_id))

            ---@diagnostic disable-next-line: param-type-mismatch
            client:request('workspace/_roslyn_restore', result, function(err, response)
                if err then
                    vim.notify(err.message, vim.log.levels.ERROR, { title = 'roslyn_ls' })
                end
                if response then
                    for _, v in ipairs(response) do
                        vim.notify(v.message, vim.log.levels.INFO, { title = 'roslyn_ls' })
                    end
                end
            end)

            return vim.NIL
        end,
        ['razor/provideDynamicFileInfo'] = function(_, _, _)
            vim.notify(
                'Razor is not supported.\nPlease use https://github.com/tris203/rzls.nvim',
                vim.log.levels.WARN,
                { title = 'roslyn_ls' }
            )
            return vim.NIL
        end,
    }
end




local function roslyn_settings()
    return {
        ["csharp|solution"] = {
            loadProjectsOnDemand = false,
        },
        ['csharp|background_analysis'] = {
            dotnet_analyzer_diagnostics_scope = 'OpenFiles',
            dotnet_compiler_diagnostics_scope = 'CurrentDocument',
        },
        ['csharp|inlay_hints'] = {
            csharp_enable_inlay_hints_for_implicit_object_creation = false,
            csharp_enable_inlay_hints_for_implicit_variable_types = false,
            csharp_enable_inlay_hints_for_lambda_parameter_types = false,
            csharp_enable_inlay_hints_for_types = false,
            dotnet_enable_inlay_hints_for_indexer_parameters = false,
            dotnet_enable_inlay_hints_for_literal_parameters = false,
            dotnet_enable_inlay_hints_for_object_creation_parameters = false,
            dotnet_enable_inlay_hints_for_other_parameters = false,
            dotnet_enable_inlay_hints_for_parameters = false,
            dotnet_suppress_inlay_hints_for_parameters_that_differ_only_by_suffix = false,
            dotnet_suppress_inlay_hints_for_parameters_that_match_argument_name = false,
            dotnet_suppress_inlay_hints_for_parameters_that_match_method_intent = false,
        },
        ['csharp|symbol_search'] = {
            dotnet_search_reference_assemblies = false,
        },
        ['csharp|completion'] = {
            dotnet_show_name_completion_suggestions = false,
            dotnet_show_completion_items_from_unimported_namespaces = false,
            dotnet_provide_regex_completions = false,
        },
        ['csharp|code_lens'] = {
            dotnet_enable_references_code_lens = false,
        },
    }
end

local function capabilities()
    return {
        -- HACK: Doesn't show any diagnostics if we do not set this to true
        textDocument = {
            diagnostic = {
                dynamicRegistration = true,
            },
        },
    }
end




local function root_dir(bufnr, cb)
    -- vim.lsp.config['roslyn_ls'].cmd_env = get_env()
    local bufname = vim.api.nvim_buf_get_name(bufnr)
    -- don't try to find sln or csproj for files from libraries
    -- outside of the project
    if not bufname:match('^' .. fs.joinpath('/tmp/MetadataAsSource/')) then
        -- try find solutions root first
        local root_dir = fs.root(bufnr, function(fname, _)
            return fname:match('%.sln[x]?$') ~= nil
        end)

        if not root_dir then
            -- try find projects root
            root_dir = fs.root(bufnr, function(fname, _)
                return fname:match('%.csproj$') ~= nil
            end)
        end

        if root_dir then
            cb(root_dir)
        end
    end
end

local function on_init(client)
    local root_dir = client.config.root_dir

    -- try load first solution we find
    for entry, type in fs.dir(root_dir) do
        if type == 'file' and (vim.endswith(entry, '.sln') or vim.endswith(entry, '.slnx')) then
            on_init_sln(client, fs.joinpath(root_dir, entry))
            return
        end
    end

    -- if no solution is found load project
    for entry, type in fs.dir(root_dir) do
        if type == 'file' and vim.endswith(entry, '.csproj') then
            on_init_project(client, { fs.joinpath(root_dir, entry) })
        end
    end
end

local function on_attach(client, bufnr)
    vim.api.nvim_create_user_command("Build", BuildCSharpProject, {})
    vim.keymap.set("n", "<leader>bb", "<CMD>Build<CR>", {})
    require("keymaps").lsp_mappings(bufnr)
end

local function setup()
    vim.lsp.config('roslyn_ls', {
        name = name,
        cmd = get_cmd(),
        on_init = on_init,
        filetypes = filetypes,
        on_attach = on_attach,
        root_dir = root_dir,
        handlers = roslyn_handlers(),
        settings = roslyn_settings(),
        filewatching = true,
        offset_encoding = offset_encoding,
        capabilities = capabilities(),
    })
    vim.g.dotnet_errors_only = true
    vim.g.dotnet_show_project_file = false
    vim.lsp.enable('roslyn_ls')
end

M.setup = setup
vim.api.nvim_create_autocmd("FileType", {
    pattern = "cs",
    once = true,
    callback = function(args)
        local bufnr = args.buf
        local filepath = vim.api.nvim_buf_get_name(bufnr)
        -- print("C# file:", filepath)
        vim.lsp.config['roslyn_ls'].cmd_env = get_env(filepath)
    end,
})

return M
