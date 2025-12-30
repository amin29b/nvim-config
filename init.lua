vim.o.compatible = false
local termfeatures = vim.g.termfeatures or {}
termfeatures.osc52 = false
vim.g.termfeatures = termfeatures
vim.g.editorconfig = true
vim.opt.updatetime = 50

pcall(function()
    vim.o.shell = "powershell.exe"
    vim.opt.shellcmdflag = "-NoLogo -NoProfile -ExecutionPolicy RemoteSigned -Command"
    vim.opt.shellquote = ""
    vim.opt.shellxquote = ""
end)

vim.cmd.colorscheme("quiet")
vim.o.termguicolors = true
vim.o.guicursor     =
"a:blinkwait700-blinkoff400-blinkon250-Cursor/lCursor,n-v-c:block,i-ci-ve:ver25,r-cr:hor20,o:hor50,sm:block-blinkwait175-blinkoff150-blinkon175"


-- vim.cmd.colorscheme("slate")
vim.o.background     = "dark"
vim.o.virtualedit    = "all"
vim.o.mouse          = ""
vim.o.number         = true
vim.g.mapleader      = " "
vim.g.mapleaderlocal = " "
vim.o.cursorline     = true
vim.o.signcolumn     = "yes"
vim.o.belloff        = "all"
vim.o.winborder      = "single"
vim.o.swapfile       = false
vim.o.undofile       = true
vim.o.undodir        = vim.fn.expand("~/.nvim/undodir")
vim.o.incsearch      = true
vim.o.hlsearch       = true
vim.o.ignorecase     = true
vim.o.smartcase      = true
vim.opt.completeopt  = { "menuone", "popup", "fuzzy", "noselect" }
vim.o.ruler          = true
vim.o.laststatus     = 2
vim.o.showmode       = false
vim.o.scrolloff      = 5
vim.o.sidescrolloff  = 5 -- keep 5 columns visible left/right of cursor
vim.o.sidescroll     = 3
vim.o.wrap           = false
vim.o.tabstop        = 4
vim.o.shiftwidth     = 4
vim.o.expandtab      = true
vim.o.smartindent    = true
vim.o.syntax         = "on"

vim.o.cmdwinheight   = 20
vim.o.cmdheight      = 2

vim.o.splitbelow     = true
vim.o.splitright     = true
vim.o.showtabline    = 2
-- vim.o.formatoptions         = "jql"
-- vim.opt_local.formatoptions = "jql"
vim.opt.formatoptions:remove({ "c", "r", "o" })
vim.api.nvim_create_autocmd("BufEnter", {
    callback = function()
        vim.opt.formatoptions:remove({ "c", "r", "o" })
    end,
})
vim.o.backspace   = "indent,eol,start"

vim.o.wildmenu    = true
vim.o.wildmode    = "full"
vim.o.wildoptions = "pum"

vim.o.showmatch   = true
vim.o.showcmd     = true

vim.o.encoding    = "utf-8"
vim.o.autoindent  = true
vim.o.hidden      = true
-- vim.fn.wildtrigger = true


vim.o.foldenable = true
vim.o.foldexpr = 'v:lua.vim.lsp.foldexpr()'
vim.o.foldlevel = 99
vim.o.foldlevelstart = 99
vim.o.foldmethod = 'expr'
vim.opt.fillchars:append { fold = " " }
vim.opt.foldtext = "v:lua._G.MyFoldText()"
function _G.MyFoldText()
    local line = vim.fn.getline(vim.v.foldstart)
    return "> " .. line .. " [...]"
end




vim.diagnostic.config({
    severity_sort = true,
    update_in_insert = false,
    virtual_lines = false,
    virtual_text = false,
    underline = {
        severity = { min = vim.diagnostic.severity.WARN },
    },
    signs = {
        severity = { min = vim.diagnostic.severity.WARN }
    },
    jump = {
        severity = { min = vim.diagnostic.severity.WARN }
    }
})


local function terminal_setup()
    local terminal = require("terminal")
    terminal.setup()
end

require("sunglasses").setup({
    filter_type = "SHADE",
    filter_percent = 0.4,
    -- filter_type = "TINT",
    -- filter_percent = 0.2,
})

local function fzf_lua_setup()
    local fzflua = require("fzf-lua")
    fzflua.setup({
        fzf_opts = {
            ["--cycle"] = true,
            ["--ansi"] = true,
        },
        defaults = {
            git_icons = false,
            file_icons = false,
            color_icons = false,
        },
    })
    require("keymaps").fzflua()
end

local function keymaps_setup()
    local keymaps = require("keymaps")
    keymaps.setup()
end

local function colors_setup()
    local colors = require("colors")
    colors.setup()
end

-- pcall(fzf_lua_setup)

pcall(terminal_setup)
pcall(require, "statusline_setup")
pcall(require, "my_jumps")
pcall(require, "my_projects")
pcall(require, "my_project_jumps")
pcall(require, "comment")
pcall(require, "oil_setup")
keymaps_setup()
fzf_lua_setup()
colors_setup()

vim.api.nvim_create_autocmd("ColorScheme", {
    callback = function()
        colors_setup()
    end,
})


require("lsps.roslyn_ls").setup()
require("lsps.lua_ls").setup()
require("lsps.html_ls").setup()
require("lsps.ts_ls").setup()
require("lsps.css_ls").setup()
require("lsps.json_ls").setup()
