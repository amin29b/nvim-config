local M = {}

function M.setup()
    vim.cmd([[
      command! -bang -nargs=* Rg
        \ call fzf#vim#grep(
        \       "rg  --with-filename  --column --line-number --no-heading --color=always --smart-case -- ".shellescape(<q-args>),
        \       1,
        \       fzf#vim#with_preview({'options': '--delimiter : --nth 3..'},'up', 'ctrl-/'),
        \       !0)
        ]])

    vim.cmd([[
                " CTRL-A CTRL-Q to select all and build quickfix list

                let g:fzf_action = {
                  \ 'ctrl-q': 'fill_qucikfix',
                  \ 'ctrl-t': 'tab split',
                  \ 'ctrl-x': 'split',
                  \ 'ctrl-v': 'vsplit' }

                let $FZF_DEFAULT_OPTS = '--bind ctrl-a:select-all'
          ]])
end

return M
