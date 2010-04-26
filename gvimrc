" Before use this vimrc, it's better to rename vimrc and gvimrc
" of Kaoriya so that gvim don't read these.

" ==================== Display setting ==================== "
" override vimrc settings
set title

" gvim settings
set linespace=1
set columns=138
set lines=38


" ==================== Platform setting ==================== "
" MacVim
if has('gui_macvim')
    set guifont=Menlo:h14
    set guifontwide=M+1M+IPAG
    set transparency=5 " (opaque) 0-100 (transparent)
    set noimdisable

    set guioptions-=e " don't use gui tab apperance
    set guioptions-=T " hide toolbar
    set guioptions-=r " don't show scrollbars
    set guioptions-=l " don't show scrollbars
    set guioptions-=R " don't show scrollbars
    set guioptions-=L " don't show scrollbars
    set guioptions+=c " use console dialog rather than popup dialog

    noremap <silent> gw :macaction selectNextWindow:<CR>
    noremap <silent> gW :macaction selectPreviousWindow:<CR>
endif

" GVim(Windows)
if has('win32')
    " This must be after 'columns' and 'lines',
    " and before 'transparency'
    gui
    set guifont=Dejavu\ Sans\ Mono:h12:w7
    set guifontwide=M+1M+IPAG
    set transparency=240 " (opaque) 255 - 0 (transparent)

    set guioptions-=e " don't use gui tab apperance
    set guioptions-=T " hide toolbar
    set guioptions-=m " hide menubar
    set guioptions-=r " don't show scrollbars
    set guioptions-=l " don't show scrollbars
    set guioptions-=R " don't show scrollbars
    set guioptions-=L " don't show scrollbars
    set guioptions+=c " use console dialog rather than popup dialog
endif

" GVim(Gtk2)
if has('gui_gtk2')
    set guifont=Dejavu\ Sans\ Mono:h12:w7
    set guifontwide=M+1M+IPAG
    set linespace=2

    set guioptions-=e " don't use gui tab apperance
    set guioptions-=T " hide toolbar
    set guioptions-=m " hide menubar
    set guioptions-=r " don't show scrollbars
    set guioptions-=l " don't show scrollbars
    set guioptions-=R " don't show scrollbars
    set guioptions-=L " don't show scrollbars
    set guioptions+=c " use console dialog rather than popup dialog
endif
