return {
    setup = function()
        local json_ls_path = vim.fn.stdpath("config") ..
            "/lsp/html-lsp/node_modules/.bin/vscode-json-language-server.cmd"
        json_ls_path = vim.fn.expand(json_ls_path)


        vim.lsp.config('jsonserver', {
            cmd = { json_ls_path, "--stdio" },
            filetypes = {
                'json',
            },
            init_options = {
                provideFormatter = true
            },
            on_attach = function(client, bufnr)
                require("keymaps").lsp_mappings(bufnr)
            end,
        })



        vim.lsp.enable('jsonserver')
    end,
}
