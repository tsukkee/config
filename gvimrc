" ==================== 画面表示設定 ==================== "
set title       " タイトル表示
set linespace=0 " 行間
set columns=125 " 幅
set lines=50    " 高さ
set nolinebreak " 改行しない
set textwidth=0 " 改行しない

" 先にしとかないとWindowsでTransparencyが有効にならないっぽい
gui

" ==================== フォント設定 ==================== "
" 普通のMac版GVim
if has('gui_mac')
    set guifont=Osaka-Mono:h14
    " set guifont=mplus-1mn-regular:h14
    set transparency=240
endif

" 実験版MacVim
if has('gui_macvim')
    set guifont=Osaka-Mono:h14
    " set guifont=mplus-1mn-regular:h14
    set transparency=5
    set showtabline=2
    set imdisable
    map <silent> gw :macaction selectNextWindow:<CR>
    map <silent> gW :macaction selectPreviousWindow:<CR>
endif

" Windows版GVim
if has('win32')
    set guifont=M+2VM+IPAG_circle:h10:cSHIFTJIS
    colorscheme xoria256
    set transparency=240
endif


" ==================== その他 ==================== "
" imを無効にする
set iminsert=0
set imsearch=0

if has('win32')
    au BufNewFile,BufRead *.cpp,*.h set noexpandtab
end

if has('mac')
    set guioptions+=ae
    set guioptions-=T
endif

" highlight系は最後にしないとWindowsで有効にならないっぽい
highlight ZenkakuSpace guibg=#3333ff guifg=#3333ff
match ZenkakuSpace /　/

" ポップアップメニューの色変える
highlight Pmenu guibg=#3333ff guifg=#000000
highlight PmenuSel guibg=#0000dd guifg=#000000
highlight PmenuSbar guibg=#333333
highlight PmenuThumb guibg=#aaaaaa
