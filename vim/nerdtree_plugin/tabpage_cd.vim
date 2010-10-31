if exists("g:loaded_nerdtree_tabpage_cd")
    finish
endif
let g:loaded_nerdtree_tabpage_cd = 1

if !exists(':TabpageCD')
    echoerr 'This plugin requires TabpageCD command'
    finish
endif

function! s:callback_name()
    return matchstr(expand('<sfile>'), '<SNR>\d\+_') . 'callback'
endfunction

function! s:callback()
    let currentDir = g:NERDTreeFileNode.GetSelected().path.getDir().str({'format': 'Cd'})
    execute 'TabpageCD' currentDir
endfunction

call NERDTreeAddMenuItem({
            \ 'text': '(t)abpage cd',
            \ 'shortcut': 't',
            \ 'callback': s:callback_name()})

call NERDTreeAddKeyMap({
            \ 'key': 'ct',
            \ 'callback': s:callback_name(),
            \ 'quickhelpText': 'tabpage cd to selected file or directory'})

