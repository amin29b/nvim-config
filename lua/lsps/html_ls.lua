return {
    setup = function()
        local html_ls_path = vim.fn.stdpath("config") ..
            "/lsp/html-lsp/node_modules/.bin/vscode-html-language-server.cmd"
        html_ls_path = vim.fn.expand(html_ls_path)
        vim.lsp.config('htmlserver', {
            cmd = { html_ls_path, "--stdio" },
            filetypes = {
                'html'
            },
            init_options = {
                provideFormatter = true
            },
            settings = {
                html = {
                    hover = { documentation = true, references = true },
                    validate = true
                }
            },
            on_attach = function(client, bufnr)
                require("keymaps").lsp_mappings(bufnr)
            end,
        })
        vim.lsp.enable('htmlserver')
    end,
}
