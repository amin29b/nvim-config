local function get_commentstring(ref_position)
    local buf_cs = vim.bo.commentstring

    local ts_parser = vim.treesitter.get_parser(0, '', { error = false })
    if not ts_parser then
        return buf_cs
    end

    -- Try to get 'commentstring' associated with local tree-sitter language.
    -- This is useful for injected languages (like markdown with code blocks).
    local row, col = ref_position[1] - 1, ref_position[2]
    local ref_range = { row, col, row, col + 1 }

    -- Get 'commentstring' from tree-sitter captures' metadata.
    -- Traverse backwards to prefer narrower captures.
    local caps = vim.treesitter.get_captures_at_pos(0, row, col)
    for i = #caps, 1, -1 do
        local id, metadata = caps[i].id, caps[i].metadata
        local md_cms = metadata['bo.commentstring'] or metadata[id] and metadata[id]['bo.commentstring']

        if md_cms then
            return md_cms
        end
    end

    -- - Get 'commentstring' from the deepest LanguageTree which both contains
    --   reference range and has valid 'commentstring' (meaning it has at least
    --   one associated 'filetype' with valid 'commentstring').
    --   In simple cases using `parser:language_for_range()` would be enough, but
    --   it fails for languages without valid 'commentstring' (like 'comment').
    local ts_cs, res_level = nil, 0

    ---@param lang_tree vim.treesitter.LanguageTree
    local function traverse(lang_tree, level)
        if not lang_tree:contains(ref_range) then
            return
        end

        local lang = lang_tree:lang()
        local filetypes = vim.treesitter.language.get_filetypes(lang)
        for _, ft in ipairs(filetypes) do
            local cur_cs = vim.filetype.get_option(ft, 'commentstring')
            if cur_cs ~= '' and level > res_level then
                ts_cs = cur_cs
            end
        end

        for _, child_lang_tree in pairs(lang_tree:children()) do
            traverse(child_lang_tree, level + 1)
        end
    end
    traverse(ts_parser, 1)

    return ts_cs or buf_cs
end

local function get_comment_parts(ref_position)
    local cs = get_commentstring(ref_position)

    if cs == nil or cs == '' then
        vim.api.nvim_echo({ { "Option 'commentstring' is empty.", 'WarningMsg' } }, true, {})
        return { left = '', right = '' }
    end

    if not (type(cs) == 'string' and cs:find('%%s') ~= nil) then
        error(vim.inspect(cs) .. " is not a valid 'commentstring'.")
    end

    -- Structure of 'commentstring': <left part> <%s> <right part>
    local left, right = cs:match('^(.-)%%s(.-)$')
    assert(left and right)
    return { left = left, right = right }
end

local function make_comment_check(parts)
    local l_esc, r_esc = vim.pesc(parts.left), vim.pesc(parts.right)

    -- Commented line has the following structure:
    -- <whitespace> <trimmed left> <anything> <trimmed right> <whitespace>
    local regex = '^%s-' .. vim.trim(l_esc) .. '.*' .. vim.trim(r_esc) .. '%s-$'

    return function(line)
        return line:find(regex) ~= nil
    end
end

local function get_lines_info(lines, parts)
    local comment_check = make_comment_check(parts)

    local is_commented = true
    local indent_width = math.huge
    ---@type string
    local indent

    for _, l in ipairs(lines) do
        -- Update lines indent: minimum of all indents except blank lines
        local _, indent_width_cur, indent_cur = l:find('^(%s*)')
        assert(indent_width_cur and indent_cur)

        -- Ignore blank lines completely when making a decision
        if indent_width_cur < l:len() then
            -- NOTE: Copying actual indent instead of recreating it with `indent_width`
            -- allows to handle both tabs and spaces
            if indent_width_cur < indent_width then
                ---@diagnostic disable-next-line:cast-local-type
                indent_width, indent = indent_width_cur, indent_cur
            end

            -- Update comment info: commented if every non-blank line is commented
            if is_commented then
                is_commented = comment_check(l)
            end
        end
    end

    -- `indent` can still be `nil` in case all `lines` are empty
    return indent or '', is_commented
end

local function is_blank(x)
    return x:find('^%s*$') ~= nil
end

