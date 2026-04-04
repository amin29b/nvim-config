local ns = vim.api.nvim_create_namespace("cursor_word_highlight")
local utils = require("utils")

local function escape_lua_pattern(text)
    return text:gsub("([^%w])", "%%%1")
end

local special = {
    ["`"] = true,
    ["~"] = true,

    ["!"] = true,
    ["@"] = true,
    ["#"] = true,
    ["$"] = true,
    ["%"] = true,
    ["^"] = true,
    ["&"] = true,
    ["*"] = true,
    ["("] = true,
    [")"] = true,
    ["-"] = true,
    ["+"] = true,
    ["="] = true,

    ["["] = true,
    ["{"] = true,
    ["]"] = true,
    ["}"] = true,

    ["\\"] = true,
    ["|"] = true,

    [";"] = true,
    [":"] = true,
    ["'"] = true,
    ["\""] = true,

    [","] = true,
    ["<"] = true,
    ["."] = true,
    [">"] = true,
    ["/"] = true,
    ["?"] = true,
}

local function get_target()
    local result = ""
    local visual = utils.get_visual_selection_buf()
    if visual and visual ~= "" then
        result = visual
    else
        local char_under_cursor = ""
        local col = vim.fn.col(".")
        local line = vim.fn.getline(".")
        char_under_cursor = line:sub(col, col)
        if special[char_under_cursor] then
            result = char_under_cursor
        elseif char_under_cursor == " " then
            result = ""
        else
            result = vim.fn.expand("<cword>")
        end
    end


    return result
end

local function highlight_visible()
    vim.api.nvim_buf_clear_namespace(0, ns, 0, -1)

    local text = get_target()
    if not text or text == "" then
        return
    end

    text = escape_lua_pattern(text)

    local start_line = vim.fn.line("w0") - 1
    local end_line = vim.fn.line("w$")
    local lines = vim.api.nvim_buf_get_lines(0, start_line, end_line, false)

    for i, line in ipairs(lines) do
        local from = 1
        while true do
            local s, e = string.find(line, text, from)
            if not s then
                break
            end

            vim.api.nvim_buf_add_highlight(
                0,
                ns,
                "HighlighCursorWord",
                start_line + i - 1,
                s - 1,
                e
            )

            from = e + 1
        end
    end
end

vim.api.nvim_create_autocmd(
    { "CursorMoved", "CursorMovedI", "WinScrolled", "ModeChanged" },
    { callback = highlight_visible }
)
