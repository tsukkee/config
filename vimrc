" ==================== Basic settings ==================== "
" Tab character
set tabstop=4 shiftwidth=4 softtabstop=0 " set tab width
set expandtab   " use space instead of tab
set smartindent " use smart indent

" Input support
set timeoutlen=500             " timeout for key mappings
set backspace=indent,eol,start " to delete everything with backspace key
set formatoptions+=m           " add multibyte support

" Command completion
set wildmenu                   " enhance command completion
set wildmode=list:longest,full " first 'list:lingest' and second 'full'

" Searching
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

" generate help tags
if has('mac')
    helptags ~/.vim/doc/
elseif has('win32')
    helptags ~/vimfiles/doc/
endif

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

" display cursorline only in active window
" reference: http://nanabit.net/blog/2007/11/03/vim-cursorline/
augroup CursorLine
    autocmd! CursorLine
    " autocmd WinLeave * set nocursorcolumn nocursorline
    " autocmd WinEnter,BufRead * set cursorcolumn cursorline
    autocmd WinLeave * set nocursorline
    autocmd WinEnter,BufRead * set cursorline
augroup END

" Folding
" reference: http://d.hatena.ne.jp/ns9tks/20080318/1205851539
set foldmethod=marker
" 行頭でhを押すと折りたたみを閉じる
nnoremap <expr> h col('.') == 1 && foldlevel(line('.')) > 0 ? 'zc' : 'h'
" 折りたたみ上でlを押すと折りたたみを開く
nnoremap <expr> l foldclosed(line('.')) != -1 ? 'zo' : 'l'
" 行頭でhを押すと選択範囲に含まれる折りたたみを閉じる
vnoremap <expr> h col('.') == 1 && foldlevel(line('.')) > 0 ? 'zcgv' : 'h'
" 折りたたみ上でlを押すと選択範囲に含まれる折りたたみを開く
vnoremap <expr> l foldclosed(line('.')) != -1 ? 'zogv' : 'l'

" Status line
set laststatus=2
set statusline=%<%F\ %r%h%w%y%{'['.(&fenc!=''?&fenc:&enc).']['.&ff.']'}%=%m%v,%l/%L(%P:%n)

" autodetect charset
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

" 日本語を含まない場合は fileencoding に utf-8 を使うようにする
function! AU_ReCheck_FENC()
if &fileencoding =~# 'iso-2022-jp' && search("[^\x01-\x7e]", 'n') == 0
  " let &fileencoding=&encoding
  set fenc=utf-8
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

set complete+=k    " to use dictionary for completion
filetype indent on " to use filetype indent
filetype plugin on " to use filetype plugin

" Dictionary
" augroup Dictionary
    " autocmd! Dictionary
    " autocmd FileType javascript setlocal dictionary+=~/.vim/dict/javascript.dict
    " autocmd FileType php setlocal dictionary+=~/.vim/dict/php.dict
" augroup END

" Omni completion
set completeopt+=menuone " 補完表示設定

" TabでOmni補完及びポップアップメニューの選択
inoremap <silent> <expr> <CR> (pumvisible() ? "\<C-e>" : "") . "\<CR>"
inoremap <silent> <expr> <Tab> pumvisible() ? "\<C-y>" : "\<Tab>"

" ポップアップメニューの色変える
" highlight Pmenu ctermbg=lightcyan ctermfg=black 
" highlight PmenuSel ctermbg=blue ctermfg=white 
" highlight PmenuSbar ctermbg=darkgray 
" highlight PmenuThumb ctermbg=lightgray

" Disable input methods
set iminsert=0
set imsearch=0

" ==================== キーマップ ==================== "
" 表示行単位で移動
nnoremap j  gj
nnoremap k  gk
nnoremap gj j
nnoremap gk k
nnoremap 0  g0
nnoremap g0 0
nnoremap $  g$
nnoremap g$ $

vnoremap j  gj
vnoremap k  gk
vnoremap gj j
vnoremap gk k
vnoremap 0  g0
vnoremap g0 0
vnoremap $  g$
vnoremap g$ $


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
    nnoremap <silent> <Space>y :.w !pbcopy<CR><CR>
    vnoremap <silent> <Space>y :w !pbcopy<CR><CR>
    nnoremap <silent> <Space>p :r !pbpaste<CR>
    vnoremap <silent> <Space>p :r !pbpaste<CR>
" GVim(Mac & Win)
else
    noremap <Space>y "+y
    noremap <Space>p "+p
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

cabbrev cd TabpageCD
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


