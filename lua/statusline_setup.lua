local function lsp_status()
    local attached_clients = vim.lsp.get_clients({ bufnr = 0 })
    if #attached_clients == 0 then
        return ""
    end
    local names = vim.iter(attached_clients)
        :map(function(client)
            local name = client.name:gsub("language.server", "ls")
            return name
        end)
        :totable()
    return "[" .. table.concat(names, ", ") .. "]"
end

local function mode_status()
    local mode = vim.fn.mode()

    if mode == 'n' then
        return " NORMAL      "
    elseif mode == 'i' then
        return " INSERT      "
    elseif mode == 'V' then
        return " VISUAL-LINE "
    elseif mode == 'v' then
        return " VISUAL"
    elseif mode == '' then
        return " VISUAL-BLOCK"
    elseif mode == 'c' then
        return " COMMAND     "
    else
        return 'Mode: ' .. mode
    end

    return ""
end

function _G.statusline()
    return table.concat({
        mode_status(),
        "%f",
        "%h%w%m%r",
        "%=",
        lsp_status(),
        " %-14(%l,%c%V%)",
        "Buf:%03n",
        "%P",
    }, " ")
end

vim.o.statusline = "%{%v:lua._G.statusline()%}"
