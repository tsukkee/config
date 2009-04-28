" ==================== Display setting ==================== "
set title       " 
set linespace=0 " 
set columns=140 " 
set lines=45    " 
set nolinebreak " no line break
set textwidth=0 " no line break

" 先にしとかないとWindowsでTransparencyが有効にならないっぽい
gui

" ==================== Platform setting ==================== "
" MacVim
if has('gui_macvim')
    " set guifont=Osaka-Mono:h14
    " set guifont=mplus-1mn-regular:h14
    colorscheme xoria256
    set transparency=5
    set showtabline=2
    set imdisable
    map <silent> gw :macaction selectNextWindow:<CR>
    map <silent> gW :macaction selectPreviousWindow:<CR>
endif

" GVim(Windows)
if has('win32')
    set guifont=M+2VM+IPAG_circle:h10:cSHIFTJIS
    colorscheme xoria256
    set transparency=240
endif


" ==================== Others ==================== "
" disable im
set iminsert=0
set imsearch=0

if has('win32')
    set guioptions-=T

    autocmd FileType cpp,h setlocal noexpandtab
end

if has('mac')
    set guioptions+=ae
    set guioptions-=T
endif

" highlight系は最後にしないとWindowsで有効にならないっぽい
highlight ZenkakuSpace guibg=#3333ff guifg=#3333ff
match ZenkakuSpace /　/
