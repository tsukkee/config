" ==================== Settings ==================== "
" Define and reset augroup used in vimrc
augroup vimrc
    autocmd!
    autocmd VimEnter * let g:vim_has_launched = 1
augroup END

" Default runtime directory
if has('win32')
    let s:runtimepath = expand('~/vimfiles')
else
    let s:runtimepath = expand('~/.vim')
endif

" Append 'runtimepath' and generate helptags
if !exists('g:vim_has_launched')
    let &runtimepath = &runtimepath . ',' . s:runtimepath . '/bundle/pathogen'
    call pathogen#runtime_append_all_bundles()
    call pathogen#helptags()
endif

" Get SID prefix of vimrc (see :h <SID>)
function! s:SID_PREFIX()
    return matchstr(expand('<sfile>'), '<SNR>\d\+_')
endfunction

" Tab
set tabstop=4 shiftwidth=4 softtabstop=4 " set tab width
set expandtab   " use space rather than tab
set smartindent " use smart indent
set history=100 " number of command history

" Input support
set backspace=indent,eol,start " delete everything with backspace
set formatoptions+=m           " add multibyte support
" set iskeyword+=-               " add keyword to '-'
set nolinebreak                " don't break line automatically
set textwidth=0                " don't break line automatically
set iminsert=0                 " disable input method control in insert mode
set imsearch=-1                " use same value with 'iminsert' for search mode

" Command completion
set wildmenu                   " enhance command completion
set wildmode=list:longest,full " first 'list:lingest' and second 'full'

" Search
set wrapscan   " search wrap around the end of the file
set ignorecase " ignore case search
set smartcase  " override 'ignorecase' if the search pattern contains upper case
set incsearch  " incremental search
set hlsearch   " highlight searched words
nohlsearch     " avoid highlighting when reloading vimrc

" Reading and writing file
set directory-=. " don't save tmp swap file in current directory
set autoread     " auto re-read when the file is written by other applications
" set hidden       " allow open other file without saving current file
set tags=./tags; " search tag file recursively (see :h file-searching)

" Display
set notitle                   " don't rewrite title string
set showmatch                 " highlight correspods character
set showcmd                   " show input command
set number                    " show line number
set wrap                      " wrap long lines
set scrolloff=5               " minimal number of screen lines to keep above and below the cursor
set foldmethod=marker         " use marker for folding
set foldcolumn=3              " display folds
set list                      " show unprintable characters
set listchars=tab:>\ ,trail:~ " strings to use in 'list'
set ambiwidth=double          " for multibyte characters, such as □, ○

" Status line
set laststatus=2 " always show statusine
let &statusline = '%!' . s:SID_PREFIX() . 'statusline()'
function! s:statusline()
    let s = '%2*%w%r%*%y'
    let s .= '[' . (&fenc != '' ? &fenc : &enc) . ']'
    let s .= '[' . &ff . ']'
    let s .= ' %<%F%1*%m%*%= %v,%l/%L(%P)'
    return s
endfunction

" Tab line
set showtabline=2 " always show tab bar
let &tabline = '%!' . s:SID_PREFIX() . 'tabline()'
function! s:tabline()
    let s = ''
    for i in range(1, tabpagenr('$'))
        let list = tabpagebuflist(i)
        let nr = tabpagewinnr(i)
        let title = fnamemodify(bufname(list[nr - 1]), ':t')
        let title = empty(title) ? '[No Name]' : title

        let s .= i == tabpagenr() ? '%#TabLineSel#' : '%#TabLine#'
        let s .= '%' . i . 'T[' . i . '] ' . title
        let s .= '  '
    endfor

    let tabpaged_cwd = exists('t:cwd') ? '[' . t:cwd . ']' : ''
    if exists('*lingr#unread_count')
        let lingr_unread_count = lingr#unread_count()
        if lingr_unread_count > 0
            let lingr_unread = "%#ErrorMsg#(" . lingr_unread_count . ")"
        elseif lingr_unread_count == 0
            let lingr_unread = "()"
        else
            let lingr_unread = ""
        endif
    else
        let lingr_unread = ""
    endif
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
if has('win32') && has('gui')
    let $LANG='ja_JP.UTF-8'
    set encoding=utf-8
