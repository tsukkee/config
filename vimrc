" ==================== 基本の設定 ==================== "
" 全般設定
set nocompatible     " 必ず最初に書く
set viminfo+=!       " YankRing用に!を追加
set shellslash       " Windowsでディレクトリパスの区切り文字に / を使えるようにする
set lazyredraw       " マクロなどを実行中は描画を中断
colorscheme xoria256 " カラースキーム

" タブ周り
" tabstopはTab文字を画面上で何文字分に展開するか
" shiftwidthはcindentやautoindent時に挿入されるインデントの幅
" softtabstopはTabキー押し下げ時の挿入される空白の量，0の場合はtabstopと同じ，BSにも影響する
set tabstop=4 shiftwidth=4 softtabstop=0
set expandtab   " タブを空白文字に展開
set smartindent " スマートインデント

" 入力補助
set backspace=indent,eol,start " バックスペースでなんでも消せるように
set formatoptions+=m           " 整形オプション，マルチバイト系を追加

" コマンド補完
set wildmenu                   " コマンド補完を強化
set wildmode=list:longest,full " リスト表示

" 検索関連
set wrapscan   " 最後まで検索したら先頭へ戻る
set ignorecase " 大文字小文字無視
set smartcase  " 大文字ではじめたら大文字小文字無視しない
set incsearch  " インクリメンタルサーチ
set hlsearch   " 検索文字をハイライト

" ファイル関連
set nobackup   " バックアップ取らない
set autoread   " 他で書き換えられたら自動で読み直す
set noswapfile " スワップファイル作らない
set hidden     " 編集中でも他のファイルを開けるようにする

" ヘルプファイル
if has('mac')
    " set runtimepath+=~/.vim/ja/
    helptags ~/.vim/doc/
    " helptags ~/.vim/ja/doc/
elseif has('win32')
    " set runtimepath+=~/vimfiles/ja/
    helptags ~/vimfiles/doc/
    " helptags ~/vimfiles/ja/doc/
endif

"表示関連
set showmatch         " 括弧の対応をハイライト
set showcmd           " 入力中のコマンドを表示
set number            " 行番号表示
set wrap              " 画面幅で折り返す
set list              " 不可視文字表示
set listchars=tab:>\  " 不可視文字の表示方法
set notitle           " タイトル書き換えない
set scrolloff=5       " 行送り
set nolinebreak       " 改行しない
set textwidth=0       " 改行しない

" カレントウィンドウのみラインを引く
augroup cch
    autocmd! cch
    " autocmd WinLeave * set nocursorcolumn nocursorline
    " autocmd WinEnter,BufRead * set cursorcolumn cursorline
    autocmd WinLeave * set nocursorline
    autocmd WinEnter,BufRead * set cursorline
augroup END

" fold関連
set foldmethod=marker
" 行頭でhを押すと折りたたみを閉じる
nnoremap <expr> h col('.') == 1 && foldlevel(line('.')) > 0 ? 'zc' : 'h'
" 折りたたみ上でlを押すと折りたたみを開く
nnoremap <expr> l foldclosed(line('.')) != -1 ? 'zo' : 'l'
" 行頭でhを押すと選択範囲に含まれる折りたたみを閉じる
vnoremap <expr> h col('.') == 1 && foldlevel(line('.')) > 0 ? 'zcgv' : 'h'
" 折りたたみ上でlを押すと選択範囲に含まれる折りたたみを開く
vnoremap <expr> l foldclosed(line('.')) != -1 ? 'zogv' : 'l'

" ステータスライン関連
set laststatus=2
set statusline=%<%F\ %r%h%w%y%{'['.(&fenc!=''?&fenc:&enc).']['.&ff.']'}%=%4v(ASCII=%03.3b,HEX=%02.2B)\ %l/%L(%P)%m

" エンコーディング関連
set ffs=unix,dos,mac " 改行文字

" 文字コードの自動認識
" 適当な文字コード判別
if has('mac')
    set termencoding=utf-8
elseif has('win32')
    set termencoding=cp932
endif
set encoding=utf-8
set fileencodings=iso-2022-jp,utf-8,cp932,euc-jp

" UTF-8の□や○でカーソル位置がずれないようにする
set ambiwidth=double

" ファイルタイプ関連
syntax on " シンタックスカラーリングオン

" 全角スペースをハイライト
highlight ZenkakuSpace ctermbg=darkcyan ctermfg=darkcyan
match ZenkakuSpace /　/

set complete+=k    " 補完に辞書ファイル追加
filetype indent on " ファイルタイプによるインデントを行う
filetype plugin on " ファイルタイプごとのプラグインを使う

" 辞書関連
autocmd FileType javascript :set dictionary+=~/.vim/dict/javascript.dict
autocmd FileType php :set dictionary+=~/.vim/dict/php.dict

