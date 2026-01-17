local M = {}
local function SpellCheck(arg)
    local spell_restore = vim.o.spell
    vim.o.spell = true

    vim.api.nvim_create_augroup("restore_spell_option", { clear = true })

    vim.api.nvim_create_autocmd({ "CursorMoved", "CompleteDone" }, {
        buffer = 0,
        group = "restore_spell_option",
        once = true,
        callback = function()
            vim.o.spell = spell_restore
            vim.api.nvim_del_augroup_by_name("restore_spell_option")
        end,
    })

    return arg or ""
end



function M.setup()
    local opts = { noremap = true, silent = true }
    local opts2 = { remap = true, silent = true }
    -- -- Space
    vim.keymap.set("n", "<Space>", "<Nop>")
    vim.keymap.set("v", "<Space>", "<Nop>")

    -- Ctrl-Space
    vim.keymap.set("n", "<C-Space>", "<Nop>")
    vim.keymap.set("v", "<C-Space>", "<Nop>")
    vim.keymap.set("i", "<C-Space>", "<Nop>")

    -- Ctrl-C
    vim.keymap.set("n", "<C-c>", "<Nop>")
    vim.keymap.set("v", "<C-c>", "<Nop>")

    vim.keymap.set("n", "þ", "<Nop>")
    vim.keymap.set("v", "þ", "<Nop>")
    vim.keymap.set("i", "þ", "<Nop>")

    vim.keymap.set("n", "ý", "<Nop>")
    vim.keymap.set("v", "ý", "<Nop>")
    vim.keymap.set("i", "ý", "<Nop>")

    vim.keymap.set("n", "<C-S-b>", "<Nop>")
    vim.keymap.set("n", "<C-S-B>", "<Nop>")

    vim.keymap.set("v", ">", ">gv")
    vim.keymap.set("v", "<", "<gv")

    -- Insert mode
    vim.keymap.set("i", "<C-j>", "<Nop>")
    -- vim.keymap.set("i", "<C-h>", "<Nop>", { remap = true })

    -- i for Insert mode
    -- c for Command-line mode
    -- t for Terminal mode
    vim.keymap.set({ "i", "c", "t" }, "<C-h>", "<left>")
    vim.keymap.set({ "i", "c", "t" }, "<C-j>", "<down>")
    vim.keymap.set({ "i", "c", "t" }, "<C-k>", "<up>")
    vim.keymap.set({ "i", "c", "t" }, "<C-l>", "<right>")


    -- Normal mode
    vim.keymap.set("n", "<leader>so", ":source $MYVIMRC<CR>", opts)
    vim.keymap.set("n", "<leader>no", ":noh<CR>", opts)

    -- Insert mode (expr mappings)
    vim.keymap.set("i", "<Tab>", function()
        return vim.fn.pumvisible() == 1 and "<C-n>" or "<Tab>"
    end, { expr = true, noremap = true })

    vim.keymap.set("i", "<S-Tab>", function()
        return vim.fn.pumvisible() == 1 and "<C-p>" or "<S-Tab>"
    end, { expr = true, noremap = true })

    vim.keymap.set("i", "<CR>", function()
        return vim.fn.pumvisible() == 1 and "<C-y>" or "<CR>"
    end, { expr = true, noremap = true })

    vim.keymap.set("i", "<Esc>", function()
        return vim.fn.pumvisible() == 1 and "<C-e>" or "<Esc>"
    end, { expr = true, noremap = true })

    vim.keymap.set("i", "<C-x><C-k>", function()
        return SpellCheck("<C-x><C-k>")
    end, { expr = true, noremap = true })

    vim.keymap.set("n", "z=", function()
        SpellCheck()
        vim.cmd("normal! z=")
    end, { noremap = true, silent = true })

    vim.keymap.set("n", "<F6>", function()
        vim.fn.setreg("+", vim.fn.fnamemodify(vim.fn.expand("%"), ":p"))
    end, { noremap = true, silent = true })

    vim.keymap.set("n", "<leader>jo", '<cmd>MyProjectJumps<cr>')
    vim.keymap.set("n", "<leader>jj", '<cmd>AddProjectJump<cr>')

    -- vim.keymap.set("n", "<leader>jo", '<cmd>MyJumps<cr>')
    -- vim.keymap.set("n", "<leader>jj", '<cmd>lua add_jump()<cr>')

    -- vim.keymap.set("n", "<leader>ju", '<cmd>Jumps<cr>')

    local skComment = require("comment");
    vim.keymap.set('n', '<C-k><C-c>', skComment.comment, { expr = true, desc = 'Comment line' })
    vim.keymap.set('n', '<C-k><C-u>', skComment.uncomment, { expr = true, desc = 'Uncomment line' })

    vim.keymap.set('v', '<C-k><C-c>', skComment.comment_gv, { expr = true, desc = 'Comment line' })
    vim.keymap.set('v', '<C-k><C-u>', skComment.uncomment_gv, { expr = true, desc = 'Uncomment line' })

    vim.keymap.set("n", "-", "<CMD>Oil --float<CR>", { desc = "Open parent directory" })
    vim.keymap.set("n", "<leader>B", "<CMD>Build<CR>", { noremap = true, desc = "Build Project" })

    vim.api.nvim_create_autocmd("FileType", {
        pattern = "oil",
        callback = function()
            vim.keymap.set("n", "q", "<cmd>close<CR>", { buffer = true, silent = true, })
            vim.keymap.set("n", "", "<cmd>close<CR>", { buffer = true, silent = true, })
        end,
    })

    vim.keymap.set("n", "*", function()
        vim.fn.setreg("/", "\\c" .. vim.fn.expand("<cword>"))
        vim.cmd("normal! n")
    end, { noremap = true })

    -- vim.keymap.set("n", "#", function()
    --     vim.fn.setreg("/", vim.fn.expand("<cword>"))
    -- or
    -- vim.fn.setreg("/", "\\c" .. vim.fn.expand("<cword>"))
    --     vim.cmd("normal! N")
    -- end, { noremap = true })
    vim.keymap.set("v", "<leader>tt",
        function()
            local query = require("utils").get_visual_selection()
            if query == "" then
                return
            end
            require("tab").tabular(query)
        end
        , opts)
