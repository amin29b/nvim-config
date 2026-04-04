local M = {}

local color_text = "#FCFCFC"
local color_constant = "#CC8210"
local color_branch = "#1080FF"
local color_paren = "#a0c0FF"
local color_delimiter = "#7777cc"
local color_comment = "#10702b"

local ns = vim.api.nvim_create_namespace("dim_empty_lines")


local function highlight_empty_lines(buf)
    local buf = vim.api.nvim_get_current_buf()
    local win = vim.api.nvim_get_current_win()

    local top = vim.fn.line("w0") - 1
    local bottom = vim.fn.line("w$") - 1
    local cursor = vim.api.nvim_win_get_cursor(win)[1] - 1

    vim.api.nvim_buf_clear_namespace(buf, ns, top, bottom + 1)

    local lines = vim.api.nvim_buf_get_lines(buf, top, bottom + 1, false)

    for i, line in ipairs(lines) do
        local lnum = top + i - 1

        if lnum ~= cursor and line == "" then
            vim.api.nvim_buf_set_extmark(buf, ns, lnum, 0, {
                line_hl_group = "DimEmptyLine",
            })
        end
    end
end

local function set_matchadd_common()
    vim.fn.matchadd("ExtraWhitespace", "\\s\\+$")
    vim.fn.matchadd("TODOColor", "\\<TODO\\>")
    vim.fn.matchadd("NOTEColor", "\\<NOTE\\>")
    vim.fn.matchadd("STUDYColor", "\\<STUDY\\>")
    vim.fn.matchadd("IMPORTANTColor", "\\<IMPORTANT\\>")
    vim.fn.matchadd("FIXMEColor", "\\<FIXME\\>")
    vim.fn.matchadd("BUGColor", "\\<BUG\\>")
end
local function set_highlight_groups_common()
    local common_hls = {
        ["Normal"]             = { fg = color_text, bg = "#070707", italic = false, bold = false },
        ["DimEmptyLine"]       = { bg = "#101010" },
        ["HighlighCursorWord"] = { bg = "#101F3F" },
        ["@comment"]           = { fg = color_comment },
        ["Comment"]            = { fg = color_comment },

        ["@string.escape"]     = { fg = "#16c79a", bold = true },
        ["@character"]         = { fg = color_constant },
        ["@string"]            = { fg = color_constant },
        ["@number"]            = { fg = color_constant },
        ["@boolean"]           = { fg = color_constant },
        ["@constant.builtin"]  = { fg = color_constant },


        ["@variable"]                    = { fg = color_text },
        ["@variable.parameter"]          = { fg = color_text },
        ["@property"]                    = { fg = color_text },
        ["@keyword.import"]              = { fg = color_text },
        ["@keyword.type"]                = { fg = color_text },
        ["@type"]                        = { fg = color_text },
        ["@function"]                    = { fg = color_text },
        ["@type.builtin"]                = { fg = color_text },
        ["@keyword.directive.define"]    = { fg = color_text },
        ["@keyword.operator"]            = { fg = color_text },
        ["@keyword"]                     = { fg = "#777777", bold = true },
        ["Type"]                         = { fg = "#666666", bold = true },

        ["@keyword.repeat"]              = { fg = color_branch, bold = true },
        ["@keyword.conditional"]         = { fg = color_branch, bold = true },
        ["@keyword.conditional.ternary"] = { fg = color_branch, bold = true },
        ["@keyword.directive"]           = { fg = color_branch, bold = true },
        ["@keyword.return"]              = { fg = color_branch, bold = true },
        ["Statement"]                    = { fg = color_branch, bold = true },

        ["@operator"]                    = { fg = color_delimiter, bold = true },
        ["@lsp.type.operator"]           = { fg = color_delimiter, bold = true },
        ["@punctuation.delimiter"]       = { fg = color_delimiter, bold = true },
        ["@punctuation.bracket"]         = { fg = color_delimiter, bold = true },
        ["@constructor"]                 = { fg = color_delimiter, bold = true },
        ["@lsp.type.punctuation"]        = { fg = color_delimiter, bold = true },


        -- ["PreProc"]                   = { fg = "#006000", bold = true },
        -- ["PreProc"]                   = { fg = "#505020", bg = "#999999" },
        ["PreProc"]                  = { fg = color_branch },

        ["Folded"]                   = { fg = "#11A6FF", bg = "#111144", bold = true },
        -- ["LineNr"]                    = { fg = "#000000", bg = "#A6A6A6", bold = false, italic = false },
        ["Cursor"]                   = { bg = "#2CFF05" },
        -- ["Cursor"]                    = { bg = "#ff0000" },
        ["LineNr"]                   = { fg = "#101080", bg = "#A6A6A6", bold = false, italic = false },
        ["CursorLineNr"]             = { bg = "#101080", bold = true, italic = false },
        ["CursorLine"]               = { bg = "#101035", bold = false },
        ["SignColumn"]               = { bg = "#2e3440", bold = false, italic = true },
        ["EndOfBuffer"]              = { bg = "#111120", bold = false, italic = true },

        -- ["TODOColor"]                 = { fg = "#661111", bold = true },
        -- ["NOTEColor"]                 = { fg = "#11FF11", bold = true },
        ["TODOColor"]                = { fg = "#000000", bg = "#661111", bold = true, underline = true },
        ["NOTEColor"]                = { bg = "#000000", fg = "#119911", bold = true, underline = true },
        ["STUDYColor"]               = { bg = "#000000", fg = "#FFFF11", bold = true, underline = true },
        ["IMPORTANTColor"]           = { bg = "#000000", fg = "#FFFF11", bold = true, underline = true },
        ["FIXMEColor"]               = { fg = "#999900", bold = true },
        ["BUGColor"]                 = { fg = "#999900", bold = true },
        ["ExtraWhitespace"]          = { bg = "#321111", bold = true },

        ["OilDir"]                   = { fg = "#7aa2f7", bold = true },
        ["OilFile"]                  = { fg = "#c0caf5", bg = "NONE" },
        ["NormalFloat"]              = { fg = "NONE", bg = "NONE" },

        ["TabLineFill"]              = { fg = "NONE", bg = "#A6A6A6" },
        ["TabLine"]                  = { fg = "NONE", bg = "#A6A6A6" },
        ["TabLineSel"]               = { fg = "#050505", bg = "#FFFFFF" },

        ["DiagnosticUnderlineWarn"]  = { fg = "#ffff00" },
        ["DiagnosticUnderlineError"] = { fg = "#ff0000" },
    }

    for group, opts in pairs(common_hls) do
        vim.api.nvim_set_hl(0, group, opts)
    end
