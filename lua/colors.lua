local M = {}

function M.setup()
    vim.fn.matchadd("ExtraWhitespace", "\\s\\+$")
    vim.fn.matchadd("TODOColor", "\\<TODO\\>")
    vim.fn.matchadd("NOTEColor", "^.*\\<NOTE\\>.*:.*$")
    vim.fn.matchadd("FIXMEColor", "\\<FIXME\\>")
    vim.fn.matchadd("BUGColor", "\\<BUG\\>")
    vim.fn.matchadd("REGION", [[^.*#region.*$]])
    vim.fn.matchadd("ENDREGION", [[^.*#endregion.*$]])


    local color_text = "#FFFFFF"
    -- local color_constant="#885522"
    -- local color_constant="#805020"
    local color_constant = "#E6B88A"
    local color_branch = "#4B70F5"
    local color_delimiter = "#7777cc"

    local custom_hls = {
        ["@comment"]                     = { fg = "#335533", italic = true, bold = false },
        ["Comment"]                      = { fg = "#335533", italic = true, bold = false },
        ["javaScriptLineComment"]        = { fg = "#335533", italic = true, bold = false },
        ["javaScriptComment"]            = { fg = "#335533", italic = true, bold = false },

        ["@string.escape"]               = { fg = "#16c79a", bold = true },

        ["@character"]                   = { fg = color_constant, bold = false },
        ["@string"]                      = { fg = color_constant, bold = false },
        ["@number"]                      = { fg = color_constant, bold = false },
        ["@boolean"]                     = { fg = color_constant, bold = false },
        ["@constant.builtin"]            = { fg = color_constant, bold = false },
        ["javaScriptStringS"]            = { fg = color_constant, bold = false },
        ["javaScriptStringT"]            = { fg = color_constant, bold = false },
        ["javaScriptStringD"]            = { fg = color_constant, bold = false },
        ["javaScriptNumber"]            = { fg = color_constant, bold = false },
        ["javaScriptBoolean"]            = { fg = color_constant, bold = false },
        ["csBoolean"]                    = { fg = color_constant, bold = false },

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
        ["javaScriptFunction"]           = { fg = color_text },
        ["javaScriptReserved"]           = { fg = color_text },
        ["javaScriptOperator"]           = { fg = color_text },
        ["javaScriptIdentifier"]         = { fg = color_text },

        ["@keyword"]                     = { fg = "#777777", bold = true },
        ["Type"]                         = { fg = "#666666", bold = true },

        ["@keyword.repeat"]              = { fg = color_branch, bold = true },
        ["@keyword.conditional"]         = { fg = color_branch, bold = true },
        ["@keyword.conditional.ternary"] = { fg = color_branch, bold = true },
        ["@keyword.directive"]           = { fg = color_branch, bold = true },
        ["@keyword.return"]              = { fg = color_branch, bold = true },
        ["javaScriptConditional"]        = { fg = color_branch, bold = true },
        ["javaScriptRepeat"]             = { fg = color_branch, bold = true },
        ["javaScriptStatement"]          = { fg = color_branch, bold = true },
        ["Statement"]                    = { fg = color_branch, bold = true },

        ["@operator"]                    = { fg = color_delimiter, bold = true },
        ["@lsp.type.operator"]           = { fg = color_delimiter, bold = true },
        ["@punctuation.delimiter"]       = { fg = color_delimiter, bold = true },
        ["@punctuation.bracket"]         = { fg = color_delimiter, bold = true },
        ["@constructor"]                 = { fg = color_delimiter, bold = true },
        ["javaScriptParens"]             = { fg = color_delimiter, bold = true },
        ["javaScriptBraces"]             = { fg = color_delimiter, bold = true },
        ["@lsp.type.punctuation"]        = { fg = color_delimiter, bold = true },

        ["Folded"]                       = { fg = "#11A6FF", bg = "#000044", bold = true },
        ["LineNr"]                       = { fg = "#000000", bg = "#A6A6A6", bold = false, italic = false },
        ["CursorLineNr"]                 = { bg = "#0000FF", bold = false, italic = true },
        ["SignColumn"]                   = { bg = "#2e3440", bold = false, italic = true },
        ["EndOfBuffer"]                  = { bg = "#2e3440", bold = false, italic = true },

        ["TODOColor"]                    = { fg = "#660000", bold = true },
        ["NOTEColor"]                    = { fg = "#007700", bold = true },
        ["FIXMEColor"]                   = { fg = "#999900", bold = true },
        ["BUGColor"]                     = { fg = "#999900", bold = true },
        ["ExtraWhitespace"]              = { bg = "#320000", bold = true },

        ["Cursor"]                       = { reverse = true, bg = "#66FF66" },

        ["REGION"]                       = { fg = "#000020", bg = "#999999" },
        ["ENDREGION"]                    = { fg = "#000020", bg = "#999999" },

        ["OilDir"]                       = { fg = "#7aa2f7", bold = true },
        ["OilFile"]                      = { fg = "#c0caf5", bg = "NONE" },
        -- ["OilFloat"]                     = { fg = "#FF0000", bg = "#FF00FF" },
        ["NormalFloat"]                  = { fg = "NONE", bg = "NONE" },

        ["TabLineFill"]                  = { fg = "NONE", bg = "#A6A6A6" },
        ["TabLine"]                      = { fg = "NONE", bg = "#A6A6A6" },
        ["TabLineSel"]                   = { fg = "#000000", bg = "#FFFFFF" },
    }


    for group, opts in pairs(custom_hls) do
        vim.api.nvim_set_hl(0, group, opts)
    end
end

return M
