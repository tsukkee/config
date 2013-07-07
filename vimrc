" Last Change: 07 Jul 2013
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

scriptencoding utf-8

" ==================== Utilities ==================== "
let s:is_win = has('win32') || has('win64')
let s:is_mac = has('unix')
" let s:is_mac = has('macunix') || (executable('uname') && system('uname') =~? '^darwin')
let s:runtimepath = expand(s:is_win ? '~/vimfiles' : '~/.vim')

" define and reset augroup used in vimrc
augroup vimrc
    autocmd!
augroup END

" get SID prefix of vimrc
" See: :h <SID>
function! s:SID_PREFIX()
    return matchstr(expand('<sfile>'), '<SNR>\d\+_')
endfunction

" get dirname
function! s:dirname(path)
    return isdirectory(a:path) ? a:path : fnamemodify(a:path, ':p:h')
endfunction


" ==================== NeoBundle ==================== "
filetype plugin indent off

if has('vim_starting')
    let &runtimepath = &runtimepath . ',' . s:runtimepath . '/bundle/neobundle.vim'
endif
let g:neobundle_default_git_protocol = 'https'
call neobundle#rc(expand(s:runtimepath . '/bundle'))

NeoBundle 'ag.vim', {'lazy': 1}
NeoBundle 'errormarker.vim', {'lazy': 1}
NeoBundle 'Indent-Guides'
NeoBundle 'matchit.zip'
NeoBundle 'SudoEdit.vim'
NeoBundle 'Vdebug', {'lazy': 1}

NeoBundle 'altercation/vim-colors-solarized'
NeoBundle 'bling/vim-airline'
NeoBundle 'davidhalter/jedi-vim', {'lazy': 1,
            \ 'autoload': { 'filetypes': ['python']}}
NeoBundle 'deton/jasegment.vim', {'lazy': 1,
            \ 'autoload': { 'filetypes': ['text', 'txt']}}
NeoBundle 'h1mesuke/textobj-wiw'
NeoBundle 'h1mesuke/vim-alignta'
NeoBundle 'kana/vim-altercmd'
NeoBundle 'kana/vim-arpeggio'
NeoBundle 'kana/vim-fakeclip'
NeoBundle 'kana/vim-operator-replace'
NeoBundle 'kana/vim-operator-user'
NeoBundle 'kana/vim-smartinput'
NeoBundle 'kana/vim-submode'
NeoBundle 'kana/vim-tabpagecd'
NeoBundle 'kana/vim-textobj-indent'
NeoBundle 'kana/vim-textobj-user'
NeoBundle 'kien/ctrlp.vim'
NeoBundle 'mattn/wiseman-f-vim'
NeoBundle 'mattn/benchvimrc-vim', {'lazy': 1}
 NeoBundle 'osyo-manga/shabadou.vim', {'lazy': 1}
NeoBundle 'osyo-manga/vim-reanimate'
NeoBundle 'osyo-manga/vim-watchdogs', {'lazy': 1}
NeoBundle 'Rykka/colorv.vim', {'lazy': 1}
NeoBundle 'scrooloose/nerdtree'
NeoBundle 'scrooloose/syntastic', {'lazy': 1}
NeoBundle 'Shougo/neobundle.vim'
NeoBundle 'Shougo/neocomplcache'
NeoBundle 'Shougo/unite.vim'
NeoBundle 'Shougo/vimproc'
NeoBundle 'Shougo/vimshell', {'lazy': 1}
NeoBundle 'Shougo/vinarise', {'lazy': 1}
NeoBundle 't9md/vim-quickhl'
NeoBundle 't9md/vim-textmanip'
NeoBundle 'thinca/vim-prettyprint', {'lazy': 1}
NeoBundle 'thinca/vim-qfreplace', {'lazy': 1}
NeoBundle 'thinca/vim-quickrun'
NeoBundle 'thinca/vim-ref'
NeoBundle 'thinca/vim-scall', {'lazy': 1}
NeoBundle 'thinca/vim-showtime', {'lazy': 1}
NeoBundle 'thinca/vim-textobj-comment'
NeoBundle 'tomtom/tcomment_vim'
NeoBundle 'tpope/vim-repeat'
NeoBundle 'tpope/vim-surround'
NeoBundle 'ujihisa/unite-colorscheme'
NeoBundle 'vim-jp/autofmt'

