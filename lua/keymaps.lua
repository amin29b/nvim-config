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
    vim.keymap.set("i", "<C-h>", "<left>")
    vim.keymap.set("i", "<C-j>", "<down>")
    vim.keymap.set("i", "<C-k>", "<up>")
    vim.keymap.set("i", "<C-l>", "<right>")

    -- Command-line mode
    vim.keymap.set("c", "<C-h>", "<left>")
    vim.keymap.set("c", "<C-j>", "<down>")
    vim.keymap.set("c", "<C-k>", "<up>")
    vim.keymap.set("c", "<C-l>", "<right>")

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

    vim.keymap.set("n", "<leader>jo", '<cmd>MyJumps<cr>')
    vim.keymap.set("n", "<leader>jj", '<cmd>lua add_jump()<cr>')

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

function M.fzflua()
    -- local opts = { buffer = bufnr }
    local opts = {}

    vim.keymap.set("n", "<leader>/", function()
        require("fzf-lua").lgrep_curbuf()
    end, opts)
    vim.keymap.set("v", "<leader>/", function()
        require("fzf-lua").grep_visual({ cwd = vim.fn.expand("%:p:h") })
    end, opts)

    vim.keymap.set("n", "<leader>ls", function()
        require("fzf-lua").buffers()
    end, opts)
end

return M