local function make_comment_function(parts, indent)
    local prefix, nonindent_start, suffix = indent .. parts.left, indent:len() + 1, parts.right
    local blank_comment = indent .. vim.trim(parts.left) .. vim.trim(suffix)

    return function(line)
        if is_blank(line) then
            return blank_comment
        end
        return prefix .. line:sub(nonindent_start) .. suffix
    end
end

local function make_uncomment_function(parts)
    local l_esc, r_esc = vim.pesc(parts.left), vim.pesc(parts.right)
    local regex = '^(%s*)' .. l_esc .. '(.*)' .. r_esc .. '(%s-)$'
    local regex_trimmed = '^(%s*)' .. vim.trim(l_esc) .. '(.*)' .. vim.trim(r_esc) .. '(%s-)$'

    return function(line)
        -- Try regex with exact comment parts first, fall back to trimmed parts
        local indent, new_line, trail = line:match(regex)
        if new_line == nil then
            indent, new_line, trail = line:match(regex_trimmed)
        end

        -- Return original if line is not commented
        if new_line == nil then
            return line
        end

        -- Prevent trailing whitespace
        if is_blank(new_line) then
            indent, trail = '', ''
        end

        return indent .. new_line .. trail
    end
end

local function toggle_lines(line_start, line_end, ref_position)
    ref_position = ref_position or { line_start, 0 }
    local parts = get_comment_parts(ref_position)
    local lines = vim.api.nvim_buf_get_lines(0, line_start - 1, line_end, false)
    local indent, is_comment = get_lines_info(lines, parts)
    local f = is_comment and make_uncomment_function(parts) or make_comment_function(parts, indent)
    vim._with({ lockmarks = true }, function()
        vim.api.nvim_buf_set_lines(0, line_start - 1, line_end, false, vim.tbl_map(f, lines))
    end)
end

local function comment_lines(line_start, line_end, ref_position)
    ref_position = ref_position or { line_start, 0 }
    local parts = get_comment_parts(ref_position)
    local lines = vim.api.nvim_buf_get_lines(0, line_start - 1, line_end, false)
    local indent, is_comment = get_lines_info(lines, parts)
    is_comment = false
    make_comment_function(parts, indent)
    local f = is_comment and make_uncomment_function(parts) or make_comment_function(parts, indent)
    vim._with({ lockmarks = true }, function()
        vim.api.nvim_buf_set_lines(0, line_start - 1, line_end, false, vim.tbl_map(f, lines))
    end)
end

local function uncomment_lines(line_start, line_end, ref_position)
    ref_position = ref_position or { line_start, 0 }
    local parts = get_comment_parts(ref_position)
    local lines = vim.api.nvim_buf_get_lines(0, line_start - 1, line_end, false)
    local indent, is_comment = get_lines_info(lines, parts)
    is_comment = true
    make_uncomment_function(parts, indent)
    local f = is_comment and make_uncomment_function(parts) or make_comment_function(parts, indent)
    vim._with({ lockmarks = true }, function()
        vim.api.nvim_buf_set_lines(0, line_start - 1, line_end, false, vim.tbl_map(f, lines))
    end)
end

local function operator(mode)
    -- Used without arguments as part of expression mapping. Otherwise it is
    -- called as 'operatorfunc'.
    if mode == nil then
        vim.o.operatorfunc = "v:lua.require'vim._comment'.operator"
        return 'g@'
    end

    -- Compute target range
    local mark_from, mark_to = "'[", "']"
    local lnum_from, col_from = vim.fn.line(mark_from), vim.fn.col(mark_from)
    local lnum_to, col_to = vim.fn.line(mark_to), vim.fn.col(mark_to)

    -- Do nothing if "from" mark is after "to" (like in empty textobject)
    if (lnum_from > lnum_to) or (lnum_from == lnum_to and col_from > col_to) then
        return
    end

    -- NOTE: use cursor position as reference for possibly computing local
    -- tree-sitter-based 'commentstring'. Recompute every time for a proper
    -- dot-repeat. In Visual and sometimes Normal mode it uses start position.
    toggle_lines(lnum_from, lnum_to, vim.api.nvim_win_get_cursor(0))
    return ''
end

