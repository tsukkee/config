" ==================== Settings ==================== "
" Tab character
set tabstop=4 shiftwidth=4 softtabstop=4 " set tab width
set expandtab   " use space instead of tab
set smartindent " use smart indent
set history=100 " number of command history
 
" Input support
set timeoutlen=500             " timeout for key mappings
set backspace=indent,eol,start " to delete everything with backspace key
set formatoptions+=m           " add multibyte support

" Command completion
set wildmenu                   " enhance command completion
set wildmode=list:longest,full " first 'list:lingest' and second 'full'

" Search
set wrapscan   " search wrap around the end of the file
set ignorecase " ignore case search
set smartcase  " override 'ignorecase' if the search pattern contains upper case
set incsearch  " incremental search
set hlsearch   " highlight searched words

" Reading and writing file
set nobackup   " don't backup
set noswapfile " don't use swap file
set autoread   " auto reload when file rewrite other application
set hidden     " allow open other file without saving current file

" Display
set showmatch         " highlight correspods character
set showcmd           " show input command
set number            " show row number
set wrap              " wrap each lines
set list              " show unprintable characters
set listchars=tab:>\  " strings to user in 'list'
set notitle           " don't rewrite title string
set scrolloff=5       " minimal number of screen lines to keep above and below the cursor.
set nolinebreak       " don't auto line break
set textwidth=0       " don't auto line break
set foldmethod=marker " folding
set laststatus=2      " always show statusine
set statusline=%<%F\ %r%h%w%y%{'['.(&fenc!=''?&fenc:&enc).']['.&ff.']'}%=%m%v,%l/%L(%P:%n)
" set statusline=%<%F\ %r%h%w%y%{'['.(&fenc!=''?&fenc:&enc).']['.&ff.']'}%=%{'['.neocomplcache#keyword_complete#caching_percent('').'%]'}%m%v,%l/%L(%P:%n)

" Display cursorline only in active window
" reference: http://nanabit.net/blog/2007/11/03/vim-cursorline/
" augroup CursorLine
    " autocmd! CursorLine
    " autocmd WinLeave * set nocursorcolumn nocursorline
    " autocmd WinEnter,BufRead * set cursorcolumn cursorline
    " autocmd WinLeave * set nocursorline
    " autocmd WinEnter,BufRead * set cursorline
" augroup END

" Generate help tags
if has('mac')
    helptags ~/.vim/doc/
elseif has('win32')
    helptags ~/vimfiles/doc/
endif

" Autodetect charset
" reference: http://www.kawaz.jp/pukiwiki/?vim#cb691f26
if &encoding !=# 'utf-8'
    set encoding=japan
    set fileencoding=japan
endif
if has('iconv')
    let s:enc_euc = 'euc-jp'
    let s:enc_jis = 'iso-2022-jp'
    " iconvがeucJP-msに対応しているかをチェック
    if iconv("\x87\x64\x87\x6a", 'cp932', 'eucjp-ms') ==# "\xad\xc5\xad\xcb"
        let s:enc_euc = 'eucjp-ms'
        let s:enc_jis = 'iso-2022-jp-3'
        " iconvがJISX0213に対応しているかをチェック
    elseif iconv("\x87\x64\x87\x6a", 'cp932', 'euc-jisx0213') ==# "\xad\xc5\xad\xcb"
        let s:enc_euc = 'euc-jisx0213'
        let s:enc_jis = 'iso-2022-jp-3'
    endif
    " fileencodingsを構築
    if &encoding ==# 'utf-8'
        let s:fileencodings_default = &fileencodings
        let &fileencodings = s:enc_jis .','. s:enc_euc .',cp932'
        let &fileencodings = &fileencodings .','. s:fileencodings_default
        unlet s:fileencodings_default
    else
        let &fileencodings = &fileencodings .','. s:enc_jis
        set fileencodings+=utf-8,ucs-2le,ucs-2
        if &encoding =~# '^\(euc-jp\|euc-jisx0213\|eucjp-ms\)$'
            set fileencodings+=cp932
            set fileencodings-=euc-jp
            set fileencodings-=euc-jisx0213
            set fileencodings-=eucjp-ms
            let &encoding = s:enc_euc
            let &fileencoding = s:enc_euc
        else
            let &fileencodings = &fileencodings .','. s:enc_euc
        endif
    endif
    " 定数を処分
    unlet s:enc_euc
    unlet s:enc_jis
endif

" 日本語を含まない場合は fileencoding にencodingを使うようにする
function! AU_ReCheck_FENC()
    if &fileencoding =~# 'iso-2022-jp' && search("[^\x01-\x7e]", 'n') == 0
        let &fileencoding=&encoding
    endif