endif

" Autodetect charset
" Reference: http://www.kawaz.jp/pukiwiki/?vim#cb691f26
if &encoding !=# 'utf-8'
    set encoding=japan
    set fileencoding=japan
endif
if has('iconv')
    " Reset (see :h fencs)
    if &encoding ==# 'utf-8'
        set fileencodings=ucs-bom,utf-8,default,latin1
    else
        set fileencodings=ucs-bom
    endif

    " check iconv supports eucJP-ms
    if iconv("\x87\x64\x87\x6a", 'cp932', 'eucjp-ms') ==# "\xad\xc5\xad\xcb"
        let s:enc_euc = 'eucjp-ms'
        let s:enc_jis = 'iso-2022-jp-3'
    " check iconv supports JISX0213
    elseif iconv("\x87\x64\x87\x6a", 'cp932', 'euc-jisx0213') ==# "\xad\xc5\xad\xcb"
        let s:enc_euc = 'euc-jisx0213'
        let s:enc_jis = 'iso-2022-jp-3'
    else
        let s:enc_euc = 'euc-jp'
        let s:enc_jis = 'iso-2022-jp'
    endif

    " build fileencodings (ignore euc-jp environment)
    " encoding=utf-8
    if &encoding ==# 'utf-8'
        let &fileencodings = join([s:enc_jis, s:enc_euc, 'cp932', &fileencodings], ",")
    " encoding=sjis
    else
        let &fileencodings =
        \   join([&fileencodings, s:enc_jis, 'utf-8', 'ucs-2le', 'ucs-2', s:enc_euc], ",")
    endif

    unlet s:enc_euc
    unlet s:enc_jis
endif

" use 'fileencoding' for 'encoding' if the file don't contain multibyte characters
" give up searching multibyte characters when searching time is over 500 ms
autocmd vimrc BufReadPost *
\   if &fileencoding =~# 'iso-2022-jp' && search("[^\x01-\x7e]", 'n', 0, 500) == 0
\|      let &fileencoding=&encoding
\|  endif

" line feed character
if has('unix')
    set ffs=unix,dos
elseif has('win32')
    set ffs=dos,unix
endif

" Omni completion
set completeopt+=menuone " Display menu

" File type settings
filetype indent on " to use filetype indent
filetype plugin on " to use filetype plugin

" Show quickfix automatically
" Reference: http://webtech-walker.com/archive/2009/09/29213156.html
autocmd vimrc QuickfixCmdPost make,grep,grepadd,vimgrep
\   if len(getqflist()) != 0
\|      copen
\|  endif

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
if has('win32')
    let &viewdir = s:runtimepath . '\view'
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

    if g:colors_name == 'xoria256'
        highlight CursorLine cterm=none gui=none
        highlight ZenkakuSpace ctermbg=77 guibg=#5fdf5f
    elseif g:colors_name == 'lucius'
        highlight ZenkakuSpace ctermbg=172 guibg=#ffaa00
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
    colorscheme torte
endif


" ==================== Keybind and commands ==================== "
" Use AlterCommand and Arpeggio
call altercmd#load()
call arpeggio#load()
Arpeggioinoremap fj <Esc>
Arpeggiocnoremap fj <Esc>
Arpeggiovnoremap fj <Esc>
let g:submode_timeoutlen=600

" Use more logical mapping (see :h Y)
nnoremap Y y$

" Prefix
" Reference: http://d.hatena.ne.jp/kuhukuhun/20090213/1234522785
nnoremap [Prefix] <Nop>
nmap <Space> [Prefix]
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

command! -nargs=+ PopupMap call s:popupMap(<f-args>)
function! s:popupMap(lhs, ...)
    let rhs = join(a:000, ' ')
    execute 'inoremap <silent> <expr>' a:lhs 'pumvisible() ?' rhs ': "' . a:lhs . '"'
endfunction

command! -bang -nargs=+ CommandMap call s:commandMap('<bang>', <f-args>)
function! s:commandMap(buffer, lhs, ...)
    let rhs = join(a:000, ' ')
    let buffer = a:buffer == '!' ? '<buffer>' : ''
    execute 'nnoremap <silent>' buffer a:lhs ':<C-u>' . rhs . '<CR>'
