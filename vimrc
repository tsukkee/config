" Last Change: 07 May 2011
" Author:      tsukkee
" Licence:     The MIT License {{{
"     Permission is hereby granted, free of charge, to any person obtaining a copy
"     of this software and associated documentation files (the "Software"), to deal
"     in the Software without restriction, including without limitation the rights
"     to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
"     copies of the Software, and to permit persons to whom the Software is
"     furnished to do so, subject to the following conditions:
"
"     The above copyright notice and this permission notice shall be included in
"     all copies or substantial portions of the Software.
"
"     THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
"     IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
"     FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
"     AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
"     LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
"     OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
"     THE SOFTWARE.
" }}}


" ==================== Vundle ==================== "
let s:is_mac = has('macunix') || (executable('uname') && system('uname') =~? '^darwin')
let s:is_win = has('win32') || has('win64')
let s:runtimepath = expand(s:is_win ? '~/vimfiles' : '~/.vim')

filetype off

set runtimepath&
let &runtimepath = &runtimepath . ',' . s:runtimepath . '/bundle/vundle'
call vundle#rc()

Bundle 'cocoa.vim'
Bundle 'errormarker.vim'
Bundle 'fontzoom.vim'
Bundle 'Indent-Guides'
Bundle 'Javascript-Indentation'
Bundle 'JavaScript-syntax'
Bundle 'Lucius'
Bundle 'Markdown'
Bundle 'matchit.zip'
Bundle 'newspaper.vim'
Bundle 'SudoEdit.vim'
Bundle 'Textile-for-VIM'
Bundle 'xoria256.vim'
Bundle 'ZenCoding.vim'

" Bundle 'gmarik/vundle'
Bundle 'h1mesuke/vim-alignta'
Bundle 'h1mesuke/unite-outline'
Bundle 'kana/vim-altercmd'
Bundle 'kana/vim-arpeggio'
Bundle 'kana/vim-fakeclip'
Bundle 'kana/vim-metarw'
Bundle 'kana/vim-metarw-git'
Bundle 'kana/vim-operator-user'
Bundle 'kana/vim-operator-replace'
Bundle 'kana/vim-submode'
Bundle 'kana/vim-surround'
Bundle 'kana/vim-textobj-indent'
Bundle 'kana/vim-textobj-user'
Bundle 'Shougo/echodoc'
Bundle 'Shougo/neocomplcache'
Bundle 'Shougo/unite.vim'
Bundle 'Shougo/vimproc'
Bundle 'Shougo/vimshell'
Bundle 'thinca/vim-qfreplace'
Bundle 'thinca/vim-quickrun'
Bundle 'thinca/vim-ref'
Bundle 'thinca/vim-textobj-plugins'
Bundle 'tpope/vim-haml'
Bundle 'git@github.com:tsukkee/lingr-vim.git'
Bundle 'git@github.com:tsukkee/ttree.vim.git'
Bundle 'git@github.com:tsukkee/vundle.git'
Bundle 'git@github.com:tsukkee/unite-help.git'
Bundle 'git@github.com:tsukkee/unite-tag.git'
Bundle 'tyru/caw.vim'
Bundle 'tyru/operator-html-escape.vim'
Bundle 'ujihisa/unite-colorscheme'
Bundle 'git://gist.github.com/99234.git', {'name': 'textobj-comment'}

Bundle 'http://svn.macports.org/repository/macports/contrib/mpvim/'
Bundle 'http://lampsvn.epfl.ch/svn-repos/scala/scala-tool-support/trunk/src/vim', {'name': 'scala'}
" Bundle 'https://bitbucket.org/ns9tks/vim-l9'
" Bundle 'https://bitbucket.org/ns9tks/vim-fuzzyfinder'

Bundle 'muttator', {'type': 'nosync'}
Bundle 'vimperator', {'type': 'nosync'}
Bundle 'vimrcbox', {'type': 'nosync'}
Bundle 'tmux', {'type': 'nosync'}

filetype plugin indent on


" ==================== Settings ==================== "
" Define and reset augroup used in vimrc
augroup vimrc
    autocmd!
augroup END

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
set notagbsearch " don't use binary search
set wrapscan     " search wrap around the end of the file
set ignorecase   " use ignore case search
set smartcase    " override 'ignorecase' if the search pattern contains upper case
set incsearch    " use incremental search
set hlsearch     " highlight searched words
nohlsearch       " avoid highlighting when reloading vimrc

" Reading and writing file
set directory-=.    " don't save tmp swap file in current directory
set autoread        " auto re-read when the file is modified by other applications
set hidden          " allow opening other buffer without saving current buffer
set tags=./tags;    " search tag file recursively (see :h file-searching)