endfunction
augroup RECHECK_FENC
    autocmd! RECHECK_FENC
    autocmd BufReadPost * call AU_ReCheck_FENC()
augroup END

" File Formats
set ffs=unix,dos,mac

" For multibyte characters, such as □, ○
set ambiwidth=double

" File type
syntax on " syntax coloring
colorscheme xoria256 " colorscheme

" Hightlight Zenkaku space
highlight ZenkakuSpace ctermbg=darkcyan ctermfg=darkcyan
match ZenkakuSpace /　/

" set complete+=k    " to use dictionary for completion
filetype indent on " to use filetype indent
filetype plugin on " to use filetype plugin

" Dictionary
" augroup Dictionary
    " autocmd! Dictionary
    " autocmd FileType javascript setlocal dictionary+=~/.vim/dict/javascript.dict
    " autocmd FileType php setlocal dictionary+=~/.vim/dict/php.dict
" augroup END

" Omni completion
set completeopt+=menuone " Display menu

" Disable input methods
set iminsert=0
set imsearch=0

" ==================== Keybind ==================== "
" Prefix
" reference: http://d.hatena.ne.jp/kuhukuhun/20090213/1234522785
nnoremap [Prefix] <Nop>
nmap <Space> [Prefix]

" Folding
" reference: http://d.hatena.ne.jp/ns9tks/20080318/1205851539
" hold with 'h' if the cursor is on the head of line
nnoremap <expr> h col('.') == 1 && foldlevel(line('.')) > 0 ? 'zc' : 'h'
" expand with 'l' if the cursor on the holded text
nnoremap <expr> l foldclosed(line('.')) != -1 ? 'zo' : 'l'
" hold with 'h' if the cursor is on the head of line in visual mode
vnoremap <expr> h col('.') == 1 && foldlevel(line('.')) > 0 ? 'zcgv' : 'h'
" expand with 'l' if the cursor on the holded text in visual mode
vnoremap <expr> l foldclosed(line('.')) != -1 ? 'zogv' : 'l'

" Move the cursor according to visual line and row
" nnoremap j  gj
" nnoremap k  gk
" nnoremap gj j
" nnoremap gk k
" nnoremap 0  g0
" nnoremap g0 0
" nnoremap $  g$
" nnoremap g$ $

" vnoremap j  gj
" vnoremap k  gk
" vnoremap gj j
" vnoremap gk k
" vnoremap 0  g0
" vnoremap g0 0
" vnoremap $  g$
" vnoremap g$ $

" Use beginning matches on command-line history
cnoremap <C-p> <Up>
cnoremap <C-n> <Down>
cnoremap <Up> <C-p>
cnoremap <Down> <C-n>

" Re-select last yanked word
" reference: 
nnoremap gc `[v`]

" Keybind for completing and selecting popup menu
" reference:
inoremap <silent> <expr> <CR> (pumvisible() ? "\<C-y>" : "") . "\<CR>X\<BS>"
inoremap <silent> <expr> <Tab> pumvisible() ? "\<C-n>" : "\<Tab>"
inoremap <silent> <expr> <S-Tab> pumvisible() ? "\<C-p>" : "\<S-Tab>"
inoremap <silent> <expr> <C-h> (pumvisible() ? "\<C-y>" : "") . "\<C-h>"
inoremap <silent> <expr> <C-n> pumvisible() ? "\<C-n>" : "\<C-x>\<C-u>\<C-p>"

" Delete highlight
nnoremap <silent> gh :nohlsearch<CR>

" Expand path
cnoremap <expr> <C-x> expand('%:p:h') . "/"
cnoremap <expr> <C-z> expand('%:p:r') 

" Copy and paste
" Command-C and Command-V are also available in MacVim
" Reference:
" http://subtech.g.hatena.ne.jp/cho45/20061010/1160459376
" http://vim.wikia.com/wiki/Mac_OS_X_clipboard_sharing
"
" need  'set enc=utf-8' and
" below environment variable for UTF-8 characters
" export __CF_USER_TEXT_ENCODING='0x1F5:0x08000100:14'
"
" Vim(Mac)
if has('mac') && !has('gui')
    nnoremap <silent> [Prefix]y :.w !pbcopy<CR><CR>
    vnoremap <silent> [Prefix]y :w !pbcopy<CR><CR>
    nnoremap <silent> [Prefix]p :r !pbpaste<CR>
    vnoremap <silent> [Prefix]p :r !pbpaste<CR>
" GVim(Mac & Win)
else
    noremap [Prefix]y "+y
    noremap [Prefix]p "+p
endif

" Enable mouse wheel
" In Mac, Only on iTerm.app, disable on Terminal.app
if has('mac')
    set mouse=a
    set ttymouse=xterm2