NeoBundle 'git@github.com:tsukkee/lingr-vim.git'
NeoBundle 'git@github.com:tsukkee/ttree.vim.git', {'lazy': 1}
NeoBundle 'git@github.com:tsukkee/unite-help.git'
NeoBundle 'git@github.com:tsukkee/unite-tag.git'

NeoBundle 'http://lampsvn.epfl.ch/svn-repos/scala/scala-tool-support/trunk/src/vim',
            \ {'name': 'scala', 'directory': 'scala', 'type': 'svn'}
NeoBundle 'http://svn.macports.org/repository/macports/contrib/mpvim/', {'type': 'svn'}

NeoBundle 'muttator', {'type': 'nosync', 'lazy': 1}
NeoBundle 'tmux', {'type': 'nosync'}
NeoBundle 'vimperator', {'type': 'nosync'}

filetype plugin indent on

" ==================== Settings ==================== "
if s:is_win
    set shellslash
endif

" indent
set tabstop=4
set shiftwidth=4
set softtabstop=4
set expandtab
set smartindent

" input
set backspace=indent,eol,start
set formatoptions+=mM " add multibyte support
set formatexpr=jpvim#formatexpr()
set nolinebreak
set iminsert=0
set imsearch=0

" command completion
set wildmenu
set wildmode=list:longest,full

