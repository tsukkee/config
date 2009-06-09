" Before use this vimrc, it's better to rename vimrc and gvimrc
" of Kaoriya so that gvim don't read these.

" ==================== Display setting ==================== "
" override vimrc settings
set title

" re-set vimrc settings (this setting is rewrote anywhere)
set textwidth=0

" gvim settings
set linespace=1
set columns=140
set lines=45
set showtabline=2

" This must be after 'columns' and 'lines',
" and before 'transparency' and 'heighlight'
gui

highlight ZenkakuSpace guibg=#3333ff guifg=#3333ff
match ZenkakuSpace /　/

" ==================== Platform setting ==================== "
" MacVim
if has('gui_macvim')
    " set guifont=Osaka-Mono:h14
    " set guifont=mplus-1mn-regular:h14
    set transparency=5 " (opaque) 0-100 (transparent)
    set guioptions+=e " use gui tab apperance
    set guioptions-=T " hide toolbar

    noremap <silent> gw :macaction selectNextWindow:<CR>
    noremap <silent> gW :macaction selectPreviousWindow:<CR>
endif

" GVim(Windows)
if has('win32')
    set guifont=M+2VM+IPAG_circle:h10:cSHIFTJIS
    set transparency=240 " (opaque) 255 - 0 (transparent)
    set guioptions-=T " hide toolbar

    autocmd FileType cpp,h setlocal noexpandtab
endif