" Display
set title                     " don't rewrite title string
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

" Reference: http://vim.wikia.com/wiki/Automatically_set_screen_title
set titlelen=15
autocmd vimrc BufEnter * let &titlestring = '%{' . s:SID_PREFIX() . 'titlestring()}'
autocmd vimrc User plugin-lingr-unread let &titlestring = '%{' . s:SID_PREFIX() . 'titlestring()}'
if exists('$TMUX') || exists('$WINDOW')
    set t_ts=k
    set t_fs=\
endif
function! s:titlestring()
    if &filetype =~ '^lingr'
        let &titlestring = 'vim: [lingr: ' . lingr#unread_count() . ']'
    elseif exists('t:cwd')
        let &titlestring = 'vim: %<' . t:cwd
    else
        let &titlestring = 'vim: %<' . bufname('')
    endif
endfunction

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
    let tabpage_cwd = exists('t:cwd') ? '[' . t:cwd . ']' : ''

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
    let s .= '%#TabLineFill#%T%=%<' . tabpage_cwd . lingr_unread
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
    language messages ja_JP.UTF-8
    set encoding=utf-8
    set termencoding=cp932 " mainly for ref-phpmanual
endif

" detect encoding
if has('kaoriya')
    set fileencodings=guess
else
    set fileencodings=iso-2022-jp,euc-jp,cp932,utf-8,latin1
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

" Show quickfix automatically
autocmd vimrc QuickfixCmdPost * if !empty(getqflist()) | cwindow | endif

" Save and load fold settings automatically
" Reference: http://vim-users.jp/2009/10/hack84/
" Don't save options.
set viewoptions-=options
let &viewdir = s:runtimepath . '/view'
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

" Session
set sessionoptions=buffers,curdir,folds,tabpages
let s:session_file = expand('~/.session.vim')
function! s:save_session()
    let cwd = getcwd()
    cd ~
    mksession! `=s:session_file`
    cd `=cwd`
    echo "Session saved."
endfunction
function! s:load_session()
    let neco_enabled = exists(':NeoComplCacheDisable')
    if neco_enabled
        NeoComplCacheDisable
    endif
    if filereadable(s:session_file)
        let cwd = getcwd()
        cd ~
        source `=s:session_file`
        cd `=cwd`
    endif
    tabdo CD
    if neco_enabled
        NeoComplCacheEnable
    endif
endfunction
nnoremap <silent> [Prefix]S :<C-u>call <SID>load_session()<CR>
nnoremap <silent> [Prefix]s :<C-u>call <SID>save_session()<CR>

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
        " ligher Comment
        highlight Comment ctermfg=244 guifg=#808080

        " indent guids
        highlight IndentGuidesOdd ctermbg=235
        highlight IndentGuidesEven ctermbg=236
    else
        highlight ZenkakuSpace ctermbg=77
    endif
endfunction

syntax enable " enable syntax coloring

" Indent guide
let g:indent_guides_enable_on_vim_startup = 1
let g:indent_guides_auto_colors = 0
let g:indent_guides_guide_size = 1

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
let g:arpeggio_timeoutlen = 100

Arpeggionmap fj <Esc>
Arpeggioimap fj <Esc>
Arpeggiocmap fj <Esc>
Arpeggiovmap fj <Esc>

" submode
let g:submode_timeoutlen=600

" Use more logical mapping (see :h Y)
nnoremap Y y$

