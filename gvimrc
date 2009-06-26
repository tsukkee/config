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

" This must be after 'columns' and 'lines',
" and before 'transparency'
gui

" ==================== Platform setting ==================== "
" MacVim
if has('gui_macvim')
    " set guifont=Osaka-Mono:h14
    " set guifont=mplus-1mn-regular:h14
    set transparency=5 " (opaque) 0-100 (transparent)
    set guioptions-=e  " don't use gui tab apperance
    set guioptions-=T  " hide toolbar

    noremap <silent> gw :macaction selectNextWindow:<CR>
    noremap <silent> gW :macaction selectPreviousWindow:<CR>

    if has('kaoriya')
        set ambiwidth=auto
        set fencs=guess
    endif
endif

" GVim(Windows)
if has('win32')
    set guifont=M+2VM+IPAG_circle:h10:cSHIFTJIS
    set transparency=240 " (opaque) 255 - 0 (transparent)
    set guioptions-=e    " don't use gui tab apperance
    set guioptions-=T    " hide toolbar
    set guioptions-=m    " hide menubar

    autocmd FileType cpp,h setlocal noexpandtab

    if has('kaoriya')
        set ambiwidth=auto
        set fencs=guess
    endif
endif

