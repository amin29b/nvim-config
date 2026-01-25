local M = {}

function M.setup()
    vim.fn.matchadd("ExtraWhitespace", "\\s\\+$")
    vim.fn.matchadd("TODOColor", "\\<TODO\\>")
    vim.fn.matchadd("NOTEColor", "^.*\\<NOTE\\>.*:.*$")
    vim.fn.matchadd("FIXMEColor", "\\<FIXME\\>")
    vim.fn.matchadd("BUGColor", "\\<BUG\\>")
    vim.fn.matchadd("REGION", [[^.*#region.*$]])
    vim.fn.matchadd("ENDREGION", [[^.*#endregion.*$]])
    vim.fn.matchadd("PUNC", "[,.:;]")


    local color_text = "#FCFCFC"
    -- local color_constant="#885522"
    -- local color_constant="#805020"
    -- local color_constant = "#E6B88A"
    local color_constant = "#CC8200"
    -- local color_branch = "#4B70F5"
    -- local color_branch = "#4B70F5"
    -- local color_branch = "#4444FF"
    local color_branch = "#6030FF"
    local color_delimiter = "#7777cc"
    -- local color_comment = "#119911"
    -- local color_comment = "#45CC2D"
    local color_comment = "#04702b"

    local custom_hls = {
        ["PUNC"]                         = { fg = "#666688", bold = true },
        ["Normal"]                       = { fg = color_text, bg = "#001500", italic = false, bold = false },
        ["@comment"]                     = { fg = color_comment },
        ["Comment"]                      = { fg = color_comment },
        ["javaScriptLineComment"]        = { fg = color_comment },
        ["javaScriptComment"]            = { fg = color_comment },

        ["@string.escape"]               = { fg = "#16c79a", bold = true },

        ["@character"]                   = { fg = color_constant },
        ["@string"]                      = { fg = color_constant },
        ["@number"]                      = { fg = color_constant },
        ["@boolean"]                     = { fg = color_constant },
        ["@constant.builtin"]            = { fg = color_constant },
        ["javaScriptStringS"]            = { fg = color_constant },
        ["javaScriptStringT"]            = { fg = color_constant },
        ["javaScriptStringD"]            = { fg = color_constant },
        ["javaScriptNumber"]             = { fg = color_constant },
        ["javaScriptBoolean"]            = { fg = color_constant },


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


        ["@lsp.type.excludedCode.cs"] = { fg = "#006000", bold = true },
        -- ["PreProc"]                   = { fg = "#006000", bold = true },
        ["PreProc"]                   = { fg = "#505020", bg = "#999999" },
        ["REGION"]                    = { fg = "#505020", bg = "#999999" },
        ["ENDREGION"]                 = { fg = "#050520", bg = "#999999" },

        ["Folded"]                    = { fg = "#11A6FF", bg = "#111144", bold = true },
        -- ["LineNr"]                    = { fg = "#000000", bg = "#A6A6A6", bold = false, italic = false },
        ["LineNr"]                    = { fg = "#101080", bg = "#A6A6A6", bold = false, italic = false },
        ["Cursor"]                    = { bg = "#2CFF05" },
        ["CursorLineNr"]              = { bg = "#101080", bold = true, italic = false },
        ["CursorLine"]                = { bg = "#101080", bold = true },
        ["SignColumn"]                = { bg = "#2e3440", bold = false, italic = true },
        ["EndOfBuffer"]               = { bg = "#111120", bold = false, italic = true },

        ["TODOColor"]                 = { fg = "#661111", bold = true },
        ["NOTEColor"]                 = { fg = "#11FF11", bold = true },
        ["FIXMEColor"]                = { fg = "#999900", bold = true },
        ["BUGColor"]                  = { fg = "#999900", bold = true },
        ["ExtraWhitespace"]           = { bg = "#321111", bold = true },

        ["OilDir"]                   = { fg = "#7aa2f7", bold = true },
        ["OilFile"]                  = { fg = "#c0caf5", bg = "NONE" },
        ["NormalFloat"]              = { fg = "NONE", bg = "NONE" },

        ["TabLineFill"]              = { fg = "NONE", bg = "#A6A6A6" },
        ["TabLine"]                  = { fg = "NONE", bg = "#A6A6A6" },
        ["TabLineSel"]               = { fg = "#050505", bg = "#FFFFFF" },

        ["DiagnosticUnderlineWarn"]  = { fg = "#ffff00" },
        ["DiagnosticUnderlineError"] = { fg = "#ff0000" },

        ["csSpecialChar"]                = { fg = "#16c79a", bold = true },
        ["csBoolean"]                    = { fg = color_constant },
        ["csString"]                     = { fg = color_constant },
        ["csVerbatimString"]             = { fg = color_constant },
        ["csQuote"]                      = { fg = color_constant },
        ["csInteger"]                    = { fg = color_constant },
        ["csReal"]                       = { fg = color_constant },
        ["csNull"]                       = { fg = color_constant },
        ["csTypeOf"]                     = { fg = color_text },
        ["csUnspecifiedStatement"]       = { fg = "#666666", bold = true },
        -- ["csUnsupportedStatement"]       = { fg = "#666666", bold = true },
        ["csUnsupportedStatement"]       = { fg = color_constant, bold = true },
        ["csNew"]                        = { fg = "#666666", bold = true },
        ["csAccess"]                     = { fg = "#666666", bold = true },
        ["csAccessor"]                   = { fg = "#666666", bold = true },
        ["csRepeat"]                     = { fg = color_branch, bold = true },
        ["csConditional"]                = { fg = color_branch, bold = true },
        ["csLabel"]                      = { fg = color_branch, bold = true },
        ["csLogicSymbols"]               = { fg = color_branch, bold = true },
        ["csIsAs"]                       = { fg = color_delimiter, bold = true },
        ["csParens"]                     = { fg = color_delimiter, bold = true },
        ["csBraces"]                     = { fg = color_delimiter, bold = true },
        ["csGenericBraces"]              = { fg = color_delimiter, bold = true },
        -- ["csOpSymbols"]                  = { fg = "#2FEF10", bold = true },
        ["csOpSymbols"]                  = { fg = "#2F50Ef", bold = true },
        -- ["csLogicSymbols"]               = { fg = color_delimiter, bold = true },
    }

    for group, opts in pairs(custom_hls) do
        vim.api.nvim_set_hl(0, group, opts)
    end
end

return M
