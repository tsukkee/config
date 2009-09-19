" vimrcbox.vim
" Author: Sora harakami <sora134@gmail.com>
" Require: curl
" Licence: MIT Licence

if !exists('g:vimrcbox_user')
    let g:vimrcbox_user = ''
endif

if !exists('g:vimrcbox_pass')
    let g:vimrcbox_pass = ''
endif

if !exists('g:vimrcbox_vimrc')
    let g:vimrcbox_vimrc = ''
endif

if !exists('g:vimrcbox_gvimrc')
    let g:vimrcbox_gvimrc = ''
endif

"change baseurl if debug
"let g:vimrcbox_baseurl = 'http://127.0.0.1/vimrcb/'
let g:vimrcbox_baseurl = 'http://soralabo.net/s/vrcb/'
function! s:VrbUpdateVimrc(...)
    let user = g:vimrcbox_user
    let pass = g:vimrcbox_pass
    if exists('a:1')
        let postfile = a:1
    elseif len(g:vimrcbox_vimrc) > 0
        let postfile = g:vimrcbox_vimrc
    else
        let postfile = $MYVIMRC
    endif
    if user == ''
        let user = input("Username: ")
        if !len(user)
            echo "Cancel"
            return []
        endif
    endif
    if pass == ''
        let pass = inputsecret("Password: ")
        if !len(pass)
            echo "Cancel"
            return []
        endif
    endif
    "post
    let result = system("curl -s -F vimrc=@".postfile." -F user=".user." -F pass=".pass." -F gvim=0 ".g:vimrcbox_baseurl."api/register")
    if result =~ '1'
        echo "Update success"
    else
        echo "Update failure" 
    end
endfunction

function! s:VrbUpdateGvimrc(...)
    let user = g:vimrcbox_user
    let pass = g:vimrcbox_pass
    if exists('a:1')
        let postfile = a:1
    elseif len(g:vimrcbox_gvimrc) > 0
        let postfile = g:vimrcbox_gvimrc
    else
        let postfile = $MYGVIMRC
    endif
    if user == ''
        let user = input("Username: ")
        if !len(user)
            echo "Cancel"
            return []
        endif
    endif
    if pass == ''
        let pass = inputsecret("Password: ")
        if !len(pass)
            echo "Cancel"
            return []
        endif
    endif
    "post
    let result = system("curl -s -F vimrc=@".postfile." -F user=".user." -F pass=".pass." -F gvim=1 ".g:vimrcbox_baseurl."api/register")
    if result =~ '1'
        echo "Update success"
    else
        echo "Update failure" 
    end
endfunction

command! -nargs=? -complete=file RcbVimrc :call s:VrbUpdateVimrc(<f-args>)
command! -nargs=? -complete=file RcbGVimrc :call s:VrbUpdateGvimrc(<f-args>)
