" ==================== Settings ==================== "
" Define and reset augroup used in vimrc
augroup vimrc
    autocmd!
augroup END

" Platform detection
let s:is_mac = has('macunix') || (executable('uname') && system('uname') =~? '^darwin')
let s:is_win = has('win32') || has('win64')

" Default runtime directory
let s:runtimepath = expand(s:is_win ? '~/vimfiles' : '~/.vim')

" generate 'runtimepath' and helptags using pathogen
if has('vim_starting')
    let &runtimepath = &runtimepath . ',' . s:runtimepath . '/bundle/pathogen'
    call pathogen#runtime_append_all_bundles()
    call pathogen#helptags()
endif

" Get SID prefix of vimrc (see :h <SID>)
function! s:SID_PREFIX()
    return matchstr(expand('<sfile>'), '<SNR>\d\+_')
endfunction

" Get dirname
function! s:dirname(path)
    return isdirectory(a:path) ? a:path : fnamemodify(a:path, ':p:h')
endfunction

" Tab
set tabstop=4 shiftwidth=4 softtabstop=4 " set tab width
set expandtab   " use space rather than tab
set smartindent " use smart indent
set history=100 " number of command history

" Input support
set backspace=indent,eol,start " delete everything with backspace
set formatoptions+=m           " add multibyte support
set nolinebreak                " don't break line automatically
set iminsert=0
set imsearch=0

" Command completion
set wildmenu                   " enhance command completion
set wildmode=list:longest,full " use 'list:longest' at first and then use 'full'

" Search
set wrapscan   " search wrap around the end of the file
set ignorecase " use ignore case search
set smartcase  " override 'ignorecase' if the search pattern contains upper case
set incsearch  " use incremental search
set hlsearch   " highlight searched words
nohlsearch     " avoid highlighting when reloading vimrc

" Reading and writing file
set directory-=.    " don't save tmp swap file in current directory
set autoread        " auto re-read when the file is modified by other applications
set hidden          " allow opening other buffer without saving current buffer
set tags=./tags;    " search tag file recursively (see :h file-searching)

" Display
set notitle                   " don't rewrite title string
set showmatch                 " highlight corresponds character
set showcmd                   " show input command
set noshowmode                " for echodoc
set number                    " show line number
set wrap                      " wrap long lines
set scrolloff=5               " minimal number of screen lines to keep above and below the cursor
set foldmethod=marker         " use marker for folding
set foldcolumn=3              " display folds
set list                      " show unprintable characters
set listchars=tab:>\ ,trail:~ " strings to use in 'list'
set ambiwidth=double          " use double width for Eastern Asian Ambiguous characters

" Statusline
set laststatus=2 " always show statusine
let &statusline = '%!' . s:SID_PREFIX() . 'statusline()'
function! s:statusline()
    let s = '%2*%w%r%*%y'
    let s .= '[' . (&fenc != '' ? &fenc : &enc) . ']'
    let s .= '[' . &ff . ']'
    let s .= ' %<%F%1*%m%*%= %v,%l/%L(%P)'
    return s
endfunction

" Tabline
set showtabline=2 " always show tabline
let &tabline = '%!' . s:SID_PREFIX() . 'tabline()'
function! s:tabline()
    " show each tab
    let s = ''
    for i in range(1, tabpagenr('$'))
        let list = tabpagebuflist(i)
        let nr = tabpagewinnr(i)
        if exists('*gettabvar')
            let title = fnamemodify(gettabvar(i, 'cwd'), ':t') . '/'
        else
            let title = fnamemodify(bufname(list[nr - 1]), ':t')
        endif
        let title = empty(title) ? '[No Name]' : title

        let s .= i == tabpagenr() ? '%#TabLineSel#' : '%#TabLine#'
        let s .= '%' . i . 'T[' . i . '] ' . title
        let s .= '  '
    endfor

    " show cwd for current tab
    let tabpaged_cwd = exists('t:cwd') ? '[' . t:cwd . ']' : ''

    " show lingr unread count
    let lingr_unread = ""
    if exists('*lingr#unread_count')
        let lingr_unread_count = lingr#unread_count()
        if lingr_unread_count > 0
            let lingr_unread = "%#ErrorMsg#(" . lingr_unread_count . ")"
        elseif lingr_unread_count == 0
            let lingr_unread = "()"
        endif
    endif

    " build tabline
    let s .= '%#TabLineFill#%T%=%<' . tabpaged_cwd . lingr_unread
    return s
endfunction

" Display cursorline only in active window
" Reference: http://nanabit.net/blog/2007/11/03/vim-cursorline/
augroup vimrc
    autocmd WinLeave * setlocal nocursorline
    autocmd WinEnter,BufRead * setlocal cursorline
augroup END