end

function M.lsp_mappings(bufnr)
    local opts = { buffer = bufnr }

    vim.keymap.set("n", "<F12>", vim.lsp.buf.definition, opts)
    vim.keymap.set("n", "<C-k><C-d>", vim.lsp.buf.format, opts)
    -- vim.keymap.set("n", "<C-k><C-d>", require("conform").format, opts)
    vim.keymap.set("n", "<C-k><C-r>", vim.lsp.buf.rename, opts)
    vim.keymap.set("n", "<C-k><C-l>", vim.lsp.buf.references, opts)
    vim.keymap.set("n", "<C-k><C-i>", function()
        vim.lsp.buf.hover({ border = "single" })
    end, opts)

    -- Code actions
    -- "<C-.> -> ý
    vim.keymap.set("n", "ý", vim.lsp.buf.code_action, opts)
    vim.keymap.set("v", "ý", vim.lsp.buf.code_action, opts)

    -- Diagnostics
    vim.keymap.set("n", "<C-l><C-p>", function()
        vim.diagnostic.setqflist({ severity = { min = vim.diagnostic.severity.WARN } })
    end, opts)

    vim.keymap.set("n", "<C-l><C-]>", function()
        vim.diagnostic.jump({ count = 1, float = false })
    end, opts)

    vim.keymap.set("n", "<C-l><C-[>", function()
        vim.diagnostic.jump({ count = -1, float = false })
    end, opts)

    vim.keymap.set("n", "<C-l><C-O>", function()
        vim.diagnostic.open_float({ border = "single" })
    end, opts)
end

function M.fzf_vim()
    -- local opts = { buffer = bufnr }
    local opts = {}

    vim.keymap.set("n", "<leader>/", "<cmd>BLines<cr>", opts)

    vim.keymap.set("v", "<leader>/",
        function() -- grep visual selection in current buffer
            local query = require("utils").get_visual_selection()
            if query == "" then
                return
            end
            vim.cmd("BLines " .. query)
        end
        , opts)



    vim.keymap.set("n", "<leader>g/",
        function()
            local cwd = require("utils").FindProjectRoot({ "*.root", ".git" }):gsub("\\", "/") -- IMPORTANT on Windows
            vim.cmd(string.format([[
                call fzf#vim#grep(
                \   'rg  --with-filename  --column --line-number --no-heading --color=always --smart-case '.shellescape(""),
                \       1,
                \       fzf#vim#with_preview({ 'dir' : '%s' ,'options': '--delimiter : --nth 3..'},'down', 'ctrl-/'),
                \       !0
                \   )
            ]], cwd))
        end
        , opts)


    -- fndprjroot
    vim.keymap.set("v", "<leader>g/",
        function()
            local query = require("utils").get_visual_selection()
            if query == "" then
                return
            end
            local cwd = require("utils").FindProjectRoot({ "*.root", ".git" }):gsub("\\", "/") -- IMPORTANT on Windows

            vim.cmd(string.format([[
                call fzf#vim#grep(
                \   'rg  --with-filename  --column --line-number --no-heading --color=always --smart-case '.shellescape(""),
                \       1,
                \       fzf#vim#with_preview({  'dir' : '%s' ,'options': '--query="%s"   --delimiter : --nth 3..'},'down', 'ctrl-/'),
                \       !0
                \   )
            ]], cwd, vim.fn.shellescape(query)))
        end
        , opts)

    vim.keymap.set("n", "<leader>ls",
        function()
            vim.cmd("Buffers")
        end
        , opts)
end

return M