" ==================== プラグインの設定 ==================== "
" reference: http://d.hatena.ne.jp/kuhukuhun/20090213/1234522785
nnoremap [Prefix] <Nop>
nmap <Space> [Prefix]

" ctags
command! CtagsR !ctags -R --tag-relative=no --fields=+iaS --extra=+q

" Ruby
augroup Ruby
    autocmd! Ruby
    autocmd FileType ruby,eruby,yaml setlocal softtabstop=2 shiftwidth=2 tabstop=2
augroup END

" git
let git_diff_spawn_mode = 1
augroup Git
    autocmd! Git
    autocmd BufNewFile,BufRead COMMIT_EDITMSG setlocal filetype=git
augroup END

" CakePHP
au BufNewFile,BufRead *.thtml setfiletype php
au BufNewFile,BufRead *.ctp setfiletype php

" smartword
map W <Plug>(smartword-w)
map B <Plug>(smartword-b)
map E <Plug>(smartword-e)
map gE <Plug>(smartword-ge)

" NERD_comments
let NERDSpaceDelims = 1
let NERDShutUp = 1

" AutoComplPop {{{
let g:AutoComplPop_NotEnableAtStartup = 1
let g:AutoComplPop_IgnoreCaseOption = 0
let g:AutoComplPop_CompleteoptPreview = 1
let g:AutoComplPop_Behavior = {
    \   'javascript' : [
    \       {
    \           'command'  : "\<C-n>",
    \           'pattern'  : '\k\k$',
    \           'excluded' : '^$',
    \           'repeat'   : 0,
    \       },
    \       {
    \           'command'  : "\<C-x>\<C-f>",
    \           'pattern'  : (has('win32') || has('win64') ? '\f[/\\]\f*$' : '\f[/]\f*$'),
    \           'excluded' : '[*/\\][/\\]\f*$\|[^[:print:]]\f*$',
    \           'repeat'   : 1,
    \       },
    \       {
    \           'command'  : "\<C-x>\<C-o>",
    \           'pattern'  : '\k\.$',
    \           'excluded' : '^$',
    \           'repeat'   : 0,
    \       },
    \   ],
    \   }
"}}}

" neocomplcache
let g:NeoComplCache_EnableAtStartup = 1
let g:NeoComplCache_SmartCase = 1
let g:NeoComplCache_EnableMFU = 1

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
    endif
endfunction
nnoremap <silent> <Space>rf :<C-u>call ReloadFirefox()<CR>
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
    endif
endfunction
nnoremap <silent> <Space>rs :<C-u>call ReloadSafari()<CR>
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
    endif
endfunction

augroup tex
    autocmd! tex
    autocmd FileType tex noremap <buffer> <silent> ,t :<C-u>call TexShop_TypeSet()<CR>
    autocmd FileType tex setlocal spell spelllang=en_us
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

" Others
command! HTMLEscape silent exe "rubydo $_ = $_.gsub('&', '&amp;').gsub('>', '&gt;').gsub('<', '&lt;').gsub('\"', '&quot;')"

" settings for arpeggio.vim
call arpeggio#load()

" NERD_tree
Arpeggionnoremap <silent> tn :NERDTreeToggle<CR>
nnoremap <silent> [Prefix]t :NERDTreeToggle<CR>

augroup NERDTreeCustomCommand
    autocmd! NERDTreeCustomCommand

    autocmd FileType nerdtree command! -buffer NERDTreeTabpageCd
                \ let b:currentDir = NERDTreeGetCurrentPath().getDir().strForCd()
                \ | echo 'TabpageCD to ' . b:currentDir
                \ | execute 'TabpageCD ' . b:currentDir
    autocmd FileType nerdtree nnoremap <buffer> ct :NERDTreeTabpageCd<CR>
augroup END

" FuzzyFinder
Arpeggionnoremap <silent> fn :FuzzyFinderBuffer<CR>
Arpeggionnoremap <silent> fm :FuzzyFinderMruFile<CR>
nnoremap <silent> [Prefix]b :FuzzyFinderBuffer<CR>
nnoremap <silent> [Prefix]m :FuzzyFinderMruFile<CR>

" Reload brawser
if has('ruby')
    Arpeggionnoremap <silent> ru :<C-u>call ReloadFirefox()<CR>
    nnoremap <silent> [Prefix]f :<C-u>call ReloadFirefox()<CR>
endif
if has('mac')
    Arpeggionnoremap <silent> ri :<C-u>call ReloadSafari()<CR>
    nnoremap <silent> [Prefix]s :<C-u>call ReloadSafari()<CR>
endif

" Load private information
if filereadable("~/.vimrc.local")
    source ~/.vimrc.local
endif