local function operator_comment_gv(mode)
    if mode == nil then
        vim.o.operatorfunc = "v:lua.require'comment'.operator_comment_gv"
        return 'g@'
    end

    local mark_from, mark_to = "'[", "']"
    local lnum_from, col_from = vim.fn.line(mark_from), vim.fn.col(mark_from)
    local lnum_to, col_to = vim.fn.line(mark_to), vim.fn.col(mark_to)

    if (lnum_from > lnum_to) or (lnum_from == lnum_to and col_from > col_to) then
        return
    end

    comment_lines(lnum_from, lnum_to, vim.api.nvim_win_get_cursor(0))
    vim.cmd.normal('gv')
    return ''
end

local function operator_comment(mode)
    if mode == nil then
        vim.o.operatorfunc = "v:lua.require'comment'.operator_comment"
        return 'g@'
    end

    local mark_from, mark_to = "'[", "']"
    local lnum_from, col_from = vim.fn.line(mark_from), vim.fn.col(mark_from)
    local lnum_to, col_to = vim.fn.line(mark_to), vim.fn.col(mark_to)

    if (lnum_from > lnum_to) or (lnum_from == lnum_to and col_from > col_to) then
        return
    end

    comment_lines(lnum_from, lnum_to, vim.api.nvim_win_get_cursor(0))
    return ''
end

local function operator_uncomment_gv(mode)
    if mode == nil then
        vim.o.operatorfunc = "v:lua.require'comment'.operator_uncomment_gv"
        return 'g@'
    end

    local mark_from, mark_to = "'[", "']"
    local lnum_from, col_from = vim.fn.line(mark_from), vim.fn.col(mark_from)
    local lnum_to, col_to = vim.fn.line(mark_to), vim.fn.col(mark_to)

    if (lnum_from > lnum_to) or (lnum_from == lnum_to and col_from > col_to) then
        return
    end

    uncomment_lines(lnum_from, lnum_to, vim.api.nvim_win_get_cursor(0))
    vim.cmd.normal('gv')
    return ''
end

local function operator_uncomment(mode)
    if mode == nil then
        vim.o.operatorfunc = "v:lua.require'comment'.operator_uncomment"
        return 'g@'
    end

    local mark_from, mark_to = "'[", "']"
    local lnum_from, col_from = vim.fn.line(mark_from), vim.fn.col(mark_from)
    local lnum_to, col_to = vim.fn.line(mark_to), vim.fn.col(mark_to)

    if (lnum_from > lnum_to) or (lnum_from == lnum_to and col_from > col_to) then
        return
    end

    uncomment_lines(lnum_from, lnum_to, vim.api.nvim_win_get_cursor(0))
    return ''
end

--- Select contiguous commented lines at cursor
local function textobject()
    local lnum_cur = vim.fn.line('.')
    local parts = get_comment_parts({ lnum_cur, vim.fn.col('.') })
    local comment_check = make_comment_check(parts)

    if not comment_check(vim.fn.getline(lnum_cur)) then
        return
    end

    -- Compute commented range
    local lnum_from = lnum_cur
    while (lnum_from >= 2) and comment_check(vim.fn.getline(lnum_from - 1)) do
        lnum_from = lnum_from - 1
    end

    local lnum_to = lnum_cur
    local n_lines = vim.api.nvim_buf_line_count(0)
    while (lnum_to <= n_lines - 1) and comment_check(vim.fn.getline(lnum_to + 1)) do
        lnum_to = lnum_to + 1
    end

    -- Select range linewise for operator to act upon
    vim.cmd('normal! ' .. lnum_from .. 'GV' .. lnum_to .. 'G')
end

local comment = function()
    return operator_comment() .. '_'
end
local comment_gv = function()
    return operator_comment_gv() .. '_'
end
local uncomment = function()
    return operator_uncomment() .. '_'
end
local uncomment_gv = function()
    return operator_uncomment_gv() .. '_'
end

return {
    comment = comment,
    comment_gv = comment_gv,
    uncomment = uncomment,
    uncomment_gv = uncomment_gv,
    operator_comment = operator_comment,
    operator_comment_gv = operator_comment_gv,
    operator_uncomment = operator_uncomment,
    operator_uncomment_gv = operator_uncomment_gv,
--    operator = operator,
--    textobject = textobject,
--    toggle_lines = toggle_lines
}
