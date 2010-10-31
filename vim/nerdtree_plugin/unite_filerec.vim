if exists("g:loaded_nerdtree_unite_filerec")
    finish
endif
let g:loaded_nerdtree_unite_filerec = 1

if !exists(':Unite')
    echoerr 'This plugin requires unite.vim'
    finish
endif

function! s:callback_name()
    return matchstr(expand('<sfile>'), '<SNR>\d\+_') . 'callback'
endfunction

function! s:callback()
    let currentDir = g:NERDTreeFileNode.GetSelected().path.getDir().str({'format': 'Cd'})
    execute 'Unite' '-input=' . currentDir . '/' 'file_rec'
endfunction

call NERDTreeAddMenuItem({
            \ 'text': '(u)nite file_rec',
            \ 'shortcut': 'u',
            \ 'callback': s:callback_name()})

call NERDTreeAddKeyMap({
            \ 'key': 'cu',
            \ 'callback': s:callback_name(),
            \ 'quickhelpText': 'start unite file_rec with selected file or directory'})