" Use set encoding=utf-8 in Windows
" needs ja.po with utf-8 encoding as $VIMRUNTIME/lang/ja_JP.UTF-8/LC_MESSAGES/vim.mo
" Reference: http://d.hatena.ne.jp/thinca/20090111/1231684962
if s:is_win && has('gui')
    let $LANG='ja_JP.UTF-8'
    set encoding=utf-8
    set termencoding=cp932 " mainly for ref-phpmanual
endif

" detect charset automatically
if &encoding ==# 'utf-8'
    set fileencodings=iso-2022-jp,euc-jp,cp932,utf-8,latin1
else
    set fileencodings=iso-2022-jp,utf-8,euc-jp,cp932,latin1
endif

" use 'fileencoding' for 'encoding' if the file doesn't contain multibyte characters
" give up searching multibyte characters when searching time is over 500 ms
autocmd vimrc BufReadPost *
\   if &fileencoding =~# 'iso-2022-jp' && search("[^\x01-\x7e]", 'n', 0, 500) == 0
\|      let &fileencoding=&encoding
\|  endif

" detect line feed character
if s:is_win
    set ffs=dos,unix
else
    set ffs=unix,dos
endif

" Omni completion
set completeopt+=menuone " Display menu

" File type settings
filetype indent on " to use filetype indent
filetype plugin on " to use filetype plugin

" Show quickfix automatically
autocmd vimrc QuickfixCmdPost * if !empty(getqflist()) | cwindow | endif

" Save and load fold settings automatically
" Reference: http://vim-users.jp/2009/10/hack84/
" Don't save options.
set viewoptions-=options
augroup vimrc
    autocmd BufWritePost *
    \   if expand('%') != '' && &buftype !~ 'nofile'
    \|      mkview
    \|  endif
    autocmd BufRead *
    \   if expand('%') != '' && &buftype !~ 'nofile'
    \|      silent loadview
    \|  endif
augroup END
if s:is_win
    let &viewdir = s:runtimepath . '\view'
endif

" Persistent undo
if has('persistent_undo')
    set undofile
    let &undodir = s:runtimepath . '/undo'
endif


" ==================== Hightlight ==================== "
augroup vimrc
    autocmd ColorScheme * call s:onColorScheme()
    autocmd VimEnter,WinEnter * call matchadd('ZenkakuSpace', '　')
augroup END
function! s:onColorScheme()
    " Modify colorscheme
    if !exists('g:colors_name')
        return
    endif

    if g:colors_name == 'lucius'
        " based on SpecialKey
        highlight ZenkakuSpace ctermbg=239 guibg=#405060
        " based on ErrorMsg
        highlight User1 ctermbg=237 ctermfg=196 cterm=bold
        \               guibg=#363946 guifg=#e5786d gui=bold
        " based on ModeMsg
        highlight User2 ctermbg=237 ctermfg=117 cterm=bold
        \               guibg=#363946 guifg=#76d5f8 gui=bold
    else
        highlight ZenkakuSpace ctermbg=77
    endif
endfunction

syntax enable " enable syntax coloring

" colorscheme
if &t_Co == 256 || has('gui')
    colorscheme lucius
else
    colorscheme desert
endif


" ==================== Keybind and commands ==================== "
" Use AlterCommand and Arpeggio
call altercmd#load()
call arpeggio#load()

Arpeggionmap fj <Esc>
Arpeggioimap fj <Esc>
Arpeggiocmap fj <Esc>
Arpeggiovmap fj <Esc>

" submode
let g:submode_timeoutlen=600

" Use more logical mapping (see :h Y)
nnoremap Y y$

" Prefix
" Reference: http://d.hatena.ne.jp/kuhukuhun/20090213/1234522785
nnoremap [Prefix] <Nop>
vnoremap [Prefix] <Nop>
nmap <Space> [Prefix]
vmap <Space> [Prefix]
noremap [Operator] <Nop>
map , [Operator]

" Mapping command
command! -nargs=+ NExchangeMap call s:exchangeMap('n', <f-args>)
command! -nargs=+ CExchangeMap call s:exchangeMap('c', <f-args>)
command! -nargs=+ VExchangeMap call s:exchangeMap('v', <f-args>)
function! s:exchangeMap(mode, a, b)
    execute a:mode . 'noremap' a:a a:b
    execute a:mode . 'noremap' a:b a:a
endfunction

command! -bang -nargs=+ CommandMap call s:commandMap('nnoremap', <bang>0, <f-args>)
command! -bang -nargs=+ ArpeggioCommandMap call s:commandMap('Arpeggionnoremap', <bang>0, <f-args>)
function! s:commandMap(command, buffer, lhs, ...)
    let rhs = join(a:000, ' ')
    let buffer = a:buffer ? '<buffer>' : ''
    execute a:command '<silent>' buffer a:lhs ':<C-u>' . rhs . '<CR>'
endfunction

command! -nargs=+ PopupMap call s:popupMap(<f-args>)
function! s:popupMap(lhs, ...)
    let rhs = join(a:000, ' ')
    execute 'inoremap <silent> <expr>' a:lhs 'pumvisible() ?' rhs ': "' . a:lhs . '"'