" search
set wrapscan
set ignorecase
set smartcase
set incsearch
set hlsearch
nohlsearch " reset highlighting when reloading vimrc
set wildignore+=*/.git*,*/.hg/*,*/.svn/*

" reading and writing file
set directory-=. " don't save tmp swap file in current directory
set autoread
set hidden
set tags=./tags; " search tag file recursively (See: :h file-searching)

" interface
set showmatch
set showcmd
set showmode
set number
set wrap
set scrolloff=5
set foldmethod=marker
set foldcolumn=3
set list
set listchars=tab:^\ ,trail:~
set ambiwidth=double

" title
" Reference: http://vim.wikia.com/wiki/Automatically_set_screen_title
set title
set titlelen=100
autocmd vimrc BufEnter * let &titlestring = '%{' . s:SID_PREFIX() . 'titlestring()}'
autocmd vimrc User plugin-lingr-unread let &titlestring = '%{' . s:SID_PREFIX() . 'titlestring()}'
if exists('$TMUX') || exists('$WINDOW')
    set t_ts=k
    set t_fs=\
endif
function! s:titlestring()
    if &filetype =~ '^lingr'
        return 'vim: [lingr: ' . lingr#unread_count() . ']'
    else
        return 'vim: ' . bufname('')
    endif
endfunction

" statusline
set laststatus=2 " always show statusine

" tabline
set showtabline=2 " always show tabline
let &tabline = '%!' . s:SID_PREFIX() . 'tabline()'
let s:max_tabwidth = 16
let s:v = {}
function! s:tabline()
    if empty(s:v)
        let s:v = vital#of('unite.vim') " for truncate()
    endif

    " show each tab
    let s = ''
    let title_width = min([s:max_tabwidth, &columns / (tabpagenr('$') + 1) - 1])
    for i in range(1, tabpagenr('$'))
        let list = tabpagebuflist(i)
        let nr = tabpagewinnr(i)
        let current_tabnr = tabpagenr()

        let title = fnamemodify(bufname(list[nr - 1]), ':t')
        if empty(title) | let title = '[No Name]' | endif
        let title = s:v.truncate(title, title_width)

        let s .= i == tabpagenr() ? '%#TabLineSel#' : '%#TabLine#'
        let s .= '%' . i . 'T' . title
        let s .= '%#SpecialKey#|'
    endfor

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
    let s .= '%#TabLineFill#%T%=%<[' . getcwd() . ']' . lingr_unread
    return s
endfunction

" display cursorline only in active window
" Reference: http://nanabit.net/blog/2007/11/03/vim-cursorline/
augroup vimrc
    autocmd WinLeave * setlocal nocursorline
    autocmd WinEnter,BufRead * setlocal cursorline
augroup END

" use set encoding=utf-8 in Windows
if s:is_win && has('gui_running')
    language messages ja_JP.UTF-8
    set encoding=utf-8
endif

" detect encoding
if has('kaoriya')
    set fileencodings=guess
else
    set fileencodings=iso-2022-jp,euc-jp,cp932,utf-8,latin1
endif

" use 'fileencoding' for 'encoding' if the file doesn't contain multibyte characters
" give up searching multibyte characters when searching time is over 100 ms
autocmd vimrc BufReadPost *
\   if &fileencoding =~# 'iso-2022-jp' && search("[^\x01-\x7e]", 'n', 0, 100) == 0
\|      let &fileencoding=&encoding
\|  endif

" detect line feed character
if s:is_win
    set ffs=dos,unix
else
    set ffs=unix,dos
endif

" omni completion
set completeopt+=menuone

" show quickfix automatically
autocmd vimrc QuickfixCmdPost * if !empty(getqflist()) | cwindow | endif

" save and load fold settings automatically
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

" session
set sessionoptions=buffers,folds,resize,tabpages

" persistent undo
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

    if g:colors_name == 'solarized'
        " based on SpecialKey
        highlight ZenkakuSpace ctermbg=185
        " indent guids
        highlight IndentGuidesOdd ctermbg=187
        highlight IndentGuidesEven ctermbg=186
    else
        highlight ZenkakuSpace ctermbg=77
    endif
endfunction

syntax enable

" Indent guide
let g:indent_guides_enable_on_vim_startup = 1
let g:indent_guides_auto_colors = 0
let g:indent_guides_guide_size = 1

" colorscheme
if &t_Co == 256 || has('gui')
    let g:solarized_contrast = 'high'
    set background=light
    colorscheme solarized
else
    colorscheme desert
endif

" ==================== Keybind and commands ==================== "
" Use AlterCommand and Arpeggio
call altercmd#load()
call arpeggio#load()
let g:arpeggio_timeoutlen = 100

" make easy to execute <Esc>
Arpeggionmap fj <Esc>
Arpeggioimap fj <Esc>
Arpeggiocmap fj <Esc>
Arpeggiovmap fj <Esc>

" submode
let g:submode_timeoutlen=600

" use more logical mapping (See: :h Y)
nnoremap Y y$

" open new tab at last
nnoremap <silent> <C-n> :<C-u>99tabnew<CR>

" prefix
" Reference: http://d.hatena.ne.jp/kuhukuhun/20090213/1234522785
nnoremap [Prefix] <Nop>
vnoremap [Prefix] <Nop>
nmap <Space> [Prefix]
vmap <Space> [Prefix]
noremap [Operator] <Nop>
map , [Operator]

" mapping command
command! -bang -nargs=+ CommandMap call s:commandMap('nnoremap', <bang>0, <f-args>)
command! -bang -nargs=+ ArpeggioCommandMap call s:commandMap('Arpeggionnoremap', <bang>0, <f-args>)
function! s:commandMap(command, buffer, lhs, ...)
    let rhs = join(a:000, ' ')
    let buffer = a:buffer ? '<buffer>' : ''
    execute a:command '<silent>' buffer a:lhs ':<C-u>' . rhs . '<CR>'
endfunction

" use physical cursor movement
nnoremap <Plug>(arpeggio-default:j) gj
nnoremap gj j
vnoremap <Plug>(arpeggio-default:j) gj
vnoremap gj j
nnoremap <Plug>(arpeggio-default:k) gk
nnoremap gk k
vnoremap gk k
vnoremap k gk
nnoremap $ g$
nnoremap g$ $
vnoremap $ g$
vnoremap g$ $
nnoremap 0 g0
nnoremap g0 0
vnoremap 0 g0
vnoremap g0 0

" use beginning matches on command-line history
cnoremap <C-p> <Up>
cnoremap <Up> <C-p>
cnoremap <C-n> <Down>
cnoremap <Down> <C-n>

" cmdwin
set cmdwinheight=1
augroup vimrc
    autocmd CmdwinEnter * startinsert!
    \|   nnoremap <buffer> <Esc> :<C-u>q<CR>
    \|   Arpeggioinoremap <buffer> fj <Esc>:<C-u>q<CR>
augroup END

" write file easely
CommandMap [Prefix]w update

" allow undo for i_CTRL-u, i_CTRL-w and <CR>
" Reference: http://vim-users.jp/2009/10/hack81/
inoremap <expr> <C-u> (pumvisible() ? "\<C-e>" : "") . "\<C-g>u\<C-u>"
inoremap <C-w> <C-g>u<C-w>
inoremap <CR> <C-g>u<CR>

" folding
" Reference: http://d.hatena.ne.jp/ns9tks/20080318/1205851539
nnoremap <expr> h col('.') == 1 && foldlevel(line('.')) > 0 ? 'zc' : 'h'
nnoremap <expr> l foldclosed(line('.')) != -1 ? 'zo' : 'l'
vnoremap <expr> h col('.') == 1 && foldlevel(line('.')) > 0 ? 'zcgv' : 'h'
vnoremap <expr> l foldclosed(line('.')) != -1 ? 'zogv' : 'l'

" reset highlight
CommandMap gh nohlsearch

" select last changed or yanked text
nnoremap gl `[v`]

" input path in command mode
cnoremap <expr> <C-x> expand('%:p:h') . "/"
cnoremap <expr> <C-z> expand('%:p:r')

" copy and paste with fakeclip
" See: :h fakeclip-multibyte-on-mac
map gy "*y
map gp "*p
if exists('$WINDOW') || exists('$TMUX')
    map gY <Plug>(fakeclip-screen-y)
    map gP <Plug>(fakeclip-screen-p)
endif

" tab move
call submode#enter_with('tabmove', 'n', '', 'gt', 'gt')
call submode#enter_with('tabmove', 'n', '', 'gT', 'gT')
call submode#map('tabmove', 'n', '', 't', 'gt')
call submode#map('tabmove', 'n', '', 'T', 'gT')

" window resizing with submode
call submode#enter_with('winsize', 'n', '', '<C-w>>', '<C-w>>')
call submode#enter_with('winsize', 'n', '', '<C-w><', '<C-w><')
call submode#enter_with('winsize', 'n', '', '<C-w>+', '<C-w>+')
call submode#enter_with('winsize', 'n', '', '<C-w>-', '<C-w>-')
call submode#map('winsize', 'n', '', '>', '<C-w>>')
call submode#map('winsize', 'n', '', '<', '<C-w><')
call submode#map('winsize', 'n', '', '+', '<C-w>+')
call submode#map('winsize', 'n', '', '-', '<C-w>-')

" enable mouse wheel with iTerm2
if s:is_mac
    set mouse=a
    set ttymouse=xterm2
endif

" binary editing (See: :h xxd)
" TODO: use vinarize
" Reference: http://vim-users.jp/2010/03/hack133/
augroup vimrc
    autocmd BufReadPost,BufNewFile *.bin,*.exe,*.dll,*.swf,*.bmp setlocal filetype=xxd
    autocmd BufReadPost * if &l:binary | setlocal filetype=xxd | endif
augroup END

" cd to project directory
command! -nargs=0 CD execute 'cd' unite#util#path2project_directory(expand('%:p'))

" rename
command! -nargs=1 -bang -complete=file Rename saveas<bang> <args> | call delete(expand('#'))

" ctags
command! -nargs=0 CtagsR !ctags -R

" alternate grep
" Reference: http://vim-users.jp/2010/03/hack130/
set grepprg=jvgrep
command! -complete=file -nargs=+ Jvgrep call s:grep('grep', [<f-args>])
command! -complete=file -nargs=+ Vimgrep call s:grep('vimgrep', [<f-args>])
function! s:grep(cmd, args)
    execute a:cmd a:args[-1] join(a:args[:-2])
endfunction
" AlterCommand gr[ep] Jvgrep
AlterCommand gr[ep] Vimgrep

" expand VimBall
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

" growl for mac
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

" quicklook for mac
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

        " for Lingr-Vim (should use :python ?)
        " autocmd vimrc FileType lingr-messages nnoremap <silent> <buffer> O :<C-u>call <SID>lingr_vim_quicklook()<CR>
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

" last change
let g:lastchange_pattern  = 'Last Change: '
let g:lastchange_locale   = s:is_win ? 'English' : 'en_US.UTF-8'
let g:lastchange_format   = '%d %b %Y'
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

" suicide
command! Suicide call system('kill -KILL ' . getpid())

" ==================== Plugins settings ==================== "
" FileType
let g:python_highlight_all = 1
augroup vimrc
    " some ftplugins set 'textwidth'
    autocmd FileType * setlocal textwidth=0

    " vim (use :help)
    autocmd FileType vim setlocal keywordprg=:help

    " ruby
    autocmd FileType ruby,eruby,yaml setlocal softtabstop=2 shiftwidth=2 tabstop=2

    " less
    autocmd BufNewFile,BufRead *.less setfiletype css

    " CakePHP
    autocmd BufNewFile,BufRead *.thtml setfiletype php
    autocmd BufNewFile,BufRead *.ctp setfiletype php

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
            " for example, matches[1] is 'subsub' when line is '\subsubsection'
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
augroup END

" surround
nmap s  <Plug>Ysurround
nmap S  <Plug>YSurround
nmap ss <Plug>Yssurround
nmap Ss <Plug>YSsurround
nmap SS <Plug>YSsurround

" operator-replace
map [Operator]r <Plug>(operator-replace)

" neocomplcache
let g:neocomplcache_enable_at_startup = 0

inoremap <expr> <C-y> neocomplcache#smart_close_popup()
inoremap <expr> <C-e> neocomplcache#cancel_popup()
imap <expr> <C-l> neocomplcache#sources#snippets_complete#expandable()
\   ? "\<Plug>(neocomplcache_snippets_expand)"
\   : neocomplcache#complete_common_string()
smap <silent> <C-l> <Plug>(neocomplcache_snippets_expand)

" execute repl
" phpsh: http://github.com/facebook/phpsh
let s:simple_repl_programs = {
\   'php':        'phpsh',
\   'ruby':       'irb',
\   'python':     'python',
\   'perl':       'perl -de 1',
\   'scala':      'scala',
\   'javascript': 'node',
\   'haskell':    'ghci',
\   'erlang':     'erl'
\}
function! s:simple_repl()
    NeoBundleSource vimshell
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

" unite
let g:unite_enable_start_insert = 1
let g:unite_source_file_mru_time_format = '(%Y/%m/%d %T) '

ArpeggioCommandMap km Unite -buffer-name=files buffer file_mru file
ArpeggioCommandMap kt Unite -buffer-name=tags tags
execute 'ArpeggioCommandMap ke call ' s:SID_PREFIX() . 'unite_help_with_ref()'

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
let s:did_unite_setting = 0
function! s:unite_settings()
    if !s:did_unite_setting
        " call unite#set_substitute_pattern('files', '^$VIM', substitute(substitute($VIM,  '\\', '/', 'g'), ' ', '\\\\ ', 'g'), -100)
        " call unite#set_substitute_pattern('files', '^\.vim', s:runtimepath, -100)
        let s:did_unite_setting = 1
    endif

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

" nerdtree
CommandMap [Prefix]t NERDTree
ArpeggioCommandMap nt NERDTreeToggle

" ttree
" let g:ttree_replace_netrw = 1
" 
" CommandMap [Prefix]t call ttree#show(getcwd())
" ArpeggioCommandMap nt TtreeToggle
" 
" autocmd FileType ttree call s:setup_ttree()
" function! s:setup_ttree()
"     CommandMap! ct call <SID>ttree_cd()
"     CommandMap! cu call <SID>ttree_unite_filerec()
" endfunction
" 
" function! s:ttree_cd()
"     let dir = s:dirname(ttree#get_node().path)
"     cd `=dir`
" endfunction
" 
" function! s:ttree_unite_filerec()
"     let path = s:dirname(ttree#get_node().path)
"     if winnr('$') > 1
"         wincmd p
"     else
"         let w = winwidth(winnr()) - g:ttree_width
"         execute 'botright' w 'vnew'
"     endif
"     call unite#start([["file_rec/async", path]])
" endfunction

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
let g:lingr_vim_terminate_thread_immediately = 1
let g:lingr_vim_time_format = "%Y/%m/%d %H:%M:%S"

" reload Firefox
" needs MozRepl and +ruby
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
        echoerr 'needs has("ruby") or has("python")'
    endif
endfunction
CommandMap [Prefix]rf call ReloadFirefox()

" utility command for Mac
if s:is_mac
    command! Here silent call system('open ' . expand('%:p:h'))
    command! This silent call system('open ' . expand('%:p'))
    command! -nargs=1 -complete=file Open silent call system('open ' . shellescape(expand(<f-args>), 1))
endif

" utility command for Windows
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

" quickrun
let g:quickrun_no_default_key_mappings = 1
let g:quickrun_config = {
\   '_': {
\       'runner': 'python'
\   }
\}
nmap [Prefix]q <Plug>(quickrun)
vmap [Prefix]q :QuickRun<CR>

" textmanip
call submode#enter_with('textmanip', 'v', 'r', '<C-t>h', '<Plug>(textmanip-move-left)')
call submode#enter_with('textmanip', 'v', 'r', '<C-t>j', '<Plug>(textmanip-move-down)')
call submode#enter_with('textmanip', 'v', 'r', '<C-t>k', '<Plug>(textmanip-move-up)')
call submode#enter_with('textmanip', 'v', 'r', '<C-t>l', '<Plug>(textmanip-move-right)')
call submode#leave_with('textmanip', 'v', '', '<Esc>')
call submode#map('textmanip', 'v', 'r', 'h', '<Plug>(textmanip-move-left)')
call submode#map('textmanip', 'v', 'r', 'j', '<Plug>(textmanip-move-down)')
call submode#map('textmanip', 'v', 'r', 'k', '<Plug>(textmanip-move-up)')
call submode#map('textmanip', 'v', 'r', 'l', '<Plug>(textmanip-move-right)')

" quickhl
nmap [Prefix]m <Plug>(quickhl-toggle)
vmap [Prefix]m <Plug>(quickhl-toggle)
nmap [Prefix]M <Plug>(quickhl-reset)

" airline
let g:airline_theme = 'light'
let g:airline_left_sep=' '
let g:airline_right_sep=' '

" plain text
hi ColorColumn guibg=#aaaaaa
autocmd vimrc FileType text,txt
\   setl cc+=72
\|  setl textwidth=72
\|  setl formatexpr=autofmt#japanese#formatexpr()

" CtrlP
let g:ctrlp_tabpage_position = 'l'
let g:ctrlp_clear_cache_on_exit = 0
let g:ctrlp_max_depth = 2
let g:ctrlp_custom_ignore = {
\   'dir':  '\.git$\|\.hg$\|\.svn$\|\.neocon$\|\.unite$',
\   'file': '\.exe$\|\.so$\|\.dll$\|\.DS_Store$'
\ }

" reanimate
let g:reanimate_save_dir = s:runtimepath . '/reanimate'
command! -nargs=0 ReanimateSaveWithTimeStamp execute 'ReanimateSave' strftime('time%Y%m%d%H%M%S')
CommandMap [Prefix]ss ReanimateSaveWithTimeStamp
CommandMap [Prefix]sl ReanimateLoadLatest
CommandMap [Prefix]sL Unite reanimate -default-action=reanimate_load

autocmd vimrc VimLeave * call s:delete_old_sessions(10)
function! s:delete_old_sessions(num)
    let dirs = sort(split(globpath(g:reanimate_save_dir . '/' . g:reanimate_default_category, 'time*'), "\n"))
    let len = len(dirs)

    if len - a:num <= 0
        return
    endif

    for i in range(0, len - a:num - 1)
        if s:is_win
            call system('rmdir /s /q "' . dirs[i] . '"')
        elseif s:is_mac
            call system('rm -Rf ' . dirs[i])
        endif
    endfor
endfunction

" markdown-pandoc
let s:pandoc_command = "pandoc \"%s\" -s -c \"%s\" -o \"%s\" &"
let s:pandoc_default_css = 'pandoc.css'
let s:pandoc_default_formats = ['html']
let s:pandoc_output_encoding = s:is_win ? 'cp932' : 'utf-8'

function! s:pandoc_auto_run()
    if exists('b:pandoc_enable') && b:pandoc_enable
        let b:pandoc_auto_run = 1
    endif
endfunction

function! s:pandoc_stop_auto_run()
    let b:pandoc_auto_run = 0
endfunction

function! s:pandoc_run()
    if !exists('b:pandoc_auto_run') || !b:pandoc_auto_run | return | endif

    let input = expand('%')
    let base = expand('%:r')
    let css = exists('b:pandoc_css') ? b:pandoc_css : s:pandoc_default_css
    let formats = exists('b:pandoc_formats') && (type([]) == type(b:pandoc_formats))
                \ ? b:pandoc_formats : s:pandoc_default_formats

    for format in formats
        let c = iconv(printf(s:pandoc_command, input, css, base . '.' . format),
                    \ &encoding, s:pandoc_output_encoding)
        call vimproc#system(c)
        if vimproc#get_last_status() != 0
            echomsg vimproc#get_last_errmsg()
        endif
    endfor
endfunction

function! s:pandoc_parse_local_setting()
    let raw = matchstr(getline('$'), '<!--\zs.\+\ze-->')
    try
        sandbox let data = eval('{' . raw . '}')
        for [k, v] in items(data)
            let b:pandoc_{k} = v
            unlet k v
        endfor
    catch /E121/
        echomsg 'markdown: local setting parse error'
    endtry
endfunction

function! s:markdown_make_title()
    let l = strwidth(getline('.'))
    let n = line('.')
    let s = ''
    for i in range(l)
        let s .= '='
    endfor
    call append(n, s)
endfunction

function! s:pandoc_markdown_to_pdf()
    let oldcwd = getcwd()
    lcd `=expand("%:p:h")`

    let command = "pandoc %s -V documentclass=ltjarticle --latex-engine=lualatex -o %s"
    let input = expand('%')
    let output = expand('%:r') . '.pdf'
    let c = iconv(printf(command, input, output), &encoding, s:pandoc_output_encoding)
    call vimproc#system(c)
    if vimproc#get_last_status() != 0
        echomsg vimproc#get_last_errmsg()
    endif

    lcd `=oldcwd`
endfunction

function! s:pandoc_setup_markdown()
    call s:pandoc_parse_local_setting()
    call s:pandoc_auto_run()

    nnoremap <buffer> [Prefix]T :<C-u>call <SID>markdown_make_title()<CR>

    command! -buffer PandocAutoRun call s:pandoc_auto_run()
    command! -buffer PandocMarkdown2PDF call s:pandoc_markdown_to_pdf()
endfunction
autocmd vimrc BufWritePost *.mkd call s:pandoc_run()
autocmd vimrc FileType markdown call s:pandoc_setup_markdown()

" ==================== Loading vimrc ==================== "
" auto reloading vimrc
" Reference: http://vim-users.jp/2009/09/hack74/
if has('gui_running')
    autocmd vimrc BufWritePost .vimrc,_vimrc,vimrc nested
    \   source $MYVIMRC | source $MYGVIMRC
    autocmd vimrc BufWritePost .gvimrc,_gvimrc,gvimrc nested
    \   source $MYGVIMRC
else
    autocmd vimrc BufWritePost .vimrc,_vimrc,vimrc nested
    \   source $MYVIMRC
endif

if filereadable(expand('~/.vimrc.local'))
    source ~/.vimrc.local
endif

set secure
