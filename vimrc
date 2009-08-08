" ==================== Settings ==================== "
" Define and reset augroup using in vimrc
augroup vimrc-autocmd
    autocmd!
augroup END

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
set wildoptions=tagfile

" Search
set wrapscan   " search wrap around the end of the file
set ignorecase " ignore case search
set smartcase  " override 'ignorecase' if the search pattern contains upper case
set incsearch  " incremental search
set hlsearch   " highlight searched words

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
set list                      " show unprintable characters
set listchars=tab:>\ ,trail:_ " strings to use in 'list'
set ambiwidth=double          " For multibyte characters, such as □, ○

" Status line
set laststatus=2 " always show statusine
set statusline=%<%F\ %r%h%w%y%{'['.(&fenc!=''?&fenc:&enc).']['.&ff.']'}%=%m%v,%l/%L(%P:%n)

" Tab line
set showtabline=2         " always show tab bar
set tabline=%!MyTabLine() " set custom tabline
function! MyTabLine()
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
    let s .= '%=%#TabLineFill#%T' . tabpaged_cwd
    return s
endfunction

" Display cursorline only in active window
" Reference: http://nanabit.net/blog/2007/11/03/vim-cursorline/
augroup vimrc-autocmd
    " autocmd WinLeave * set nocursorcolumn nocursorline
    " autocmd WinEnter,BufRead * set cursorcolumn cursorline
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
    autocmd ColorScheme * call MyHighlight()
    autocmd VimEnter,WinEnter * match ZenkakuSpace /　/
augroup END

function! MyHighlight()
    " Hightlight Zenkaku space
    highlight ZenkakuSpace ctermbg=darkcyan ctermfg=darkcyan guifg=#3333ff guibg=#3333ff

    " Modify color for 'lucius'
    if g:colors_name == 'lucius'
        highlight SpecialKey ctermfg=172 guifg=#ffaa00
    endif
endfunction

syntax on " syntax coloring
" colorscheme
if has('win32') && !has('gui')
    colorscheme desert
else
    colorscheme lucius
endif


" ==================== Keybind ==================== "
" Use AlterCommand and operator-user
call altercmd#load()
call operator#user#load()

" Prefix
" Reference: http://d.hatena.ne.jp/kuhukuhun/20090213/1234522785
nnoremap [Prefix] <Nop>
nmap <Space> [Prefix]

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

" Use beginning matches on command-line history
cnoremap <C-p> <Up>
cnoremap <C-n> <Down>
cnoremap <Up> <C-p>
cnoremap <Down> <C-n>

" Re-select last yanked word
" Reference: kana's vimrc
nnoremap gc `[v`]

" Keybind for completing and selecting popup menu
" Reference: :h neocomplcache
inoremap <silent> <expr> <CR>    pumvisible() ? "\<C-y>\<CR>"  : "\<CR>"
inoremap <silent> <expr> <Tab>   pumvisible() ? "\<C-n>"       : "\<Tab>"
inoremap <silent> <expr> <S-Tab> pumvisible() ? "\<C-p>"       : "\<S-Tab>"
inoremap <silent> <expr> <C-h>   pumvisible() ? "\<C-y>\<C-h>" : "\<C-h>"
inoremap <silent> <expr> <C-n>   pumvisible() ? "\<C-n>"       : "\<C-x>\<C-u>\<C-p>"

" Delete highlight
nnoremap <silent> gh :<C-u>nohlsearch<CR>

" Input path in command mode
cnoremap <expr> <C-x> expand('%:p:h') . "/"
cnoremap <expr> <C-z> expand('%:p:r')

" Copy and paste with fakeclip
" Command-C and Command-V are also available in MacVim
" see :help fakeclip-multibyte-on-mac
nmap <C-y> "*y
vmap <C-y> "*y
nmap <C-p> "*p
vmap <C-p> "*p

if !empty($WINDOW)
    nmap gy <Plug>(fakeclip-screen-y)
    vmap gy <Plug>(fakeclip-screen-y)
    nmap gp <Plug>(fakeclip-screen-p)
    vmap gp <Plug>(fakeclip-screen-p)
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
command! -complete=customlist,s:complete_cdpath -nargs=? TabpageCD
\   execute 'cd' fnameescape(<q-args>)
\|  let t:cwd = getcwd()