endfunction

" Use physical cursor movement
" NExchangeMap j gj
nnoremap <Plug>(arpeggio-default:j) gj
nnoremap gj j
" VExchangeMap j gj
vnoremap <Plug>(arpeggio-default:j) gj
vnoremap gj j
" NExchangeMap k gk
nnoremap <Plug>(arpeggio-default:k) gk
nnoremap gk k
VExchangeMap gk k
NExchangeMap $ g$
VExchangeMap $ g$
NExchangeMap 0 g0
VExchangeMap 0 g0

" Use beginning matches on command-line history
CExchangeMap <C-p> <Up>
CExchangeMap <C-n> <Down>

" cmdwin
set cmdwinheight=3
augroup vimrc
    autocmd CmdwinEnter * startinsert!
    \|   nnoremap <buffer> <Esc> :<C-u>q<CR>
    \|   Arpeggioinoremap <buffer> fj <Esc>:<C-u>q<CR>
augroup END

" Write file easely
CommandMap [Prefix]w update

" Allow undo for i_CTRL-u and i_CTRL-w
" Reference: http://vim-users.jp/2009/10/hack81/
inoremap <C-u> <C-g>u<C-u>
inoremap <C-w> <C-g>u<C-w>

" Folding
" Reference: http://d.hatena.ne.jp/ns9tks/20080318/1205851539
" hold with 'h' if the cursor is on the head of line
nnoremap <expr> h col('.') == 1 && foldlevel(line('.')) > 0 ? 'zc' : 'h'
" expand with 'l' if the cursor on the holded text
nnoremap <expr> l foldclosed(line('.')) != -1 ? 'zo' : 'l'
" hold with 'h' if the cursor is on the head of line in visual mode
vnoremap <expr> h col('.') == 1 && foldlevel(line('.')) > 0 ? 'zcgv' : 'h'
" expand with 'l' if the cursor on the holded text in visual mode
vnoremap <expr> l foldclosed(line('.')) != -1 ? 'zogv' : 'l'

" Delete highlight
CommandMap gh nohlsearch

" Select last changed or yanked text
nnoremap gc `[v`]

" Input path in command mode
cnoremap <expr> <C-x> expand('%:p:h') . "/"
cnoremap <expr> <C-z> expand('%:p:r')

" Copy and paste with fakeclip
" Command-C and Command-V are also available in MacVim
" see :help fakeclip-multibyte-on-mac
map gy "*y
map gp "*p
if exists('$WINDOW') || exists('$TMUX')
    map gY <Plug>(fakeclip-screen-y)
    map gP <Plug>(fakeclip-screen-p)
endif

" Tab move
nnoremap L gt
nnoremap H gT

" Merge tabpage into a tab
" Reference: http://gist.github.com/434502
function! s:exists_tab(tabpagenr)
    return 1 <= a:tabpagenr && a:tabpagenr <= tabpagenr('$')
endfunction

function! s:merge_tab_into_tab(from_tabpagenr, to_tabpagenr)
    if !s:exists_tab(a:from_tabpagenr)
    \   || !s:exists_tab(a:to_tabpagenr)
    \   || a:from_tabpagenr == a:to_tabpagenr
        return
    endif

    execute 'tabnext' a:to_tabpagenr
    for bufnr in tabpagebuflist(a:from_tabpagenr)
        split
        execute bufnr 'buffer'
    endfor

    execute 'tabclose' a:from_tabpagenr
endfunction

nnoremap [Prefix]mh :<C-u>call <SID>merge_tab_into_tab(tabpagenr(), tabpagenr() - 1)<CR>
nnoremap [Prefix]ml :<C-u>call <SID>merge_tab_into_tab(tabpagenr(), tabpagenr() + 1)<CR>
nnoremap [Prefix]m  :<C-u>call <SID>merge_tab_into_tab(tabpagenr(), input('tab number:'))<CR>

" Window resize
call submode#enter_with('winsize', 'n', '', '<C-w>>', '<C-w>>')
call submode#enter_with('winsize', 'n', '', '<C-w><', '<C-w><')
call submode#enter_with('winsize', 'n', '', '<C-w>+', '<C-w>+')
call submode#enter_with('winsize', 'n', '', '<C-w>-', '<C-w>-')
call submode#map('winsize', 'n', '', '>', '<C-w>>')
call submode#map('winsize', 'n', '', '<', '<C-w><')
call submode#map('winsize', 'n', '', '+', '<C-w>+')
call submode#map('winsize', 'n', '', '-', '<C-w>-')

" Enable mouse wheel
" In Mac, Only on iTerm.app, disable on Terminal.app
if s:is_mac
    set mouse=a
    set ttymouse=xterm2
endif

" Binary (see :h xxd)
" vim -b :edit binary using xxd-format!
" Reference: http://vim-users.jp/2010/03/hack133/
augroup vimrc
    autocmd BufReadPost,BufNewFile *.bin,*.exe,*.dll,*.swf setlocal filetype=xxd
    autocmd BufReadPost * if &l:binary | setlocal filetype=xxd | endif
