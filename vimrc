" ==================== Settings ==================== "
" Define and reset augroup using in vimrc
augroup vimrc-autocmd
    autocmd!
augroup END

" get SID prefix of .vimrc
function! s:SID_PREFIX()
    return matchstr(expand('<sfile>'), '<SNR>\d\+_')
endfunction

" Generate help tags
if has('mac')
    helptags ~/.vim/doc/
elseif has('win32')
    helptags ~/vimfiles/doc/
endif

" Tab
set tabstop=4 shiftwidth=4 softtabstop=4 " set tab width
set expandtab   " use space instead of tab
set smartindent " use smart indent
set history=100 " number of command history

" Input support
set timeoutlen=500             " timeout for key mappings
set backspace=indent,eol,start " to delete everything with backspace key
set formatoptions+=m           " add multibyte support
set iskeyword+=-               " add keyword to '-'
set nolinebreak                " don't auto line break
set textwidth=0                " don't auto line break
set iminsert=0                 " Disable input methods in insert mode
set imsearch=0                 " Disable input methods in search mode

" Command completion
set wildmenu                   " enhance command completion
set wildmode=list:longest,full " first 'list:lingest' and second 'full'

" Search
set wrapscan   " search wrap around the end of the file
set ignorecase " ignore case search
set smartcase  " override 'ignorecase' if the search pattern contains upper case
set incsearch  " incremental search
set hlsearch   " highlight searched words
nohlsearch     " avoid to highlight when reload vimrc

" Reading and writing file
set directory-=. " don't save tmp swap file in current directory
set autoread     " auto reload when file rewrite other application
set hidden       " allow open other file without saving current file
set tags=./tags; " search tag file recursively (see :h file-searching)

" Display
set notitle                   " don't rewrite title string
set showmatch                 " highlight correspods character
set showcmd                   " show input command
set number                    " show row number
set wrap                      " wrap each lines
set scrolloff=5               " minimal number of screen lines to keep above and below the cursor.
set foldmethod=marker         " folding
set foldcolumn=3              " display fold
set list                      " show unprintable characters
set listchars=tab:>\ ,trail:_ " strings to use in 'list'
set ambiwidth=double          " For multibyte characters, such as □, ○

" Status line
set laststatus=2 " always show statusine
set statusline=%<%F\ %r%h%w%y%{'['.(&fenc!=''?&fenc:&enc).']['.&ff.']'}%=%m%v,%l/%L(%P:%n)

" Tab line
set showtabline=2                                  " always show tab bar
let &tabline = '%!' . s:SID_PREFIX() . 'tabline()' " set custom tabline
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
    let s .= '%#TabLineFill#%T%=' . tabpaged_cwd
    return s
endfunction

" Display cursorline only in active window
" Reference: http://nanabit.net/blog/2007/11/03/vim-cursorline/
augroup vimrc-autocmd
    autocmd WinLeave * set nocursorline
    autocmd WinEnter,BufRead * set cursorline
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
augroup vimrc-autocmd
    autocmd BufReadPost *
    \   if &fileencoding =~# 'iso-2022-jp' && search("[^\x01-\x7e]", 'n') == 0
    \|      let &fileencoding=&encoding
    \|  endif
augroup END

" line feed character
set ffs=dos,unix,mac

" use ff=unix for new file
augroup vimrc-autocmd
    autocmd BufNewFile * set ff=unix
augroup END

" Omni completion
set completeopt+=menuone " Display menu

" File type settings
filetype indent on " to use filetype indent
filetype plugin on " to use filetype plugin


" ==================== Hightlight ==================== "
augroup vimrc-autocmd
    autocmd ColorScheme * call s:onColorScheme()
    autocmd VimEnter,WinEnter * match ZenkakuSpace /　/
