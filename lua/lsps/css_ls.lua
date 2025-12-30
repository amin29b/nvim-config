return {
    setup = function()
        local css_ls_path = vim.fn.stdpath("config") ..
            "/lsp/html-lsp/node_modules/.bin/vscode-css-language-server.cmd"
        css_ls_path = vim.fn.expand(css_ls_path)


        vim.lsp.config('cssserver', {
            cmd = { css_ls_path, "--stdio" },
            filetypes = {
                'css'
            },
            init_options = {
                provideFormatter = true
            },
            settings = {
                css = {
                    hover = { documentation = true, references = true },
                    validate = true
                }
            },
            on_attach = function(client, bufnr)
                require("keymaps").lsp_mappings(bufnr)
            end,
        })

        vim.lsp.enable('cssserver')
    end,
}