augroup END

" TabpageCD
" Reference: kana's vimrc
command! -complete=file -nargs=? TabpageCD
\   execute 'cd' fnameescape(<q-args>)
\|  let t:cwd = getcwd()

AlterCommand cd TabpageCD
command! CD silent execute 'TabpageCD' fnameescape(expand('%:p:h'))

autocmd vimrc VimEnter,TabEnter *
\   if !exists('t:cwd')
\|    let t:cwd = getcwd()
\|  endif
\|  execute 'cd' fnameescape(t:cwd)

" Go to alternate tab
if !exists('g:AlternateTabNumber')
    let g:AlternateTabNumber = 1
endif

command! GoToAlternateTab silent execute 'tabnext' g:AlternateTabNumber
CommandMap g<C-^> GoToAlternateTab

autocmd vimrc TabLeave * let g:AlternateTabNumber = tabpagenr()

" Rename
command! -nargs=1 -bang -complete=file Rename saveas<bang> <args> | call delete(expand('#'))

" ctags
command! CtagsR !ctags -R

" ColorScheme selecter
" Reference: http://vim.g.hatena.ne.jp/tyru/20100226
fun! s:SelectColorS()
    30vnew

    let files = split(globpath(&rtp, 'colors/*.vim'), "\n")
    for idx in range(0, len(files) - 1)
        let file = files[idx]
        let name = matchstr(file , '\w\+\(\.vim\)\@=')
        call setline(idx + 1, name)
    endfor

    file ColorSchemeSelector
    setlocal bufhidden=wipe
    setlocal buftype=nofile
    setlocal nonu
    setlocal nomodifiable
    setlocal cursorline
    nnoremap <buffer> <Enter> :<C-u>exec 'colors' getline('.')<CR>
    nnoremap <buffer> q       :<C-u>close<CR>
endf
command! SelectColorS call s:SelectColorS()

" Alternate grep
" Reference: http://vim-users.jp/2010/03/hack130/
command! -complete=file -nargs=+ Grep call s:grep([<f-args>])
function! s:grep(args)
    execute 'vimgrep' '/'.a:args[-1].'/' join(a:args[:-2])
endfunction
AlterCommand gr[ep] Grep

" Expand VimBall
command! -bang -nargs=? -complete=dir VimBallHere call s:vimBallHere(<bang>0, <f-args>)
function! s:vimBallHere(force_mkdir, ...)
    let ffs_save = &ffs
    set ffs=unix
    let home = a:0 ? expand(a:1) : getcwd()
    if !isdirectory(home) && a:force_mkdir
        echomsg 'create directory:' home
        call mkdir(home, 'p')
    endif
    UseVimball `=home`
    let &ffs = ffs_save
endfunction

" Growl for Mac
if executable("growlnotify")
    command! -nargs=+ Growl call s:growl(<f-args>)
    function! s:growl(title, ...)
        execute printf('silent !growlnotify -t %s -m %s -H localhost',
        \   shellescape(a:title, 1), shellescape(join(a:000), 1))
    endfunction
    function! s:growl_lingr(title, ...)
        execute printf('silent !growlnotify -t %s -m %s -H localhost -I /Applications/LingrRadar.app',
        \   shellescape(a:title, 1), shellescape(join(a:000), 1))
    endfunction
endif

" Quicklook for Mac
if executable("qlmanage")
    command! -nargs=? -complete=file Quicklook call s:quicklook(<f-args>)
    function! s:quicklook(...)
        let file = a:0 ? expand(a:1) : expand('%:p')
        execute printf('silent !qlmanage -p %s >& /dev/null',
        \   shellescape(file, 1))
    endfunction

    if executable('curl')
        command! -nargs=1 QuicklookRemote call s:quicklook_remote(<f-args>)
        function! s:quicklook_remote(url)
            let fragment = split(a:url, '/')
            let name = tempname() . fragment[-1]
            execute printf('silent !curl -o %s -O %s',
            \   shellescape(name, 1), shellescape(a:url, 1))
            call s:quicklook(name)
        endfunction

        " for Lingr-Vim (should use :python?)
        autocmd vimrc FileType lingr-messages nnoremap <silent> <buffer> O :<C-u>call <SID>lingr_vim_quicklook()<CR>
        function! s:lingr_vim_quicklook()
            let pattern = '^https\?://[^ ]*\.\(png\|jpe\?g\|gif\)$'
            let candidate = expand('<cWORD>')
            if match(candidate, pattern) == 0
                echo 'opening' candidate '...'
                call s:quicklook_remote(candidate)
                echo
            endif
        endfunction
    endif
endif


