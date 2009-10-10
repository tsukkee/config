if exists("g:loaded_nerdtree_tabpage_cd")
    finish
endif
let g:loaded_nerdtree_tabpage_cd = 1

if exists(':TabpageCD') != 2
    echoerr 'This plugins need TabpageCD command'
    finish
endif

call NERDTreeAddMenuItem({
            \ 'text': '(t)abpage cd',
            \ 'shortcut': 't',
            \ 'callback': 'NERDTreeTabpageCd'})

call NERDTreeAddKeyMap({
            \ 'key': 'ct',
            \ 'callback': 'NERDTreeTabpageCd',
            \ 'quickhelpText': 'tabpage cd to selected file or directory'})

function! NERDTreeTabpageCd()
    let currentDir = g:NERDTreeFileNode.GetSelected().path.getDir().str({'format': 'Cd'})
    echo 'TabpageCD to ' . currentDir
    execute 'TabpageCD' currentDir
endfunction
