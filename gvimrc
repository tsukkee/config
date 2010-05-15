" Before use this vimrc, it's better to rename vimrc and gvimrc
" of Kaoriya so that gvim don't read these.

" ==================== Display setting ==================== "
" override vimrc settings
set title

" gvim settings
if !exists('g:vim_has_launched')
    set linespace=1
    set columns=138
    set lines=42
endif


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

    " Reference: http://github.com/kana/config/blob/c21dfc660dd789e14b0c194315773b71815f3ef0/vim/personal/dot.vimrc#L657
    function! s:activate_terminal()
        silent !open -a Terminal
        " silent !open -a iTerm
    endfunction
    command! ActivateTerminal call <SID>activate_terminal()
    nnoremap <silent> <C-f>m :<C-u>call <SID>activate_terminal()<CR>
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