" ==================== Plugins settings ==================== "
" FileType
let g:python_highlight_all = 1
augroup vimrc
    " some ftplugins set 'textwidth'
    autocmd FileType * setlocal textwidth=0

    " Vim (use :help)
    autocmd FileType vim setlocal keywordprg=:help

    " Ruby
    autocmd FileType ruby,eruby,yaml setlocal softtabstop=2 shiftwidth=2 tabstop=2
    autocmd BufNewFile,BufRead *.ru setfiletype ruby

    " less
    autocmd BufNewFile,BufRead *.less setfiletype css

    " haml (inline)
    autocmd BufNewFile,BufRead *.rb
    \   unlet b:current_syntax
    \|  syn include @rubyData syntax/haml.vim
    \|  syn region rubyDataHaml matchgroup=rubyData start="^__END__$" keepend end="\%$" contains=@rubyData 
    \|  syn match inFileTemplateName '^@@\w\+' containedin=rubyDataHaml 
    \|  hi def link inFileTemplateName Type
    \|  let b:current_syntax = "ruby"

    " CakePHP
    autocmd BufNewFile,BufRead *.thtml setfiletype php
    autocmd BufNewFile,BufRead *.ctp setfiletype php

    " Scala
    " Reference: http://d.hatena.ne.jp/tyru/20090406/1239015151
    autocmd FileType scala
    \   setlocal softtabstop=2 shiftwidth=2 tabstop=2
    \|  setlocal iskeyword+=@-@ " for javadoc
    \|  setlocal includeexpr=substitute(v:fname,'\\.','/','g')
    \|  setlocal suffixesadd=.scala
    \|  setlocal suffixes+=.class
    \|  setlocal comments& comments^=s0:*\ -,m0:*\ \ ,ex0:*/
    \|  setlocal commentstring=//%s
    \|  setlocal formatoptions-=t formatoptions+=croql

    " Textile
    autocmd BufRead,BufNewFile *.textile setfiletype textile

    " tmux
    autocmd BufRead,BufNewFile .tmux.conf*,tmux.conf* setfiletype tmux
augroup END

" vimproc
if s:is_mac
    let g:vimproc_dll_path = s:runtimepath . '/bundle/vimproc/autoload/proc_mac.so'
elseif has('unix')
    let g:vimproc_dll_path = s:runtimepath . '/bundle/vimproc/autoload/proc_gcc.so'
endif

" gist
if s:is_mac
    let g:gist_clip_command = 'pbcopy'
endif
let g:gist_detect_filetype = 1
let g:gist_open_browser_after_post = 1

" operator-replace
map [Operator]r <Plug>(operator-replace)

" caw
let g:caw_no_default_keymappings = 1
let g:caw_find_another_action = 1

nmap gA <Plug>(caw:a:comment)

" caw + operator-user
function! s:set_caw_operator(key, name)
    call operator#user#define(
    \   'caw-' . a:name,
    \   s:SID_PREFIX() . 'do_caw_command',
    \   'call ' . s:SID_PREFIX() . 'set_caw_command("' . a:name . '")')
    execute 'map' a:key '<Plug>(operator-caw-' . a:name . ')'
endfunction

function! s:set_caw_command(name)
    let s:caw_command = a:name
endfunction

function! s:do_caw_command(motion_wiseness)
    let func = 'caw#'
    if s:caw_command == 'comment'
        if a:motion_wiseness == 'line'
            let func .= 'do_I_comment'
        else
            let func .= 'do_wrap_comment'
        endif
    elseif s:caw_command == 'toggle'
        if a:motion_wiseness == 'line'
            let func .= 'do_I_toggle'
        else
            let func .= 'do_wrap_toggle'
        endif
    elseif s:caw_command == 'uncomment'
        let func .= 'do_uncomment_i'
    else
        echoerr 'operator caw: unknown command:' s:caw_command
        return
    endif

    let v = operator#user#visual_command_from_wise_name(a:motion_wiseness)
    execute 'normal! `[' . v . "`]\<Esc>"
    call call(func, ['v'])
endfunction

let s:caw_prefix = "m"
onoremap <Space> g@
call s:set_caw_operator(s:caw_prefix . 'c', 'comment')
call s:set_caw_operator(s:caw_prefix . 'd', 'uncomment')
call s:set_caw_operator(s:caw_prefix . '<Space>', 'toggle')

" Align
let g:loaded_AlignMapsPlugin = '1'

" Align + operator-user
call operator#user#define('align', s:SID_PREFIX() . 'doAlignCommand')
map [Operator]a <Plug>(operator-align)

function! s:doAlignCommand(motion_wiseness)
    let separators = input(":'[,']Align ")

    " apply only lines that contain separators
    call Align#AlignPush()
    call Align#AlignCtrl('g ' . join(split(separators, '\s\+'), '\|'))

    let v = operator#user#visual_command_from_wise_name(a:motion_wiseness)
    execute 'normal! `[' . v . "`]\<Esc>"
    '<,'>call Align#Align(0, separators)

    call Align#AlignPop()
endfunction

