return {
    setup = function()
        -- start [ - toggle terminal - ]
        local terminal = nil
        local function toggle_term()
            if terminal and not vim.api.nvim_win_is_valid(terminal) then
                terminal = nil
                return
            end


            if terminal then
                vim.api.nvim_win_hide(terminal)
                terminal = nil
                return
            end

            vim.cmd("below split | terminal")

            terminal = vim.api.nvim_get_current_win()
        end

        vim.keymap.set("n", "<leader>t", toggle_term, {});
        vim.keymap.set("t", "<leader>t", toggle_term, {});
        -- end [ - toggle terminal - ]
    end,
}