function! s:complete_cdpath(arglead, cmdline, cursorpos)
    return split(globpath(&cdpath,
            \ join(split(a:cmdline, '\s', 1)[1:], ' ') . '*/'),
            \ "\n")
endfunction

AlterCommand cd TabpageCD

command! CD silent exe "TabpageCD " . expand('%:p:h')

augroup vimrc-autocmd
    autocmd VimEnter,TabEnter *
    \   if !exists('t:cwd')
    \|    let t:cwd = getcwd()
    \|  endif
    \|  execute 'cd' fnameescape(t:cwd)
augroup END

" Rename
command! -nargs=1 -complete=file Rename saveas <args> | call delete(expand('#'))

" myoperator {{{
" DefineOperator _ Op_replace_paste call SaveReg()
" let s:lastreg = ''
" function! SaveReg()
    " let s:lastreg = v:register
" endfunction
" function! Op_replace_paste(motion_wiseness)
    " if a:motion_wiseness == "line"
        " let op = "V"
    " elseif a:motion_wiseness == "block"
        " let op = "\<C-v>"
    " else
        " let op = "v"
    " endif

    " let reg = empty(s:lastreg) ? '' : '"' . s:lastreg
    " let paste = (getpos("`]") == getpos('.')) ? 'p' : 'P'

    " exe 'normal! `["_d' . op . '`]`[' . reg . paste
" endfunction
" }}}


" ==================== Plugins settings ==================== "

" ctags
command! CtagsR !ctags -R

" Ruby
augroup vimrc-autocmd
    autocmd FileType ruby,eruby,yaml setlocal softtabstop=2 shiftwidth=2 tabstop=2
augroup END

" less
autocmd BufNewFile,BufRead *.less setfiletype css

" CakePHP
autocmd BufNewFile,BufRead *.thtml setfiletype php
autocmd BufNewFile,BufRead *.ctp setfiletype php

" gist
let g:gist_clip_command = 'pbcopy'
let g:gist_detect_filetype = 1
let g:gist_open_browser_after_post = 1

" smartword
map W <Plug>(smartword-w)
map B <Plug>(smartword-b)
map E <Plug>(smartword-e)
map gE <Plug>(smartword-ge)

" NERD_comments
let NERDSpaceDelims = 1
let NERDShutUp = 1

" neocomplcache (see :h neocomplcache)
let g:NeoComplCache_EnableAtStartup = 1
let g:NeoComplCache_SmartCase = 1
let g:NeoComplCache_EnableMFU = 1
let g:NeoComplCache_TagsAutoUpdate = 1
imap <silent> <C-l> <Plug>(neocomplcache_snippets_expand)
imap <silent> <C-@> <Plug>(neocomplcache_keyword_caching)
nmap <silent> <C-@> <Plug>(neocomplcache_keyword_caching)
inoremap <expr> <C-x><C-f> neocomplcache#manual_filename_complete()
inoremap <expr> <C-y>      pumvisible() ? neocomplcache#close_popup() : "\<C-y>"
inoremap <expr> <C-e>      pumvisible() ? neocomplcache#cancel_popup() : "\<C-e>"

" ku
function! Ku_my_keymappings()
    inoremap <buffer> <silent> <Tab> <C-n>
    inoremap <buffer> <silent> <S-Tab> <C-p>

    " for Vim
    imap <buffer> <silent> <Esc><Esc> <Plug>(ku-cancel)
    nmap <buffer> <silent> <Esc><Esc> <Plug>(ku-cancel)
    imap <buffer> <silent> <Esc><Cr> <Plug>(ku-choose-an-action)
    nmap <buffer> <silent> <Esc><Cr> <Plug>(ku-choose-an-action)

    " for GVim, MacVim
    imap <buffer> <silent> <A-Esc> <Plug>(ku-cancel)
    nmap <buffer> <silent> <A-Esc> <Plug>(ku-cancel)
    imap <buffer> <silent> <A-Cr> <Plug>(ku-choose-an-action)
    nmap <buffer> <silent> <A-Cr> <Plug>(ku-choose-an-action)
endfunction
augroup vimrc-autocmd
    autocmd FileType ku
    \    call ku#default_key_mappings(1)
    \|   call Ku_my_keymappings()
augroup END

function! Ku_common_action_my_cd(item)
    if isdirectory(a:item.word)
        execute 'TabpageCD' a:item.word
    else
        execute 'TabpageCD' fnamemodify(a:item.word, ':h')
    endif
endfunction
call ku#custom_action('common', 'cd', 'Ku_common_action_my_cd')

call ku#custom_prefix('common', '.vim', $HOME.'/.vim')
call ku#custom_prefix('common', '~', $HOME)

nnoremap <silent> [Prefix]b :<C-u>Ku buffer<Cr>
nnoremap <silent> [Prefix]kf :<C-u>Ku file<Cr>
nnoremap <silent> [Prefix]kh :<C-u>Ku history<Cr>
nnoremap <silent> [Prefix]kc :<C-u>Ku mrucommand<Cr>
nnoremap <silent> [Prefix]km :<C-u>Ku mrufile<Cr>
nnoremap <silent> [Prefix]kt :<C-u>Ku tags<Cr>
nnoremap <silent> [Prefix]h :<C-u>Ku tags/help<Cr>

" NERD_tree
" let g:NERDTreeHijackNetrw = 0
nnoremap <silent> [Prefix]t :<C-u>NERDTree<CR>
nnoremap <silent> [Prefix]T :<C-u>NERDTreeClose<CR>
nnoremap <silent> [Prefix]<C-t> :<C-u>execute 'NERDTree ' . expand('%:p:h')<CR>

" add Tabpaged CD command to NERDTree
augroup vimrc-autocmd
    autocmd FileType nerdtree command! -buffer NERDTreeTabpageCd
    \   let b:currentDir = NERDTreeGetCurrentPath().getDir().strForCd()
    \|  echo 'TabpageCD to ' . b:currentDir
    \|  execute 'TabpageCD ' . b:currentDir
    autocmd FileType nerdtree nnoremap <buffer> ct :NERDTreeTabpageCd<CR>
augroup END

" Reload Firefox {{{
" Need MozRepl and +ruby
function! ReloadFirefox()
    if has('ruby')
        ruby <<EOF
        require "net/telnet"

        telnet = Net::Telnet.new({
            "Host" => "localhost",
            "Port" => 4242
        })

        telnet.puts("content.location.reload(true)")
        telnet.close
EOF
    else
        echoerr 'need has("ruby")'
    endif
endfunction
nnoremap <silent> [Prefix]rf :<C-u>call ReloadFirefox()<CR>
" }}}

" Reload Safari {{{
" Need RubyOSA and +ruby
function! ReloadSafari()
    if has('ruby') && has('mac')
        ruby <<EOF
        require 'rubygems'
        require 'rbosa'

        safari = OSA.app("Safari")
        safari.do_javascript("location.reload(true)", safari.documents[0])
EOF
    else
        echoerr 'need has("mac") and has("ruby")'
    endif
endfunction
nnoremap <silent> [Prefix]rs :<C-u>call ReloadSafari()<CR>
" }}}

" TeXShop {{{
" Need RubyOSA and +ruby
function! TexShop_TypeSet()
    if has('ruby') && has('mac')
        ruby <<EOF
        unless $texshop
            require 'rubygems'
            require 'rbosa'

            $texshop = OSA.app("TeXShop")
        end
        $texshop.documents.each {|d|
            $texshop.typesetinteractive(d)
        }
EOF
    else
        echoerr 'need has("mac") and has("ruby")'
    endif
endfunction

augroup vimrc-autocmd
    autocmd FileType plaintex noremap <buffer> <silent> [Prefix]pt :<C-u>call TexShop_TypeSet()<CR>
    autocmd FileType plaintex setlocal spell spelllang=en_us
augroup END
" }}}

" Utility command for Mac
if has('mac')
    command! Here silent exe '!open ' . expand('%:p:h') . '/'
    command! This silent exe '!open %'
    command! Cot  silent exe '!open -a CotEditor %'
endif

" Utility command for Windows
if has('win32')
    command! Here silent exe "!start explorer " . expand('%:p:h') . '/'
endif

" TOhtml
let html_number_lines = 0
let html_use_css = 1
let use_xhtml = 1
let html_use_encoding = "utf-8"

" Escape
if has('ruby')
    command! HTMLEscape silent
    \   exe "rubydo $_ = $_.gsub('&', '&amp;').gsub('>', '&gt;').gsub('<', '&lt;').gsub('\"', '&quot;')"
endif

" Load private information
if filereadable($HOME . "/.vimrc.local")
    source ~/.vimrc.local
endif