" neocomplcache
" Reference: :h neocomplcache
let g:neocomplcache_enable_at_startup = 1
let g:neocomplcache_auto_completion_start_length = 2
let g:neocomplcache_min_keyword_length = 3
let g:neocomplcache_min_syntax_length = 3
let g:neocomplcache_ignore_case = 0
let g:neocomplcache_enable_smart_case = 1
let g:neocomplcache_enable_camel_case_completion = 1
let g:neocomplcache_enable_underbar_completion = 1
let g:neocomplcache_disable_caching_buffer_name_pattern = "\.log$\|\.zsh_history"
if !exists('g:neocomplcache_dictionary_filetype_lists')
    let g:neocomplcache_dictionary_filetype_lists = {}
endif
let g:neocomplcache_dictionary_filetype_lists['vimshell'] = expand('~/.vimshell_hist')
if !exists('g:neocomplcache_vim_completefuncs')
   let g:neocomplcache_vim_completefuncs = {}
endif
let g:neocomplcache_vim_completefuncs.Ref = 'ref#complete'
if !exists('g:neocomplcache_filetype_include_lists')
    let g:neocomplcache_filetype_include_lists = {}
endif
let g:neocomplcache_filetype_include_lists['php'] =
\   [{'filetype': 'html', 'start': '?>', 'end': '<?'}]

inoremap <expr> <C-y> neocomplcache#smart_close_popup()
inoremap <expr> <C-e> neocomplcache#cancel_popup()
imap <expr> <C-l> neocomplcache#sources#snippets_complete#expandable()
\   ? "\<Plug>(neocomplcache_snippets_expand)"
\   : neocomplcache#complete_common_string()
smap <silent> <C-l> <Plug>(neocomplcache_snippets_expand)
CommandMap [Prefix]ne NeoComplCacheEnable
CommandMap [Prefix]nd NeoComplCacheDisable

" echodoc
let g:echodoc_enable_at_startup = 1

" vimshell
augroup vimrc
    autocmd FileType vimshell nunmap <buffer> <C-d>
augroup END

" execute repl
" phpsh: http://github.com/facebook/phpsh
" node:  http://nodejs.org/
let s:simple_repl_programs = {
\   'php':        'phpsh',
\   'ruby':       'irb',
\   'python':     'python',
\   'perl':       'perl -de 1',
\   'scala':      'scala-2.8',
\   'javascript': 'node',
\   'haskell':    'ghci',
\   'erlang':     'erl'
\}
function! s:simple_repl()
    if !exists(':VimShell')
        echo "This command requires VimShell"
        return
    endif

    if !has_key(s:simple_repl_programs, &filetype)
    \   || !executable(split(s:simple_repl_programs[&filetype])[0])
        echo "This filetype is not supported"
        return
    endif

    execute "VimShellInteractive" s:simple_repl_programs[&filetype]
    let b:interactive.is_close_immediately = 1

endfunction
CommandMap [Prefix]R call <SID>simple_repl()
vnoremap [Prefix]v :VimShellSendString<CR>

" Unite
let g:unite_update_time = 100
let g:unite_enable_start_insert = 1
let g:unite_enable_split_vertically = 0

call unite#set_substitute_pattern('files', '^$VIM', substitute(substitute($VIM,  '\\', '/', 'g'), ' ', '\\\\ ', 'g'), -100)
call unite#set_substitute_pattern('files', '^\.vim', s:runtimepath, -100)
call unite#set_substitute_pattern('files', '\$\w\+', '\=eval(submatch(0))', 200)
call unite#set_substitute_pattern('files', ' ', '**', 100)

let s:unite_tabopen = {
\   'is_selectable': 1,
\   'description': 'open files or buffers in new tab'
\}
function! s:unite_tabopen.func(candidates)
    for c in a:candidates
        call unite#take_action('tabopen', c)
        TabpageCD `=s:dirname(c.word)`
    endfor
endfunction
call unite#custom_action('file,directory,buffer', 'tabopen', s:unite_tabopen)

let s:unite_nerdtree = {
\   'description': 'open NERD_tree with selected item'
\}
function! s:unite_nerdtree.func(candidate)
   NERDTree `=s:dirname(a:candidate.word)`
endfunction
call unite#custom_action('file,directory', 'nerdtree', s:unite_nerdtree)

ArpeggioCommandMap km Unite -buffer-name=files buffer file_mru tags file
ArpeggioCommandMap kb Unite -buffer-name=tabs buffer_tab tab
execute 'ArpeggioCommandMap ke call ' s:SID_PREFIX() . 'unite_help_with_ref()'

function! s:unite_help_with_ref()
    let ref_source = ref#detect()

    " try to use ref
    if !empty(ref_source)
        execute 'Unite -buffer-name=help' 'ref/' . ref_source
    " otherwise show :help
    else
        Unite -buffer-name=help help
    endif
endfunction

