return {
    setup = function()
        local lua_ls_path = vim.fn.stdpath("config") .. "/lsp/lua-lsp/bin/lua-language-server.exe"
        lua_ls_path = vim.fn.expand(lua_ls_path)
        -- print(lua_ls_path)
        vim.lsp.config('lua_ls', {
            cmd = { lua_ls_path },
            root_markers = { ".luarc.json", ".luarc.jsonc", ".luacheckrc", ".stylua.toml", "stylua.toml", "selene.toml", "selene.yml", ".git" },
            filetypes = { "lua" },
            -- capabilities = require('skBlinkCmp').get_lsp_capabilities(),
            settings = {
                Lua = {
                    runtime = { version = 'LuaJIT', },
                    diagnostics = { globals = { 'vim', 'require' }, },
                    workspace = { library = vim.api.nvim_get_runtime_file("", true), },
                    telemetry = { enable = false, },
                },
            },
            on_attach = function(client, bufnr)
                require("keymaps").lsp_mappings(bufnr)
            end,
        })
        vim.lsp.enable('lua_ls')
    end
}