end

local function set_matchadd_c_cpp()
    vim.fn.matchadd("C_ASSERT", "\\<Assert\\>")
    -- vim.fn.matchadd("C_error", "\\< error \\>")
    vim.fn.matchadd("C_warning", "\\<warning\\>")
    vim.fn.matchadd("C_PUNC", "[,;]")

    local array_C = {
        "<", ">", "=", "!", "|", "&",
        "+", "-", "\\*", "/", "%",
        "\\.",
        -- "\\[", "\\]",
    }
    local c_matches = table.concat(array_C, "\\|")
    vim.fn.matchadd("C_OPERATORS", c_matches)

    vim.fn.matchadd("C_BRACKETS", "[\\{\\}]")
    vim.fn.matchadd("C_TR", "\\( ? \\)\\|\\( : \\)")
    vim.fn.matchadd("C_PAREN", "[\\(\\)]")
    vim.fn.matchadd("C_BRACKETS2", "[[\\[\\]]")

    local c_keywords = {
        "typedef",
        "struct",
        "union",
        "inline",
        "#define",
        "#include",
        "sizeof",
        "_Pragma",
        "#pragma",
    }
    local c_keywords_matches = table.concat(c_keywords, "\\|")
    vim.fn.matchadd("C_KEYWORDS", c_keywords_matches)

    local c_types = {
        "int8", "int16", "int32", "int64",
        "uint8", "uint16", "uint32", "uint64",
        "real32", "real64",
        "bool32",
        "local_presist",
        "internal",
        "global_variable",
        -- "DWORD",
        -- "UINT",
        -- "LARGE_INTEGER",
        -- "VOID",
        -- "LPVOID",
    }
    local c_types_matches = table.concat(c_types, "\\|")
    vim.fn.matchadd("C_TYPES", c_types_matches)

    local c_constants = {
        "true", "false"
    }
    local c_constants_matches = table.concat(c_constants, "\\|")
    vim.fn.matchadd("C_CONSTANTS", c_constants_matches)


    vim.fn.matchadd("C_COMMENT", "/\\*\\|\\*/")
    vim.fn.matchadd("C_COMMENT_LINE", [[[ ]*\/\/.*]])