endfunction

" Use physical cursor movement
NExchangeMap j gj
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
augroup END

" Re-open with specified encoding
command! Utf8 edit ++enc=utf-8
command! Euc edit ++enc=euc-jp
command! Cp932 edit ++enc=cp932

" write file easely
nnoremap [Prefix]w :<C-u>update<CR>

" Allow undo for i_CTRL-u and i_CTRL-w
" Reference: http://vim-users.jp/2009/10/hack81/
inoremap <C-u> <C-g>u<C-u>
inoremap <C-w> <C-g>u<C-w>

" Folding
" Reference: http://d.hatena.ne.jp/ns9tks/20080318/1205851539
" hold with 'h' if the cursor is on the head of line
nnoremap <expr> h col('.') == 1 && foldlevel(line('.')) > 0 ? 'zc' : 'h'
" expand with 'l' if the cursor on the holded text
" nnoremap <expr> l foldclosed(line('.')) != -1 ? 'zo' : 'l'
nnoremap <expr> <Plug>(arpeggio-default:l) foldclosed(line('.')) != -1 ? 'zo' : 'l'
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
nnoremap <silent> <C-f>n gt
nnoremap <silent> <C-f><C-n> gt
nnoremap <silent> <C-f>p gT
nnoremap <silent> <C-f><C-p> gT

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
if has('mac')
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
\   cd `=fnameescape(<q-args>)`
\|  let t:cwd = getcwd()

AlterCommand cd TabpageCD
command! CD silent execute 'TabpageCD' expand('%:p:h')

autocmd vimrc VimEnter,TabEnter *
\   if !exists('t:cwd')
\|    let t:cwd = getcwd()
\|  endif
\|  cd `=fnameescape(t:cwd)`

" Go to alternate tab
if !exists('g:AlternateTabNumber')
    let g:AlternateTabNumber = 1
endif

command! GoToAlternateTab silent execute 'tabnext' g:AlternateTabNumber
CommandMap g<C-^> GoToAlternateTab
Arpeggionnoremap <silent> al :<C-u>GoToAlternateTab<CR>

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
    nnoremap <buffer>  <Enter>  :<C-u>exec 'colors' getline('.')<CR>
    nnoremap <buffer>  q        :<C-u>close<CR>
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
        execute printf('silent !growlnotify -H localhost -t %s -m %s',
        \   shellescape(a:title, 1), shellescape(join(a:000), 1))
    endfunction
    function! s:growl_lingr(title, ...)
        execute printf('silent !growlnotify -H localhost -t %s -m %s -I /Applications/LingrRadar.app',
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
augroup vimrc
    " some ftplugins set 'textwidth'
    autocmd FileType * setlocal textwidth=0

    " Vim (to use :help for K, see :h K)
    autocmd FileType vim setlocal keywordprg=""

    " Ruby
    autocmd FileType ruby,eruby,yaml setlocal softtabstop=2 shiftwidth=2 tabstop=2

    " less
    autocmd BufNewFile,BufRead *.less setfiletype css

    " haml (inline)
    autocmd BufNewFile,BufRead *.rb
    \   unlet b:current_syntax
    \|  syn include @rubyData syntax/haml.vim
    \|  syn region rubyDataHaml matchgroup=rubyData start="^__END__$" keepend end="\%$" contains=@rubyData
    \|  syn match inFileTemplateName "^@@\w\+" containedin=rubyData
    \|  hi def link inFileTemplateName Type

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
if has('mac')
    let g:vimproc_dll_path = s:runtimepath . '/bundle/vimproc/autoload/proc_mac.so'
elseif has('unix')
    let g:vimproc_dll_path = s:runtimepath . '/bundle/vimproc/autoload/proc_gcc.so'
endif

" gist
if has('mac')
    let g:gist_clip_command = 'pbcopy'
endif
let g:gist_detect_filetype = 1
let g:gist_open_browser_after_post = 1

" operator-replace
map [Operator]r <Plug>(operator-replace)

" NERDCommenter
let g:NERDSpaceDelims = 1
let g:NERDMenuMode = 0
let g:NERDCreateDefaultMappings = 0

nmap gA <Plug>NERDCommenterAppend
nmap [Prefix]a <Plug>NERDCommenterAltDelims

" NERDCommenter + operator-user
function! s:setCommentOperator(key, name)
    call operator#user#define(
    \   'comment-' . a:name,
    \   s:SID_PREFIX() . 'doCommentCommand',
    \   'call ' . s:SID_PREFIX() . 'setCommentCommand("' . a:name . '")')
    execute 'map' a:key '<Plug>(operator-comment-' . a:name . ')'