" Omni補完関連
set completeopt+=menuone " 補完表示設定

" TabでOmni補完及びポップアップメニューの選択
function! InsertTabWrapper()
    if pumvisible()
        return "\<C-n>"
    else
        return "\<Tab>"
    endif
endfunction
inoremap <Tab> <C-r>=InsertTabWrapper()<CR>

" ポップアップメニューの色変える
highlight Pmenu ctermbg=lightcyan ctermfg=black 
highlight PmenuSel ctermbg=blue ctermfg=black 
highlight PmenuSbar ctermbg=darkgray 
highlight PmenuThumb ctermbg=lightgray

" Kaoriya
if has('kaoriya')
    " imを無効にする
    set iminsert=0
    set imsearch=0
endif

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


" ハイライト消す
nnoremap <silent> gh :nohlsearch<CR>

" expand path
cnoremap <C-x> <C-r>=expand('%:p:h')<CR>/
cnoremap <C-z> <C-r>=expand('%:p:r')<CR> 

" コピペ
" Macの場合は一部でCommand-C，Command-Vも使えたりする
" reference
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

" マウス操作を有効にする
" iTermのみ，Terminal.appでは無効
if has('mac')
    set mouse=a
    set ttymouse=xterm2
endif

" ==================== プラグインの設定 ==================== "
" 基本的に<Space>に割り当てとけばかぶらない？

" ctags
" MacPortsのPrivatePortsで入るのはjexctags
set tags=./tags,./TAGS,tags,TAGS
if has('mac')
    command! CtagsR !jexctags -R --tag-relative=no --fields=+iaS --extra=+q
endif

if has('win32')
    command! CtagsR !ctags -R --tag-relative=no --fields=+iaS --extra=+q
endif

" Rails
autocmd FileType ruby,eruby,yaml set softtabstop=2 shiftwidth=2 tabstop=2
autocmd FileType ruby,eruby let g:rubycomplete_buffer_loading = 1
autocmd FileType ruby,eruby let g:rubycomplete_rails = 1
autocmd FileType ruby,eruby let g:rubycomplete_classes_in_global = 1
let g:rails_level = 4

" refe
" autocmd FileType ruby,eruby nnoremap <silent> K :Refe <cword><CR>

" CakePHP
au BufNewFile,BufRead *.thtml setfiletype php
au BufNewFile,BufRead *.ctp setfiletype php

" .vimperatorrc
au BufNewFile,BufRead .vimperatorrc,_vimperatorrc setfiletype vimperator

" NERD_comments
let NERDSpaceDelims = 1
let NERDShutUp = 1

" NERD_tree
nnoremap <silent> <Space>t :NERDTreeToggle<CR>

" Fuzzy
nnoremap <silent> <Space>fb :FuzzyFinderBuffer<CR>
nnoremap <silent> <Space>ff :FuzzyFinderFile<CR>
nnoremap <silent> <Space>fm :FuzzyFinderMruFile<CR>
nnoremap <silent> <Space>fc :FuzzyFinderMruCmd<CR>
nnoremap <silent> <C-]> :FuzzyFinderTag! <C-r>=expand('<cword>')<CR><CR>

" AutoComplete
" autocmd BufNewFile,BufRead *    :AutoComplPopEnable<CR>
" autocmd BufNewFile,BufRead .tex :AutoComplPopDisable<CR>

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

" Firefoxリロード {{{
" 要MozRepl
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

function! ScrollFirefox(n)
    if has('ruby')
        ruby <<EOF
        require "net/telnet"

        telnet = Net::Telnet.new({
            "Host" => "localhost",
            "Port" => 4242
        })

        telnet.puts("content.scrollBy(0, #{eva("a:n")})")
        telnet.close
EOF
    endif
endfunction
nmap <silent> <D-n> :call ScrollFirefox(100)<CR>
nmap <silent> <D-p> :call ScrollFirefox(-100)<CR>
" }}}

" Safariリロード {{{
" 要RubyOSA
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

" visual studio
if has('win32')
    let g:visual_studio_python_exe = "C:/Python25/python.exe"
endif

" git
let git_diff_spawn_mode = 1
autocmd BufNewFile,BufRead COMMIT_EDITMSG set filetype=git

" TeXShop タイプセット {{{
" 要RubyOSA
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

autocmd FileType tex noremap <buffer> <silent> ,t :<C-u>call TexShop_TypeSet()<CR>
" }}}

" Mac関連
if has('mac')
    command! Here silent exe '!open ' . expand('%:p:h') . '/'
    command! This silent exe '!open %'
    command! Cot  silent exe '!open -a CotEditor %'
endif

" others
command! HTMLEscape silent exe "rubydo $_ = $_.gsub('&', '&amp;').gsub('>', '&gt;').gsub('<', '&lt;').gsub('\"', '&quot;')"

" load private information
source ~/.vimrc_passwords