end
local function set_highlight_groups_c_cpp()
    local custom_hls_c_cpp = {
        ["ctype"]          = { fg = "#666666" },
        ["cSpecial"]       = { fg = "#16c79a", bold = true },
        ["cString"]        = { fg = color_constant },
        ["cCharacter"]     = { fg = color_constant },
        ["cNumber"]        = { fg = color_constant },
        ["cConstant"]      = { fg = color_constant },
        ["cBoolean"]       = { fg = color_constant },
        ["cFloat"]         = { fg = color_constant },
        ["C_CONSTANTS"]    = { fg = color_constant },
        ["cDefine"]        = { fg = "#aaaaff" },
        ["cInclude"]       = { fg = "#aaaaff" },
        ["cConditional"]   = { fg = color_branch, bold = true },
        ["cRepeat"]        = { fg = color_branch, bold = true },
        ["cStatement"]     = { fg = color_branch, bold = true },

        ["cppBoolean"]     = { fg = color_constant },
        ["cppFloat"]       = { fg = color_constant },
        ["cppNumber"]      = { fg = color_constant },
        ["cCppOutIf2"]     = { fg = "#446644" },
        ["cCppOutIf"]      = { fg = "#446644" },
        ["cCppOutWrapper"] = { fg = color_branch, bold = true },



        ["cComment"]                           = { fg = color_comment },
        ["cCommentL"]                          = { fg = color_comment },
        ["C_PUNC"]                             = { fg = "#666688", bold = false },
        -- ["C_OPERATORS"] = { fg = "#119988" },
        ["C_BRACKETS"]                         = { fg = color_branch, bold = true },
        ["C_BRACKETS2"]                        = { fg = "#99FFFF", bold = false },
        ["C_TR"]                               = { fg = color_branch, bg = "#002222", bold = true },
        ["C_PAREN"]                            = { fg = color_paren, bold = false },
        -- ["C_KEYWORDS"]     = { fg = "#a060ff", bold = true },
        ["C_KEYWORDS"]                         = { fg = "#666666" },
        ["C_TYPES"]                            = { fg = "#666666" },
        ["C_ASSERT"]                           = { fg = "#FF10FF" },
        -- ["C_OPERATORS"]                      = { fg = "#A060FF", bold = true },
        -- ["@lsp.type.operator.c"]             = { fg = "#A060FF", bold = true },
        ["C_OPERATORS"]                        = { fg = "#10ffff", bold = false },
        ["@lsp.type.operator.c"]               = { fg = "#10ffff", bold = false },
        ["@lsp.typemod.macro.globalScope.c"]   = { fg = "#777777", bold = false },
        ["@lsp.typemod.macro.fileScope.c"]     = { fg = "#777777", bold = false },
        ["@lsp.typemod.macro.globalScope.cpp"] = { fg = "#777777", bold = false },
        ["@lsp.typemod.macro.fileScope.cpp"]   = { fg = "#777777", bold = false },
        -- ["cPreCondit"]                         = { fg = "#777777", bold = false },
        ["cPreCondit"]                         = { fg = color_branch, bold = false },
        ["@lsp.typemod.class.globalScope.c"]   = { fg = "#777777", bold = false },
        ["@lsp.typemod.class.fileScope.c"]     = { fg = "#777777", bold = false },
        ["@lsp.typemod.type.globalScope.c"]    = { fg = "#777777", bold = false },
        ["@lsp.typemod.type.fileScope.c"]      = { fg = "#777777", bold = false },
        ["C_COMMENT"]                          = { fg = color_comment },
        ["C_COMMENT_LINE"]                     = { fg = color_comment },
        -- ["C_COMMENT"]                        = { fg = "#FF00FF", bold = true },
        ["qfText"]                             = { fg = "#EEEEEE", bg = "#111111", bold = false },
        ["QuickFixLine"]                       = { fg = "#EEEEEE", bg = "#551155", bold = false },
        ["qfLineNr"]                           = { fg = "#111111", bg = "#555555", bold = false },
        ["qfError"]                            = { fg = "#FF0000", bg = "#111111", bold = true },
        ["C_warning"]                          = { fg = "#FFFF00", bg = "#111111", bold = true },
    }


    for group, opts in pairs(custom_hls_c_cpp) do
        vim.api.nvim_set_hl(0, group, opts)
    end
end

