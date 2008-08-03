" flyquickfixmake
augroup plugin-flyquickfixmake
    autocmd!
    autocmd FileType ruby       call s:Setup("ruby")
    autocmd FileType php        call s:Setup("php")
    autocmd FileType javascript call s:Setup("javascript")
    autocmd FileType html       call s:Setup("tidy")
augroup END

function! s:Setup(compiler)
    if exists("g:current_compiler")
        unlet g:current_compiler
    endif
    execute "compiler " . a:compiler
    autocmd BufWritePost * silent call s:Flymake()
endfunction

let s:enabled = 0
function! s:Flymake()
    if s:enabled
        silent make %
    endif
endfunction

command! FlyQuickFixMakeEnable  let s:enabled = 1
command! FlyQuickFixMakeDisable let s:enabled = 0