augroup END
function! s:onColorScheme()
    " Hightlight Zenkaku space
    hi ZenkakuSpace ctermbg=77 guibg=#5fdf5f

    " Modify colorscheme
    if !exists('g:colors_name')
        return
    endif

    if g:colors_name == 'xoria256'
        highlight CursorLine cterm=none gui=none
    endif

    if g:colors_name == 'lucius'
        highlight SpecialKey ctermfg=172 guifg=#ffaa00
    endif

    if g:colors_name == 'zenburn'
        highlight Function    ctermfg=230
        highlight Function    guifg=#cdcd8f
        highlight Search      ctermfg=229   ctermbg=240
        highlight Search      guifg=#eded8f guibg=#6c8f6c
        highlight TabLine     ctermfg=244   ctermbg=233   cterm=none
        highlight TabLine     guifg=#9a9a9a guibg=#1c1c1b gui=bold
        highlight TabLineFill ctermfg=187   ctermbg=233   cterm=none
        highlight TabLineFill guifg=#cfcfaf guibg=#181818 gui=none
        highlight TabLineSel  ctermfg=230   ctermbg=233   cterm=none
        highlight TabLineSel  guifg=#b6bf98 guibg=#181818 gui=bold
        highlight Comment                                 gui=none
        highlight CursorLine                              gui=none
    endif
endfunction

syntax on " syntax coloring

" colorscheme
if has('win32') && !has('gui')
    colorscheme desert
else
    " let g:zenburn_high_Contrast = 0
    colorscheme xoria256
endif


" ==================== Keybind and commands ==================== "
" Use AlterCommand and Arpeggio
call altercmd#load()
call arpeggio#load()

" Prefix
" Reference: http://d.hatena.ne.jp/kuhukuhun/20090213/1234522785
nnoremap [Prefix] <Nop>
nmap <Space> [Prefix]
noremap [Operator] <Nop>
map , [Operator]

" Mapping command
command! -nargs=+ NExchangeMap call s:exchangeMap('n', <f-args>)
command! -nargs=+ CExchangeMap call s:exchangeMap('c', <f-args>)
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

" Use display line
NExchangeMap j gj
NExchangeMap k gk
NExchangeMap $ g$
NExchangeMap 0 g0

" Use beginning matches on command-line history
CExchangeMap <C-p> <Up>
CExchangeMap <C-n> <Down>

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

" Input path in command mode
cnoremap <expr> <C-x> expand('%:p:h') . "/"
cnoremap <expr> <C-z> expand('%:p:r')

" Copy and paste with fakeclip
" Command-C and Command-V are also available in MacVim
" see :help fakeclip-multibyte-on-mac
map <C-y> "*y
map <C-p> "*p
if !empty($WINDOW)
    map gy <Plug>(fakeclip-screen-y)
    map gp <Plug>(fakeclip-screen-p)
endif

" Enable mouse wheel
" In Mac, Only on iTerm.app, disable on Terminal.app
if has('mac')
    set mouse=a
    set ttymouse=xterm2
endif

" Binary (see :h xxd)
" vim -b :edit binary using xxd-format!
" Reference: http://jarp.does.notwork.org/diary/200606a.html#200606021
augroup vimrc-autocmd
    autocmd BufReadPre   *.bin,*.swf let &bin=1
    autocmd BufReadPost  *.bin,*.swf if &bin | silent %!xxd -g 1
    autocmd BufReadPost  *.bin,*.swf set ft=xxd | endif
    autocmd BufWritePre  *.bin,*.swf if &bin | %!xxd -r
    autocmd BufWritePre  *.bin,*.swf endif
    autocmd BufWritePost *.bin,*.swf if &bin | silent %!xxd -g 1
    autocmd BufWritePost *.bin,*.swf set nomod | endif
augroup END

" TabpageCD
" Reference: kana's vimrc
command! -complete=file -nargs=? TabpageCD
\   execute 'cd' fnameescape(<q-args>)
\|  let t:cwd = getcwd()

AlterCommand cd TabpageCD
command! CD silent execute 'TabpageCD' expand('%:p:h')

augroup vimrc-autocmd
    autocmd VimEnter,TabEnter *
    \   if !exists('t:cwd')
    \|    let t:cwd = getcwd()
    \|  endif
    \|  execute 'cd' fnameescape(t:cwd)