local function set_matchadd_c_cpp_2()
    local cond_C = {
        "return", "break", "continue", "case", "{", "}", ";",
        "#if", "#else", "#endif", "#elif",
        "#ifdef", "#ifndef", "#elifdef", "#elifndef"
    }
    local c_matches = table.concat(cond_C, "\\|")
    vim.fn.matchadd("C_COND", c_matches)

    vim.fn.matchadd("C_ASSERT", "\\<Assert\\>")
    vim.fn.matchadd("C_warning", "\\<warning\\>")
    -- vim.fn.matchadd("C_BRACKETS", "[\\{\\}]")
    vim.fn.matchadd("C_TR", "\\( ? \\)\\|\\( : \\)")
    vim.fn.matchadd("C_COMMENT_LINE", "//.*$")
    vim.fn.matchadd("C_SPERATOR", "^[ ]*//[ ]*[=]*$")

    set_matchadd_common()
end
local function set_highlight_groups_c_cpp_2()
    local custom_hls_c_cpp = {

        ["C_COMMENT_LINE"]           = { fg = "#707070" },
        ["C_SPERATOR"]               = { fg = "#101080" },
        ["LineNr"]                   = { fg = "#101080", bg = "#A6A6A6", bold = false, italic = false },
        ["CursorLineNr"]             = { bg = "#101080", bold = true, italic = false },
        ["CursorLine"]               = { bg = "#101035", bold = false },
        ["Cursor"]                   = { bg = "#2CFF05" },
        ["C_ASSERT"]                 = { fg = color_branch },
        ["C_warning"]                = { fg = "#FFFF00", bg = "#111111", bold = true },
        ["qfText"]                   = { fg = "#EEEEEE", bg = "#111111", bold = false },
        ["QuickFixLine"]             = { fg = "#EEEEEE", bg = "#551155", bold = false },
        ["qfLineNr"]                 = { fg = "#111111", bg = "#555555", bold = false },
        ["qfError"]                  = { fg = "#FF0000", bg = "#111111", bold = true },
        ["HighlighCursorWord"]       = { bg = "#101F3F" },
        ["DimEmptyLine"]             = { bg = "#101010" },
        ["EndOfBuffer"]              = { bg = "#111120" },
        ["TODOColor"]                = { fg = "#000000", bg = "#661111", bold = true, underline = true },
        ["NOTEColor"]                = { bg = "#000000", fg = "#119911", bold = true, underline = true },
        ["STUDYColor"]               = { bg = "#000000", fg = "#FFFF11", bold = true, underline = true },
        ["IMPORTANTColor"]           = { bg = "#000000", fg = "#FFFF11", bold = true, underline = true },
        ["FIXMEColor"]               = { fg = "#999900", bold = true },
        ["BUGColor"]                 = { fg = "#999900", bold = true },
        ["ExtraWhitespace"]          = { bg = "#113211", bold = true },

        ["cConditional"]             = { fg = color_branch },
        ["cRepeat"]                  = { fg = color_branch },
        ["C_COND"]                   = { fg = color_branch },

        ["OilDir"]                   = { fg = "#7aa2f7", bold = true },
        ["OilFile"]                  = { fg = "#c0caf5", bg = "NONE" },
        ["NormalFloat"]              = { fg = "NONE", bg = "NONE" },
        ["DiagnosticUnderlineWarn"]  = { fg = "NONE", bg = "#444410" },
        ["DiagnosticUnderlineError"] = { fg = "NONE", bg = "#441010" },
    }


    for group, opts in pairs(custom_hls_c_cpp) do
        vim.api.nvim_set_hl(0, group, opts)
    end
end

local function set_matchadd_js()
end
local function set_highlight_groups_js()
    local custom_hls_js = {
        ["javaScriptLineComment"] = { fg = color_comment },
        ["javaScriptComment"]     = { fg = color_comment },
        ["javaScriptStringS"]     = { fg = color_constant },
        ["javaScriptStringT"]     = { fg = color_constant },
        ["javaScriptStringD"]     = { fg = color_constant },
        ["javaScriptNumber"]      = { fg = color_constant },
        ["javaScriptBoolean"]     = { fg = color_constant },
        ["javaScriptFunction"]    = { fg = color_text },
        ["javaScriptReserved"]    = { fg = color_text },
        ["javaScriptOperator"]    = { fg = color_text },
        ["javaScriptIdentifier"]  = { fg = color_text },
        ["javaScriptConditional"] = { fg = color_branch, bold = true },
        ["javaScriptRepeat"]      = { fg = color_branch, bold = true },
        ["javaScriptStatement"]   = { fg = color_branch, bold = true },
        ["javaScriptParens"]      = { fg = color_delimiter, bold = true },
        ["javaScriptBraces"]      = { fg = color_delimiter, bold = true },
    }

    for group, opts in pairs(custom_hls_js) do
        vim.api.nvim_set_hl(0, group, opts)
    end
