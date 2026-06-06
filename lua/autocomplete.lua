-- vim.api.nvim_create_autocmd("InsertCharPre", {
--     callback = function()
--         if vim.fn.pumvisible() == 1 or vim.fn.state('m') == 'm' then
--             return
--         end
--         local clients = vim.lsp.get_clients({ bufnr = 0 })
--
--
--         if next(clients) ~= nil then
--             vim.lsp.completion.get()
--         else
--             local key = vim.keycode('<C-x><C-n>')
--             vim.api.nvim_feedkeys(key, 'm', false)
--         end
--     end
-- })



-- vim.api.nvim_create_autocmd('LspAttach', {
--     callback = function(args)
--         vim.lsp.completion.enable(true, args.data.client_id, args.buf, {
--             autotrigger = true,
--             convert = function(item)
--                 return { abbr = item.label }
--             end,
--         })
--     end,
-- })





vim.o.autocomplete = true

vim.api.nvim_create_autocmd('LspAttach', {
    callback = function(ev)
        local client = assert(vim.lsp.get_client_by_id(ev.data.client_id))
        if client:supports_method("textDocument/completion") then
            vim.lsp.completion.enable(true, client.id, ev.buf, { autotrigger = true })
        end
    end,
})

vim.opt.complete:append('o')
vim.o.pumheight = 6
-- vim.o.pumborder = 'solid'
vim.o.pumborder = 'shadow'



-- 							*'winborder'*
-- 'winborder'		string	(default "")
-- 			global
-- 	Defines the default border style of floating windows. The default value
-- 	is empty, which is equivalent to "none". Valid values include:
-- 	- "bold": Bold line box.
-- 	- "double": Double-line box.
-- 	- "none": No border.
-- 	- "rounded": Like "single", but with rounded corners ("╭" etc.).
-- 	- "shadow": Drop shadow effect, by blending with the background.
-- 	- "single": Single-line box.
-- 	- "solid": Adds padding by a single whitespace cell.
-- 	- custom: comma-separated list of exactly 8 characters in clockwise
-- 	  order starting from topleft. Example: >lua
-- 	     vim.o.winborder='+,-,+,|,+,-,+,|'


