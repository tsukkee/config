" Last Change: 27 Feb 2013
" Author:      tsukkee
" Licence:     The MIT License {{{
"     Permission is hereby granted, free of charge, to any person obtaining a copy
"     of this software and associated documentation files (the "Software"), to deal
"     in the Software without restriction, including without limitation the rights
"     to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
"     copies of the Software, and to permit persons to whom the Software is
"     furnished to do so, subject to the following conditions:
"
"     The above copyright notice and this permission notice shall be included in
"     all copies or substantial portions of the Software.
"
"     THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
"     IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
"     FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
"     AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
"     LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
"     OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
"     THE SOFTWARE.
" }}}

" Before use this vimrc, it's better to rename vimrc and gvimrc
" of Kaoriya so that gvim don't read these.

" ==================== Platform setting ==================== "
" MacVim
if has('gui_macvim')
    if has('vim_starting')
        set columns=154
        set lines=52
    endif
    set linespace=2

    set guifont=Cica:h16
    set guifontwide=Cica

    set transparency=5 " (opaque) 0-100 (transparent)
    set noimdisable    " use IM control
    if has('kaoriya')
        set imdisableactivate
    endif

    set guioptions-=e " don't use gui tab apperance
    set guioptions-=T " hide toolbar
    set guioptions-=r " don't show scrollbars
    set guioptions-=l " don't show scrollbars
    set guioptions-=R " don't show scrollbars
    set guioptions-=L " don't show scrollbars
    set guioptions+=c " use console dialog rather than popup dialog

    nnoremap <silent> gw :<C-u>macaction selectNextWindow:<CR>
    nnoremap <silent> gW :<C-u>macaction selectPreviousWindow:<CR>

    " for latest MacVim-Kaoriya
    if has('kaoriya')
        let $RUBY_DLL="/usr/lib/libruby.dylib"
    endif
endif

" GVim(Windows)
if has('win32')
    if has('vim_starting')
        set columns=120
        set lines=32
    endif
    set linespace=1

    " This must be after 'columns' and 'lines',
    " and before 'transparency'
    gui

    " set guifont=MigMix_1M:h12:cSHIFTJIS
    set guifont=Ricty_Diminished:h13:cSHIFTJIS

    " if has('kaoriya')
    "     set transparency=240 " (opaque) 255 - 0 (transparent)
    " endif

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
    set linespace=2

    set guifont=Dejavu\ Sans\ Mono 10
    set guifontwide=TakaoGothic\ 10

    set guioptions-=e " don't use gui tab apperance
    set guioptions-=T " hide toolbar
    set guioptions-=m " hide menubar
    set guioptions-=r " don't show scrollbars
    set guioptions-=l " don't show scrollbars
    set guioptions-=R " don't show scrollbars
    set guioptions-=L " don't show scrollbars
    set guioptions+=c " use console dialog rather than popup dialog
endif