augroup END

" Go to alternate tab
if !exists('g:AlternateTabNumber')
    let g:AlternateTabNumber = 1
endif

command! GoToAlternateTab silent execute 'tabnext' g:AlternateTabNumber
CommandMap g<C-^> GoToAlternateTab

augroup vimrc-autocmd
    autocmd TabLeave * let g:AlternateTabNumber = tabpagenr()
augroup END

" Rename
command! -nargs=1 -bang -complete=file Rename saveas<bang> <args> | call delete(expand('#'))

" ctags
command! CtagsR !ctags -R


" ==================== Plugins settings ==================== "
" FileType
augroup vimrc-autocmd
    " Ruby
    autocmd FileType ruby,eruby,yaml setlocal softtabstop=2 shiftwidth=2 tabstop=2

    " less
    autocmd BufNewFile,BufRead *.less setfiletype css

    " CakePHP
    autocmd BufNewFile,BufRead *.thtml setfiletype php
    autocmd BufNewFile,BufRead *.ctp setfiletype php
augroup END

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
call s:setCommentOperator('[Operator]<Scace>', 'toggle')
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
let g:NeoComplCache_EnableAtStartup = 1
let g:NeoComplCache_PartialCompletionStartLength = 2
let g:NeoComplCache_MinKeywordLength = 2
let g:NeoComplCache_MinSyntaxLength = 2
let g:NeoComplCache_SmartCase = 1
let g:NeoComplCache_EnableMFU = 1
let g:NeoComplCache_EnableQuickMatch = 0
let g:NeoComplCache_TagsAutoUpdate = 1
let g:NeoComplCache_EnableUnderbarCompletion = 1
let g:NeoComplCache_EnableCamelCaseCompletion = 1
if !exists('g:NeoComplCache_SameFileTypeLists')
    let g:NeoComplCache_SameFileTypeLists = {}
endif
let g:NeoComplCache_SameFileTypeLists['vim'] = 'help'
imap <silent> <C-l> <Plug>(neocomplcache_snippets_expand)
PopupMap <C-y>   neocomplcache#close_popup()
PopupMap <C-e>   neocomplcache#cancel_popup()
PopupMap <CR>    neocomplcache#close_popup() . "\<CR>"
PopupMap <Tab>   "\<C-n>"
PopupMap <S-Tab> "\<C-p>"
PopupMap <C-h>   neocomplcache#cancel_popup() . "\<C-h>"

" ku
augroup vimrc-autocmd
    autocmd FileType ku
    \    call ku#default_key_mappings(1)
    \|   call s:kuMappings()
augroup END
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
" Arpeggionmap kb :<C-u>Ku buffer<CR>
" Arpeggionmap km :<C-u>Ku mrufile<CR>

" NERDTree
let g:NERDTreeWinSize = 25
CommandMap [Prefix]t     NERDTree
CommandMap [Prefix]T     NERDTreeClose
CommandMap [Prefix]<C-t> execute 'NERDTree' expand('%:p:h')
" Arpeggionmap nt :<C-u>NERDTreeToggle<CR>

" add Tabpaged CD command to NERDTree
augroup vimrc-autocmd
    autocmd FileType nerdtree command! -buffer NERDTreeTabpageCd
    \   let b:currentDir = NERDTreeGetCurrentPath().getDir().strForCd()
    \|  echo 'TabpageCD to ' . b:currentDir
    \|  execute 'TabpageCD' b:currentDir
    autocmd FileType nerdtree CommandMap! ct NERDTreeTabpageCd
augroup END

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
endif

" Utility command for Windows
if has('win32')
    command! Here silent execute '!explorer' expand('%:p:h')
endif

" TOhtml
let html_number_lines = 0
let html_use_css = 1
let use_xhtml = 1
let html_use_encoding = 'utf-8'

" Load private information
if filereadable($HOME . '/.vimrc.local')
    source ~/.vimrc.local
endif