end

local function set_matchadd_cs()
    vim.fn.matchadd("REGION", [[^.*#region.*$]])
    vim.fn.matchadd("ENDREGION", [[^.*#endregion.*$]])
end
local function set_highlight_groups_cs()
    local custom_hls_cs = {
        ["@lsp.type.excludedCode.cs"] = { fg = "#116011", bold = true },
        ["csSpecialChar"]             = { fg = "#16c79a", bold = true },
        ["csBoolean"]                 = { fg = color_constant },
        ["csString"]                  = { fg = color_constant },
        ["csVerbatimString"]          = { fg = color_constant },
        ["csQuote"]                   = { fg = color_constant },
        ["csInteger"]                 = { fg = color_constant },
        ["csReal"]                    = { fg = color_constant },
        ["csNull"]                    = { fg = color_constant },
        ["csTypeOf"]                  = { fg = color_text },
        ["csUnspecifiedStatement"]    = { fg = "#666666", bold = true },
        -- ["csUnsupportedStatement"]       = { fg = "#666666", bold = true },
        ["csUnsupportedStatement"]    = { fg = color_constant, bold = true },
        ["csNew"]                     = { fg = "#666666", bold = true },
        ["csAccess"]                  = { fg = "#666666", bold = true },
        ["csAccessor"]                = { fg = "#666666", bold = true },
        ["csRepeat"]                  = { fg = color_branch, bold = true },
        ["csConditional"]             = { fg = color_branch, bold = true },
        ["csLabel"]                   = { fg = color_branch, bold = true },
        ["csLogicSymbols"]            = { fg = color_branch, bold = true },
        ["csIsAs"]                    = { fg = color_delimiter, bold = true },
        ["csParens"]                  = { fg = color_delimiter, bold = true },
        ["csBraces"]                  = { fg = color_delimiter, bold = true },
        ["csGenericBraces"]           = { fg = color_delimiter, bold = true },
        -- ["csOpSymbols"]                  = { fg = "#2FEF10", bold = true },
        ["csOpSymbols"]               = { fg = "#2F50Ef", bold = true },
        -- ["csLogicSymbols"]               = { fg = color_delimiter, bold = true },
        ["REGION"]                    = { fg = "#000000", bg = "#ffffff" },
        ["ENDREGION"]                 = { fg = "#000000", bg = "#ffffff" },
    }

    for group, opts in pairs(custom_hls_cs) do
        vim.api.nvim_set_hl(0, group, opts)
    end
end

local function setup_main()
    set_highlight_groups_common()
    set_highlight_groups_c_cpp()
    local match_augroup = vim.api.nvim_create_augroup('GlobalCustomMatches', { clear = true })
    vim.api.nvim_create_autocmd({ 'WinEnter', 'BufWinEnter', 'VimEnter', 'Syntax' }, {
        group = match_augroup,
        pattern = '*',
        callback = function(args)
            vim.fn.clearmatches()
            set_matchadd_c_cpp()
            set_matchadd_common()
        end,
    })

    vim.api.nvim_create_autocmd({ "BufEnter", "CursorMoved", "TextChanged", "TextChangedI" },
        {
            callback = function(args)
                highlight_empty_lines(args.buf)
            end
        }
    )
end
local function setup_temp()
    set_highlight_groups_c_cpp_2()
    local match_augroup = vim.api.nvim_create_augroup('GlobalCustomMatches', { clear = true })
    vim.api.nvim_create_autocmd({ 'WinEnter', 'BufWinEnter', 'VimEnter', 'Syntax' }, {
        group = match_augroup,
        pattern = '*',
        callback = function(args)
            vim.fn.clearmatches()
            set_matchadd_c_cpp_2()
        end,
    })

    vim.api.nvim_create_autocmd({ "BufEnter", "CursorMoved", "TextChanged", "TextChangedI" },
        {
            callback = function(args)
                highlight_empty_lines(args.buf)
            end
        }
    )
end
function M.setup()
    setup_temp()
end

return M
