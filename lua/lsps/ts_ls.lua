return {
    setup = function()
        local ts_ls_path = vim.fn.stdpath("config") ..
            "/lsp/typescript-language-server/node_modules/.bin/typescript-language-server.cmd"
        ts_ls_path = vim.fn.expand(ts_ls_path)
        vim.lsp.config('tsserver', {
            cmd = { ts_ls_path, "--stdio" },
            filetypes = {
                'javascript', 'javascriptreact'
            , 'javascript.jsx'
            , 'typescript', 'typescriptreact'
            , 'typescript.tsx', 'html' },
            on_attach = function(client, bufnr)
                require("keymaps").lsp_mappings(bufnr)
            end,
        })
        vim.lsp.enable('tsserver')
    end,
}