" Reference: http://vim-users.jp/2011/04/hack214/
onoremap ) t)
onoremap ( t(
onoremap > t>
onoremap < t<
onoremap ] t]
onoremap [ t[

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
command! -complete=dir -nargs=? TabpageCD
\   execute 'cd' fnameescape(<q-args>)
\|  let t:cwd = getcwd()

AlterCommand cd TabpageCD
command! -nargs=0 CD silent execute 'TabpageCD' unite#util#path2project_directory(expand('%:p'))

autocmd vimrc VimEnter,TabEnter *
\   if !exists('t:cwd')
\|    let t:cwd = getcwd()
\|  endif
\|  execute 'cd' fnameescape(t:cwd)

" Go to alternate tab
if !exists('g:AlternateTabNumber')
    let g:AlternateTabNumber = 1
endif

command! -nargs=0 GoToAlternateTab silent execute 'tabnext' g:AlternateTabNumber
CommandMap g<C-^> GoToAlternateTab

autocmd vimrc TabLeave * let g:AlternateTabNumber = tabpagenr()

" Rename
command! -nargs=1 -bang -complete=file Rename saveas<bang> <args> | call delete(expand('#'))

" ctags
command! -nargs=0 CtagsR !ctags -R

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

" Last change
let g:lastchange_pattern  = 'Last Change: '
let g:lastchange_locale   = s:is_win ? 'English' : 'en_US.UTF-8'
let g:lastchange_format   = '%d %b %Y'
" let g:lastchange_format   = '%a %b %d, %Y at %I:%M %p %z'
let g:lastchange_line_num = 10

autocmd vimrc BufWritePre * call s:write_last_change()
command! NOMOD let b:do_not_modify_last_change = 1
command! MOD   unlet b:do_not_modify_last_change

function! s:write_last_change()
    if exists('b:do_not_modify_last_change') || !&modified
        return
    endif

    let save_lc_time = v:lc_time
    execute 'language time' g:lastchange_locale
    for i in range(0, g:lastchange_line_num)
        let line = getline(i)
        if line =~ g:lastchange_pattern
            call setline(i, substitute(line,
            \   g:lastchange_pattern . '.*',
            \   g:lastchange_pattern . strftime(g:lastchange_format),
            \   ''))
            break
        endif
    endfor
    execute 'language time' save_lc_time
endfunction

" Suicide
command! Suicide call system('kill -KILL ' . getpid())

" Undo close tab
" How can I detect tab closing
let s:tabcount = 0
let g:tabclose_histries = []
augroup vimrc
    autocmd VimEnter,TabEnter * let s:tabcount = tabpagenr('$')
    " autocmd WinEnter * echomsg 'enter:count' tabpagenr('$')
    autocmd TabLeave * if s:tabcount > tabpagenr('$') | echomsg 'tabclose' | endif
    " autocmd TabLeave * echomsg 'leave:count' tabpagenr('$')
augroup END

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

    " tex
    autocmd FileType plaintex,tex
    \   setlocal foldmethod=expr
    \|  let &l:foldexpr = s:SID_PREFIX() . 'tex_foldexpr(v:lnum)'
    " folding using \section, \subsection, \subsubsection
    function! s:tex_foldexpr(lnum)
        " set fold level as section level
        let matches = matchlist(getline(a:lnum), '^\s*\\\(\(sub\)*\)section')
        if !empty(matches)
            " For example, matches[1] is 'subsub' when line is '\subsubsection'
            return len(matches[1]) / 3 + 1
        else
            " when next line is /\\(sub)*section/, this line is the end of specified section
            let matches = matchlist(getline(a:lnum + 1), '^\s*\\\(\(sub\)*\)section')
            if !empty(matches)
                return '<' . string(len(matches[1]) / 3 + 1)
            " otherwise keep fold level
            else
                return '='
            endif
        endif
    endfunction

    " dot
    autocmd FileType txt
    \   setlocal foldmethod=expr
    \|  let &l:foldexpr = 'Dot_foldexpr(v:lnum)'
    function! Dot_foldexpr(lnum)
        let match = matchstr(getline(a:lnum), '^\.\+')
        if !empty(match)
            return len(match)
        else
            let match = matchstr(getline(a:lnum + 1), '^\.\+')
            if !empty(match)
                return '<' . string(len(match))
            else
                return '='
            endif
        endif
    endfunction
augroup END

" surround
nmap s  <Plug>Ysurround
nmap S  <Plug>YSurround
nmap ss <Plug>Yssurround
nmap Ss <Plug>YSsurround
nmap SS <Plug>YSsurround

" vimproc
" if s:is_mac
"     let g:vimproc_dll_path = s:runtimepath . '/bundle/vimproc/autoload/proc_mac.so'
" elseif has('unix')
"     let g:vimproc_dll_path = s:runtimepath . '/bundle/vimproc/autoload/proc_gcc.so'
" endif

" gist
if s:is_mac
    let g:gist_clip_command = 'pbcopy'
endif
let g:gist_detect_filetype = 1
let g:gist_open_browser_after_post = 1

" operator-replace
map [Operator]r <Plug>(operator-replace)

" operator-html-escape
map [Operator]h <Plug>(operator-html-escape)
map [Operator]u <plug>(operator-html-unescape)

" caw
let g:caw_find_another_action = 1

augroup vimrc
    autocmd FileType plaintex,tex let b:caw_oneline_comment = '%'
augroup END

nmap gA <Plug>(caw:a:comment)
nmap <Plug>(arpeggio-default:m) <Plug>(caw:prefix)
vmap m <Plug>(caw:prefix)
nmap <Plug>(caw:prefix)<Space> <Plug>(caw:i:toggle)

" neocomplcache
" Reference: :h neocomplcache
let g:neocomplcache_enable_at_startup = 1
let g:neocomplcache_auto_completion_start_length = 2
let g:neocomplcache_manual_completion_start_length = 1
let g:neocomplcache_min_keyword_length = 3
let g:neocomplcache_min_syntax_length = 3
let g:neocomplcache_ignore_case = 0
let g:neocomplcache_enable_smart_case = 1
let g:neocomplcache_enable_camel_case_completion = 1
let g:neocomplcache_enable_underbar_completion = 1
let g:neocomplcache_disable_caching_file_path_pattern = "\.log$\|\.zsh_history"
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
inoremap <expr> <C-x><C-f> neocomplcache#manual_filename_complete()
imap <expr> <C-l> neocomplcache#sources#snippets_complete#expandable()
\   ? "\<Plug>(neocomplcache_snippets_expand)"
\   : neocomplcache#complete_common_string()
smap <silent> <C-l> <Plug>(neocomplcache_snippets_expand)
CommandMap [Prefix]ne NeoComplCacheEnable
CommandMap [Prefix]nd NeoComplCacheDisable

" echodoc
let g:echodoc_enable_at_startup = 1

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
let g:unite_source_file_mru_limit = 200
let g:unite_source_file_mru_time_format = '(%Y/%m/%d %T) '
let g:unite_source_file_rec_max_depth = 5

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
        TabpageCD `=s:dirname(c.action__path)`
    endfor
endfunction
call unite#custom_action('file,directory,buffer', 'tabopen', s:unite_tabopen)

ArpeggioCommandMap km Unite -buffer-name=files buffer file_mru file
ArpeggioCommandMap kb Unite -buffer-name=tabs buffer_tab tab
ArpeggioCommandMap kt Unite -buffer-name=outline outline tags
execute 'ArpeggioCommandMap ke call ' s:SID_PREFIX() . 'unite_help_with_ref()'

autocmd vimrc BufEnter *
\   if empty(&buftype)
\|      nnoremap <buffer> <C-]> :<C-u>UniteWithCursorWord -immediately tag<CR>
\|  endif

function! s:unite_help_with_ref()
    let unite_args = []

    let ref_source = ref#detect()
    if !empty(ref_source)
        call add(unite_args, ["ref/" . ref_source])
    endif

    call add(unite_args, ["help"])

    call unite#start(unite_args)
endfunction

autocmd vimrc FileType unite call s:unite_settings()
function! s:unite_settings()
    imap <buffer> <silent> <C-n> <Plug>(unite_insert_leave)<Plug>(unite_loop_cursor_down)
    imap <buffer> <silent> <C-p> <Plug>(unite_insert_leave)<Plug>(unite_loop_cursor_up)
    nmap <buffer> <silent> <C-n> <Plug>(unite_loop_cursor_down)
    nmap <buffer> <silent> <C-p> <Plug>(unite_loop_cursor_up)
    nmap <buffer> <silent> <C-u> <Plug>(unite_append_end)<Plug>(unite_delete_backward_line)

    Arpeggioimap <buffer> <silent> fj <Plug>(unite_exit)
    nmap <buffer> <silent> <Esc> <Plug>(unite_exit)
    nmap <buffer> <silent> <expr> / unite#do_action("narrow")

    imap <buffer> <silent> <expr> <C-t> unite#do_action("tabopen")
    nmap <buffer> <silent> <expr> <C-t> unite#do_action("tabopen")
endfunction

" ttree
let g:ttree_replace_netrw = 1

CommandMap [Prefix]t call ttree#show(getcwd())
ArpeggioCommandMap nt TtreeToggle

autocmd FileType ttree call s:setup_ttree()
function! s:setup_ttree()
    CommandMap! ct call <SID>ttree_tabpagecd()
    CommandMap! cu call <SID>ttree_unite_filerec()
endfunction

function! s:ttree_tabpagecd()
    let dir = s:dirname(ttree#get_node().path)
    CD
endfunction

function! s:ttree_unite_filerec()
    let path = s:dirname(ttree#get_node().path)
    if winnr('$') > 1
        wincmd p
    else
        let w = winwidth(winnr()) - g:ttree_width
        execute 'botright' w 'vnew'
    endif
    call unite#start([["file_rec", path]])
endfunction

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
    elseif has('python')
        python <<EOF
# coding=utf-8
import telnetlib
telnet = telnetlib.Telnet('localhost', 4242)
telnet.read_until('repl> ', 10)
telnet.write('content.location.reload(true)')
telnet.close()
EOF
    else
        echoerr 'need has("ruby") or has("python")'
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