endfunction

function! s:setCommentCommand(command)
    let s:comment_command = a:command
endfunction

function! s:doCommentCommand(motion_wiseness)
    let v = operator#user#visual_command_from_wise_name(a:motion_wiseness)
    execute 'normal! `[' . v . "`]\<Esc>"
    call NERDComment(1, s:comment_command)
endfunction

call s:setCommentOperator('[Operator]c',       'norm')
call s:setCommentOperator('[Operator]<Space>', 'toggle')
call s:setCommentOperator('[Operator]m',       'minimal')
call s:setCommentOperator('[Operator]s',       'sexy')
call s:setCommentOperator('[Operator]i',       'invert')
call s:setCommentOperator('[Operator]y',       'yank')
call s:setCommentOperator('[Operator]l',       'alignLeft')
call s:setCommentOperator('[Operator]b',       'alignBoth')
call s:setCommentOperator('[Operator]n',       'nested')
call s:setCommentOperator('[Operator]u',       'uncomment')

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

imap <silent> <C-l> <Plug>(neocomplcache_snippets_expand)
smap <silent> <C-l> <Plug>(neocomplcache_snippets_expand)
" inoremap <expr> <C-l>     neocomplcache#complete_common_string()
PopupMap <Tab>   "\<C-n>"
PopupMap <S-Tab> "\<C-p>"
PopupMap <CR>    "\<C-y>\<CR>"

" vimshell
augroup vimrc
    autocmd FileType vimshell nunmap <buffer> <C-d>
augroup END

" ku
let g:ku_mrufile_size = 1000

autocmd vimrc FileType ku
\    call ku#default_key_mappings(1)
\|   call s:kuMappings()
function! s:kuMappings()
    inoremap <buffer> <silent> <Tab> <C-n>
    inoremap <buffer> <silent> <S-Tab> <C-p>

    " for Vim
    imap <buffer> <silent> <Esc><Esc> <Plug>(ku-cancel)
    imap <buffer> <silent> <Esc><CR> <Plug>(ku-choose-an-action)

    " for GVim, MacVim
    imap <buffer> <silent> <A-CR> <Plug>(ku-choose-an-action)

    " for MacVim
    imap <buffer> <silent> <D-CR> <Plug>(ku-choose-an-action)

    " Arpeggio
    Arpeggioimap <buffer> <silent> fj <Plug>(ku-cancel)
endfunction

call ku#custom_action('common', 'cd', s:SID_PREFIX() . 'kuCommonActionCd')
function! s:kuCommonActionCd(item)
    if isdirectory(a:item.word)
        execute 'TabpageCD' a:item.word
    else
        execute 'TabpageCD' fnamemodify(a:item.word, ':h')
    endif
endfunction

call ku#custom_action('common', 'tab-Right', s:SID_PREFIX() . 'kuCommonActionTabRight')
function! s:kuCommonActionTabRight(item)
    execute 'tabe' a:item.word
    CD
endfunction

call ku#custom_action('common', 'NERD_tree', s:SID_PREFIX() . 'kuCommonActionNERDTree')
call ku#custom_key('common', 'n', 'NERD_tree')
function! s:kuCommonActionNERDTree(item)
    if isdirectory(a:item.word)
        execute 'NERDTree' a:item.word
    else
        execute 'NERDTree' fnamemodify(a:item.word, ':h')
    endif
endfunction

call ku#custom_prefix('common', '.vim', $HOME . '/.vim')
call ku#custom_prefix('common', '~', $HOME)

