if !executable('xxd')
    finish
endif

let b:undo_ftplugin = (exists('b:undo_ftplugin') ? b:undo_ftplugin . ' | ' : '')
\   . 'setl bin< eol< | execute "au! ftplugin-xxd * <buffer>" | execute "silent %!xxd -r"'

setlocal binary noendofline
silent %!xxd -g 1
%s/\r$//e
augroup ftplugin-xxd
    autocmd! * <buffer>
    autocmd BufWritePre <buffer> let b:xxd_cursor = getpos('.')
    autocmd BufWritePre <buffer> silent %!xxd -r
    autocmd BufWritePost <buffer> silent %!xxd -g 1
    autocmd BufWritePost <buffer> %s/\r$//
    autocmd BufWritePost <buffer> setlocal nomodified
    autocmd BufWritePost <buffer> call setpos('.', b:xxd_cursor) | unlet b:xxd_cursor
augroup END