autocmd vimrc FileType unite call s:unite_settings()
function! s:unite_settings()
    imap <buffer> <silent> <C-n> <Plug>(unite_insert_leave)<Plug>(unite_loop_cursor_down)
    nmap <buffer> <silent> <C-n> <Plug>(unite_loop_cursor_down)
    nmap <buffer> <silent> <C-p> <Plug>(unite_loop_cursor_up)
    nmap <buffer> <silent> <C-u> <Plug>(unite_append_end)<Plug>(unite_delete_backward_line)

    Arpeggioimap <buffer> <silent> fj <Plug>(unite_exit)
    nmap <buffer> <silent> <Esc> <Plug>(unite_exit)
    nmap <buffer> <silent> / <Plug>(unite_do_narrow_action)

    imap <buffer> <silent> <expr> <C-t> unite#do_action("tabopen")
    nmap <buffer> <silent> <expr> <C-t> unite#do_action("tabopen")
endfunction

" NERDTree
let g:NERDTreeWinSize = 21
CommandMap [Prefix]t NERDTree
ArpeggioCommandMap nt NERDTreeToggle

" ref
if s:is_mac
    let g:ref_refe_cmd = '/opt/local/bin/refe-1_8_7'
    let g:ref_refe_encoding = 'utf-8'
    let g:ref_refe_rsense_cmd = '/usr/local/lib/rsense-0.2/bin/rsense'
    let g:ref_phpmanual_path = expand('~/Documents/phpmanual')
elseif s:is_win
    let g:ref_refe_encoding = 'cp932'
    let g:ref_phpmanual_path = expand('~/Documents/phpmanual')
endif
let g:ref_alc_use_cache = 1
let g:ref_alc_start_linenumber = 43

nnoremap <C-k> :<C-u>execute 'Ref alc' expand('<cword>')<CR>

" lingr.vim
if s:is_mac
    let g:lingr_vim_command_to_open_url = 'open -g %s'
    augroup vimrc
        autocmd User plugin-lingr-message
        \   let s:temp = lingr#get_last_message()
        \|  if !empty(s:temp)
        \|      call s:growl_lingr(s:temp.nickname, s:temp.text)
        \|  endif
        \|  unlet s:temp

        autocmd User plugin-lingr-presence
        \   let s:temp = lingr#get_last_member()
        \|  if !empty(s:temp)
        \|      call s:growl_lingr(s:temp.name, (s:temp.presence ? 'online' : 'offline'))
        \|  endif
        \|  unlet s:temp
    augroup END
endif
let g:lingr_vim_time_format = "%Y/%m/%d %H:%M:%S"

" zencoding
let g:user_zen_settings = {
\    'indentation': repeat(' ', &tabstop),
\    'lang': 'ja'
\}

" swap
vmap [Prefix]s <Plug>SwapSwapOperands
vmap [Prefix]S <Plug>SwapSwapPivotOperands

" Reload Firefox
" Need MozRepl and +ruby
function! ReloadFirefox()
    if has('ruby')
        ruby <<EOF
        require 'net/telnet'
        telnet = Net::Telnet.new('Host' => 'localhost', 'Port' => 4242)
        telnet.puts('content.location.reload(true)')
        telnet.close
EOF
    else
        echoerr 'need has("ruby")'
    endif
endfunction
CommandMap [Prefix]rf call ReloadFirefox()

" Reload Safari
" Need RubyOSA and +ruby
function! ReloadSafari()
    if has('ruby') && s:is_mac
        ruby <<EOF
        require 'rubygems'
        require 'rbosa'
        safari = OSA.app('Safari')
        safari.do_javascript('location.reload(true)', safari.documents[0])
EOF
    else
        echoerr 'need has("mac") and has("ruby")'
    endif
endfunction
CommandMap [Prefix]rs call ReloadSafari()

" Utility command for Mac
if s:is_mac
    command! Here silent call system('open ' . expand('%:p:h'))
    command! This silent call system('open ' . expand('%:p'))
    command! -nargs=1 -complete=file Open silent call system('open ' . shellescape(expand(<f-args>), 1))
endif

" Utility command for Windows
if s:is_win
    command! Here silent execute '!explorer' expand('%:p:h')
    command! This silent execute '!start cmd /c "%"'
    command! -nargs=1 -complete=file Open silent execute '!explorer' shellescape(expand(<f-args>), 1)
endif

" TOhtml
let g:html_number_lines = 0
let g:html_use_css = 1
let g:use_xhtml = 1
let g:html_use_encoding = 'utf-8'

" metarw
call metarw#define_wrapper_commands(1)
AlterCommand e[dit] Edit
AlterCommand r[ead] Read
AlterCommand w[rite] Write
AlterCommand so[urce] Source

" Quickrun
let g:quickrun_no_default_key_mappings = 1
if !exists('g:quickrun_config')
    let g:quickrun_config = {}
endif
let g:quickrun_config._ = {
\   'runmode': 'async:vimproc'
\}
nmap [Prefix]q <Plug>(quickrun)