CommandMap [Prefix]b  Ku buffer
CommandMap [Prefix]kf Ku file
CommandMap [Prefix]kh Ku history
CommandMap [Prefix]kc Ku mrucommand
CommandMap [Prefix]km Ku mrufile
CommandMap [Prefix]ks Ku source
CommandMap [Prefix]kt Ku tags
CommandMap [Prefix]h  Ku tags/help
Arpeggionnoremap <silent> kb :<C-u>Ku buffer<CR>
Arpeggionnoremap <silent> kf :<C-u>Ku file<CR>
Arpeggionnoremap <silent> km :<C-u>Ku mrufile<CR>
Arpeggionnoremap <silent> ke :<C-u>Ku tags/help<CR>

" NERDTree
let g:NERDTreeWinSize = 21
CommandMap [Prefix]t     NERDTree
CommandMap [Prefix]T     NERDTreeClose
CommandMap [Prefix]<C-t> NERDTree `=expand('%:p:h')`
Arpeggionmap <silent> nt :<C-u>NERDTreeToggle<CR>

" ref
if has('mac')
    let g:ref_refe_cmd = '/opt/local/bin/refe-1_8_7'
    let g:ref_refe_encoding = 'utf-8'
    let g:ref_refe_rsense_cmd = '/usr/local/lib/rsense-0.2/bin/rsense'
    let g:ref_phpmanual_path = expand('~/Documents/phpmanual')
elseif has('win32')
    let g:ref_refe_encoding = 'cp932'
    let g:ref_phpmanual_path = expand('~/Documents/phpmanual')
endif
let g:ref_alc_use_cache = 1

" Lingr-Vim
if has('mac')
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
\    'indentation': '    ',
\    'lang': 'ja'
\}

" Reload Firefox
" Need MozRepl and +ruby
function! ReloadFirefox()
    if has('ruby')
        ruby <<EOF
        require 'net/telnet'
        telnet = Net::Telnet.new({'Host' => 'localhost', 'Port' => 4242})
        telnet.puts('content.location.reload(true)')
        telnet.close
EOF
    elss
        echoerr 'need has("ruby")'
    endif
endfunction
CommandMap [Prefix]rf call ReloadFirefox()

" Reload Safari
" Need RubyOSA and +ruby
function! ReloadSafari()
    if has('ruby') && has('mac')
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
if has('mac')
    command! Here silent execute '!open' expand('%:p:h')
    command! This silent execute '!open %'
    command! -nargs=1 -complete=file Open silent execute '!open' shellescape(expand(<f-args>), 1)
endif

" Utility command for Windows
if has('win32')
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
nmap <Space>q <Plug>(quickrun)


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
    autocmd vimrc BufWritePost .vimrc nested
    \   source $MYVIMRC | source $MYGVIMRC
    autocmd vimrc BufWritePost .gvimrc nested
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
" omnicppcomplete    : http://www.vim.org/scripts/script.php?script_id=1520
" NERD_commenter     : http://www.vim.org/scripts/script.php?script_id=1218
" NERD_tree          : http://www.vim.org/scripts/script.php?script_id=1658
" neocomplcache      : http://github.com/Shougo/neocomplcache
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
" taskpaper          : http://www.vim.org/scripts/script.php?script_id=2027
" textile            : http://www.vim.org/scripts/script.php?script_id=2305
" textobj-comment    : http://gist.github.com/99234
" textobj-indent     : http://www.vim.org/scripts/script.php?script_id=2484
" textobj-user       : http://www.vim.org/scripts/script.php?script_id=2100
" tmux(syntax)       : http://tmux.cvs.sourceforge.net/viewvc/tmux/tmux/examples/tmux.vim
" vimperator         : https://vimperator-labs.googlecode.com/hg/vimperator/contrib/vim/
" vimproc            : http://github.com/Shougo/vimproc
" vimrcbox           : http://github.com/sorah/sandbox/blob/master/vim/vimrcbox.vim
" vimshell           : http://github.com/Shougo/vimshell
" web-indent         : http://www.vim.org/scripts/script.php?script_id=3081
" xoria256           : http://www.vim.org/scripts/script.php?script_id=2140
" zencoding          : http://www.vim.org/scripts/script.php?script_id=2981