endif

" Binary (see :h xxd)
" vim -b :edit binary using xxd-format!
" reference: http://jarp.does.notwork.org/diary/200606a.html#200606021
augroup Binary
    autocmd! Binary
    autocmd BufReadPre   *.bin,*.swf let &bin=1
    autocmd BufReadPost  *.bin,*.swf if &bin | silent %!xxd -g 1
    autocmd BufReadPost  *.bin,*.swf set ft=xxd | endif
    autocmd BufWritePre  *.bin,*.swf if &bin | %!xxd -r
    autocmd BufWritePre  *.bin,*.swf endif
    autocmd BufWritePost *.bin,*.swf if &bin | silent %!xxd -g 1
    autocmd BufWritePost *.bin,*.swf set nomod | endif
augroup END

" TabpageCD
" reference: http://ujihisa.nowa.jp/entry/91395f3003
command! -complete=customlist,s:complete_cdpath -nargs=? TabpageCD
\   execute 'cd' fnameescape(<q-args>)
\ | let t:cwd = getcwd()

cnoreabbrev <expr> cd
            \ (getcmdtype() == ":" && getcmdline() ==# "cd")
            \ ? "TabpageCD"
            \ : "cd"
command! CD silent exe "TabpageCD " . expand('%:p:h')

function! s:complete_cdpath(arglead, cmdline, cursorpos)
    return split(globpath(&cdpath,
            \ join(split(a:cmdline, '\s', 1)[1:], ' ') . '*/'),
            \ "\n")
endfunction

augroup TabpageCD
    autocmd! TabpageCD
    autocmd TabEnter *
    \   if !exists('t:cwd')
    \ |   let t:cwd = getcwd()
    \ | endif
    \ | execute 'cd' fnameescape(t:cwd)
augroup END

" Rename
command! -nargs=1 -complete=file Rename saveas <args> | call delete(expand('#'))

" ==================== Plugins settings ==================== "

" ctags
command! CtagsR !ctags -R --tag-relative=no --fields=+iaS --extra=+q

" Ruby
augroup Ruby
    autocmd! Ruby
    autocmd FileType ruby,eruby,yaml setlocal softtabstop=2 shiftwidth=2 tabstop=2
augroup END

" CakePHP
au BufNewFile,BufRead *.thtml setfiletype php
au BufNewFile,BufRead *.ctp setfiletype php

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

" neocomplcache
let g:NeoComplCache_EnableAtStartup = 1
let g:NeoComplCache_SmartCase = 1
let g:NeoComplCache_EnableMFU = 1
let g:NeoComplCache_TagsAutoUpdate = 1
imap <silent> <C-l> <Plug>(neocomplcache_snippets_expand)
nmap <silent> <C-e> <Plug>(neocomplcache_keyword_caching)
imap <expr> <silent> <C-e> pumvisible() ? "\<C-e>" : "\<Plug>(neocomplcache_keyword_caching)"

" ku
function! Ku_my_keymappings()
    inoremap <buffer> <silent> <Tab> <C-n>
    inoremap <buffer> <silent> <S-Tab> <C-p>
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
augroup KuSetting
    autocmd!
    autocmd FileType ku call ku#default_key_mappings(1)
            \ | call Ku_my_keymappings()
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

augroup tex
    autocmd! tex
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

" TOhtml
let html_number_lines = 0
let html_use_css = 1
let use_xhtml = 1
let html_use_encoding = "utf-8"

" Escape
command! HTMLEscape silent exe "rubydo $_ = $_.gsub('&', '&amp;').gsub('>', '&gt;').gsub('<', '&lt;').gsub('\"', '&quot;')"

" NERD_tree
" let g:NERDTreeHijackNetrw = 0
nnoremap <silent> [Prefix]t :<C-u>NERDTree<CR>
nnoremap <silent> [Prefix]T :<C-u>NERDTreeClose<CR>
nnoremap <silent> [Prefix]<C-t> :<C-u>execute 'NERDTree ' . expand('%:p:h')<CR>

" add Tabpaged CD command to NERDTree
augroup NERDTreeCustomCommand
    autocmd! NERDTreeCustomCommand

    autocmd FileType nerdtree command! -buffer NERDTreeTabpageCd
                \ let b:currentDir = NERDTreeGetCurrentPath().getDir().strForCd()
                \ | echo 'TabpageCD to ' . b:currentDir
                \ | execute 'TabpageCD ' . b:currentDir
    autocmd FileType nerdtree nnoremap <buffer> ct :NERDTreeTabpageCd<CR>
augroup END

" Load private information
if filereadable("~/.vimrc.local")
    source ~/.vimrc.local
endif