" ==================== Loading vimrc ==================== "
" Reference: http://vim-users.jp/2009/12/hack112/
" Load settings for each location.
autocmd vimrc BufNewFile,BufReadPost * call s:vimrc_local(expand('<afile>:p:h'))
function! s:vimrc_local(loc)
    let files = findfile('.vimrc.local', escape(a:loc, ' ') . ';', -1)
    for i in reverse(filter(files, 'filereadable(v:val)'))
        source `=i`
    endfor
endfunction

" Auto reloading vimrc
" Reference: http://vim-users.jp/2009/09/hack74/
if has('gui_running')
    autocmd vimrc BufWritePost .vimrc,_vimrc,vimrc nested
    \   source $MYVIMRC | source $MYGVIMRC
    autocmd vimrc BufWritePost .gvimrc,_gvimrc,gvimrc nested
    \   source $MYGVIMRC
else
    autocmd vimrc BufWritePost .vimrc nested
    \   source $MYVIMRC
endif

if filereadable(expand('~/.vimrc.local'))
    source ~/.vimrc.local
endif

set secure


" ==================== Plugins ==================== "
" align              : http://www.vim.org/scripts/script.php?script_id=294
" altercmd           : http://www.vim.org/scripts/script.php?script_id=2332
" arpeggio           : http://www.vim.org/scripts/script.php?script_id=2425
" cocoa              : http://www.vim.org/scripts/script.php?script_id=2674
" echodoc            : http://github.com/Shougo/echodoc
" errormarker        : http://www.vim.org/scripts/script.php?script_id=1861
" fakeclip           : http://www.vim.org/scripts/script.php?script_id=2098
" fontzoom           : http://www.vim.org/scripts/script.php?script_id=2931
" gist               : http://www.vim.org/scripts/script.php?script_id=2423
" haml               : http://github.com/tpope/vim-haml
" javascript(syntax) : http://www.vim.org/scripts/script.php?script_id=1491
" javascript(syntax) : http://www.vim.org/scripts/script.php?script_id=2802
" ku                 : http://www.vim.org/scripts/script.php?script_id=2337
" lingr-vim          : http://github.com/tsukkee/lingr-vim
" lucius             : http://www.vim.org/scripts/script.php?script_id=2536
" macports           : http://svn.macports.org/repository/macports/contrib/mpvim/
" markdown(syntax)   : http://www.vim.org/scripts/script.php?script_id=2882
" matchit            : http://www.vim.org/scripts/script.php?script_id=39
" metarw             : http://www.vim.org/scripts/script.php?script_id=2335
" metarw-git         : http://www.vim.org/scripts/script.php?script_id=2336
" muttator           : https://vimperator-labs.googlecode.com/hg/muttator/contrib/vim/
" neocomplcache      : http://github.com/Shougo/neocomplcache
" NERD_commenter     : http://www.vim.org/scripts/script.php?script_id=1218
" NERD_tree          : http://www.vim.org/scripts/script.php?script_id=1658
" omnicppcomplete    : http://www.vim.org/scripts/script.php?script_id=1520
" operator-replace   : http://www.vim.org/scripts/script.php?script_id=2782
" operator-user      : http://www.vim.org/scripts/script.php?script_id=2692
" pathogen           : http://www.vim.org/scripts/script.php?script_id=2332
" php53(syntax)      : http://www.vim.org/scripts/script.php?script_id=2874
" qfreplace          : http://github.com/thinca/vim-qfreplace
" quickrun           : http://github.com/thinca/vim-quickrun
" ref                : http://www.vim.org/scripts/script.php?script_id=3067
" scala              : https://lampsvn.epfl.ch/trac/scala/browser/scala-tool-support/trunk/src/vim
" submode            : http://www.vim.org/scripts/script.php?script_id=2467
" SudoEdit           : http://www.vim.org/scripts/script.php?script_id=2709
" surround           : http://github.com/kana/vim-surround
" swap               : http://www.vim.org/scripts/script.php?script_id=3250
" taskpaper          : http://www.vim.org/scripts/script.php?script_id=2027
" textile            : http://www.vim.org/scripts/script.php?script_id=2305
" textobj-comment    : http://gist.github.com/99234
" textobj-indent     : http://www.vim.org/scripts/script.php?script_id=2484
" textobj-user       : http://www.vim.org/scripts/script.php?script_id=2100
" tmux(syntax)       : http://tmux.cvs.sourceforge.net/viewvc/tmux/tmux/examples/tmux.vim
" unite              : http://github.com/Shougo/unite.vim
" vimperator         : https://vimperator-labs.googlecode.com/hg/vimperator/contrib/vim/
" vimproc            : http://github.com/Shougo/vimproc
" vimrcbox           : http://github.com/sorah/sandbox/blob/master/vim/vimrcbox.vim
" vimshell           : http://github.com/Shougo/vimshell
" web-indent         : http://www.vim.org/scripts/script.php?script_id=3081
" xoria256           : http://www.vim.org/scripts/script.php?script_id=2140
" zencoding          : http://www.vim.org/scripts/script.php?script_id=2981
