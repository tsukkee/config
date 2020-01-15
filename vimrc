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

scriptencoding utf-8

" ==================== Utilities ==================== "
let s:is_win = has('win32') || has('win64')
let s:is_mac = has('mac')
let s:is_linux = has('linux')

let s:runtimepath = expand(s:is_win ? '~/vimfiles' : '~/.vim')

" define and reset augroup used in vimrc
augroup vimrc
    autocmd!
augroup END

" get SID prefix of vimrc
" See: :h <SID>
function! s:SID_PREFIX()
    return matchstr(expand('<sfile>'), '<SNR>\d\+_')
endfunction

" get dirname
function! s:dirname(path)
    return isdirectory(a:path) ? a:path : fnamemodify(a:path, ':p:h')
endfunction

" mapping command
command! -bang -nargs=+ CommandMap call s:commandMap('nnoremap', <bang>0, <f-args>)
function! s:commandMap(command, buffer, lhs, ...)
    let rhs = join(a:000, ' ')
    let buffer = a:buffer ? '<buffer>' : ''
    execute a:command '<silent>' buffer a:lhs ':<C-u>' . rhs . '<CR>'
endfunction


" ==================== Settings ==================== "
if s:is_win
    set shellslash
endif

set spelllang=en,cjk
set viminfo& viminfo+=%20

" indent
set tabstop=4
set shiftwidth=4
set softtabstop=4
set expandtab
set smartindent

" input
set backspace=indent,eol,start
set formatoptions+=mM " add multibyte support
" set formatexpr=jpvim#formatexpr()
set nolinebreak
set iminsert=0
set imsearch=0

" command completion
set wildmenu
set wildmode=list:longest,full

" search
set wrapscan
set ignorecase
set smartcase
set incsearch
set hlsearch
nohlsearch " reset highlighting when reloading vimrc
set wildignore+=*/.git*,*/.hg/*,*/.svn/*

" reading and writing file
set directory-=. " don't save tmp swap file in current directory
set autoread
set hidden
set tags=./tags; " search tag file recursively (See: :h file-searching)

" interface
set showmatch
set showcmd
set showmode
set number
set wrap
set scrolloff=5
set foldmethod=marker
set foldcolumn=3
set list
set listchars=tab:^\ ,trail:~
set ambiwidth=double
set laststatus=2 " always show statusine
set showtabline=2 " always show tabline

" display cursorline only in active window
" Reference: http://nanabit.net/blog/2007/11/03/vim-cursorline/
augroup vimrc
    autocmd WinLeave * setlocal nocursorline
    autocmd WinEnter,BufRead * setlocal cursorline
augroup END

" use set encoding=utf-8 in Windows
if s:is_win && has('gui_running')
    language messages ja_JP.UTF-8
    set encoding=utf-8
endif

" detect encoding
if has('kaoriya')
    set fileencodings=guess
else
    set fileencodings=iso-2022-jp,euc-jp,cp932,utf-8,latin1
endif

" use 'fileencoding' for 'encoding' if the file doesn't contain multibyte characters
" give up searching multibyte characters when searching time is over 100 ms
autocmd vimrc BufReadPost *
\   if &fileencoding =~# 'iso-2022-jp' && search("[^\x01-\x7e]", 'n', 0, 100) == 0
\|      let &fileencoding=&encoding
\|  endif

" detect line feed character
if s:is_win
    set ffs=dos,unix
else
    set ffs=unix,dos
endif

" show quickfix automatically
autocmd vimrc QuickfixCmdPost * if !empty(getqflist()) | cwindow | endif

" save and load fold settings automatically
" Reference: http://vim-users.jp/2009/10/hack84/
" Don't save options.
set viewoptions-=options
let &viewdir = s:runtimepath . '/view'
augroup vimrc
    autocmd BufWritePost *
    \   if expand('%') != '' && &buftype !~ 'nofile'
    \|      mkview
    \|  endif
    autocmd BufRead *
    \   if expand('%') != '' && &buftype !~ 'nofile'
    \|      silent loadview
    \|  endif
augroup END

" session
set sessionoptions=folds,resize,tabpages

" persistent undo
set undofile
let &undodir = s:runtimepath . '/undo'

" enable mouse wheel with iTerm2
if s:is_mac
    set mouse=a
    set ttymouse=xterm2
endif

" binary editing (See: :h xxd)
" Reference: http://vim-users.jp/2010/03/hack133/
augroup vimrc
    autocmd BufReadPost,BufNewFile *.bin,*.exe,*.dll,*.swf,*.bmp setlocal filetype=xxd
    autocmd BufReadPost * if &l:binary | setlocal filetype=xxd | endif
augroup END

" use jvgrep
if executable('jvgrep')
    set grepprg=jvgrep
endif


" ==================== Keybind and commands ==================== "
" prefix
" Reference: http://d.hatena.ne.jp/kuhukuhun/20090213/1234522785
nnoremap [Prefix] <Nop>
vnoremap [Prefix] <Nop>
nmap <Space> [Prefix]
vmap <Space> [Prefix]
noremap [Operator] <Nop>
map , [Operator]

" make easy to execute <Esc>
inoremap jf <Esc>
cnoremap fj <Esc>
cnoremap jf <Esc>
vnoremap fj <Esc>
vnoremap jf <Esc>

" use more logical mapping (See: :h Y)
nnoremap Y y$

" use physical cursor movement
nnoremap j gj
nnoremap gj j
vnoremap j gj
vnoremap gj j
nnoremap k gk
nnoremap gk k
vnoremap k gk
vnoremap gk k
nnoremap $ g$
nnoremap g$ $
vnoremap $ g$
vnoremap g$ $
nnoremap 0 g0
nnoremap g0 0
vnoremap 0 g0
vnoremap g0 0

" use beginning matches on command-line history
cnoremap <C-p> <Up>
cnoremap <Up> <C-p>
cnoremap <C-n> <Down>
cnoremap <Down> <C-n>

" allow undo for i_CTRL-u, i_CTRL-w and <CR>
" Reference: http://vim-users.jp/2009/10/hack81/
inoremap <expr> <C-u> (pumvisible() ? "\<C-e>" : "") . "\<C-g>u\<C-u>"
inoremap <C-w> <C-g>u<C-w>
inoremap <CR> <C-g>u<CR>

" folding
" Reference: http://d.hatena.ne.jp/ns9tks/20080318/1205851539
nnoremap <expr> h col('.') == 1 && foldlevel(line('.')) > 0 ? 'zc' : 'h'
nnoremap <expr> l foldclosed(line('.')) != -1 ? 'zo' : 'l'
vnoremap <expr> h col('.') == 1 && foldlevel(line('.')) > 0 ? 'zcgv' : 'h'
vnoremap <expr> l foldclosed(line('.')) != -1 ? 'zogv' : 'l'

" input path in command mode
cnoremap <expr> <C-x> expand('%:p:h') . "/"
cnoremap <expr> <C-z> expand('%:p:r')

" write file easely
CommandMap [Prefix]w update

" reset highlight
CommandMap gh nohlsearch

" copy and paste with fakeclip
" See: :h fakeclip-multibyte-on-mac
map gy "*y
map gp "*p
if exists('$WINDOW') || exists('$TMUX')
    map gY <Plug>(fakeclip-screen-y)
    map gP <Plug>(fakeclip-screen-p)
endif

" rename
command! -nargs=1 -bang -complete=file Rename saveas<bang> <args> | call delete(expand('#'))

" ctags
command! -nargs=0 CtagsR !ctags -R

" utility command for Mac
if s:is_mac
    command! Here silent call system('open ' . expand('%:p:h'))
    command! This silent call system('open ' . expand('%:p'))
    command! -nargs=1 -complete=file Open silent call system('open ' . shellescape(expand(<f-args>), 1))
endif

" utility command for Windows
if s:is_win
    command! Here silent execute '!explorer' expand('%:p:h')
    command! This silent execute '!start cmd /c "%"'
    command! -nargs=1 -complete=file Open silent execute '!explorer' shellescape(expand(<f-args>), 1)
endif


" ==================== Hightlight ==================== "
augroup vimrc
    autocmd ColorScheme * call s:onColorScheme()
    autocmd VimEnter,WinEnter * call matchadd('ZenkakuSpace', '　')
augroup END
function! s:onColorScheme()
    " Modify colorscheme
    if !exists('g:colors_name')
        return
    endif

    if g:colors_name == 'solarized'
        " based on SpecialKey
        highlight ZenkakuSpace ctermbg=185
        " indent guids
        highlight IndentGuidesOdd ctermbg=187
        highlight IndentGuidesEven ctermbg=186
    else
        highlight ZenkakuSpace ctermbg=77
    endif
endfunction

syntax enable

" Indent guide
let g:indent_guides_enable_on_vim_startup = 1
let g:indent_guides_auto_colors = 0
let g:indent_guides_guide_size = 1

" colorscheme
if &t_Co == 256 || has('gui')
    let g:solarized_contrast = 'high'
    set background=light
    colorscheme solarized
    " colorscheme iceberg
else
    colorscheme desert
endif

" ==================== Plugins ==================== "
filetype plugin indent on

" do NOT load plugins when git commit
if $HOME != $USERPROFILE && $GIT_EXEC_PATH != ''
  finish
end

" use minpac to manage my plugins
packadd minpac

if !exists('*minpac#init')
    " minpac is not available
else
    call minpac#init()
    call minpac#add('k-takata/minpac', {'type': 'opt'})

    " colorscheme
    call minpac#add('altercation/vim-colors-solarized')
    call minpac#add('cocopon/iceberg.vim')

    " enhance statusline and tabline
    call minpac#add('itchyny/lightline.vim')
    set noshowmode " hide mode when using lightline
    let g:lightline = {
    \    'tabline': { 'right': [ [  ] ] }
    \} " just delete close button on tabline

    " enhance key mappings
    call minpac#add('kana/vim-submode')
    let g:submode_timeoutlen=600
    packadd vim-submode

    " tab move
    call submode#enter_with('tabmove', 'n', '', 'gt', 'gt')
    call submode#enter_with('tabmove', 'n', '', 'gT', 'gT')
    call submode#map('tabmove', 'n', '', 't', 'gt')
    call submode#map('tabmove', 'n', '', 'T', 'gT')

    " window resizing with submode
    call submode#enter_with('winsize', 'n', '', '<C-w>>', '<C-w>>')
    call submode#enter_with('winsize', 'n', '', '<C-w><', '<C-w><')
    call submode#enter_with('winsize', 'n', '', '<C-w>+', '<C-w>+')
    call submode#enter_with('winsize', 'n', '', '<C-w>-', '<C-w>-')
    call submode#map('winsize', 'n', '', '>', '<C-w>>')
    call submode#map('winsize', 'n', '', '<', '<C-w><')
    call submode#map('winsize', 'n', '', '+', '<C-w>+')
    call submode#map('winsize', 'n', '', '-', '<C-w>-')

    " text editting
    call minpac#add('andymass/vim-matchup')
    call minpac#add('machakann/vim-sandwich')
    call minpac#add('tyru/caw.vim')
    call minpac#add('junegunn/vim-easy-align')

    " file manager
    call minpac#add('cocopon/vaffle.vim')

    " fuzzy finder
    call minpac#add('liuchengxu/vim-clap')

    " completion
    " Reference: https://mattn.kaoriya.net/software/vim/20191231213507.htm
    call minpac#add('prabirshrestha/async.vim')
    call minpac#add('prabirshrestha/asyncomplete.vim')
    call minpac#add('prabirshrestha/asyncomplete-lsp.vim')
    call minpac#add('prabirshrestha/vim-lsp')
    call minpac#add('mattn/vim-lsp-settings')
    call minpac#add('mattn/vim-lsp-icons')
    call minpac#add('hrsh7th/vim-vsnip')
    call minpac#add('hrsh7th/vim-vsnip-integ')

    function! s:on_lsp_buffer_enabled() abort
        setlocal omnifunc=lsp#complete
        setlocal signcolumn=yes
        nmap <buffer> gd <plug>(lsp-definition)
        nmap <buffer> <f2> <plug>(lsp-rename)
        inoremap <expr> <cr> pumvisible() ? "\<c-y>" : "\<cr>"
    endfunction

    augroup lsp_install
      au!
      autocmd User lsp_buffer_enabled call s:on_lsp_buffer_enabled()
    augroup END
    command! LspDebug let lsp_log_verbose=1 | let lsp_log_file = expand('~/lsp.log')

    let g:lsp_diagnostics_enabled = 1
    let g:lsp_diagnostics_echo_cursor = 1
    let g:asyncomplete_auto_popup = 1
    let g:asyncomplete_auto_completeopt = 0
    let g:asyncomplete_popup_delay = 200
    let g:lsp_text_edit_enabled = 1

    set completeopt& completeopt+=menuone,popup,noinsert,noselect
    set completepopup=height:10,width:60,highlight:InfoPopup

    function! s:setup_angular_server() abort
        let base = expand(printf('~/.vscode/extensions/%s', 'angular.ng-template-0.900.3'))
        let node_modules = printf('%s/node_modules/', base)
        let ng = expand(printf('--ngProbeLocations %s/server', base))
        let ts = expand(printf('--tsProbeLocations %s', node_modules))
        let s:server = printf('%s/server %s %s', base, ng, ts)
        autocmd User lsp_setup call lsp#register_server({
        \   'name': 'Angular Language Service',
        \   'cmd': {server_info -> [&shell, &shellcmdflag, printf('node %s --stdio', s:server)]},
        \   'root_uri':{server_info -> lsp#utils#path_to_uri(lsp#utils#find_nearest_parent_file_directory(lsp#utils#get_buffer_path(), 'angular.json'))},
        \   'whitelist': ['html', 'typescript'],
        \})
    endfunction
    call s:setup_angular_server()

    " vital
    call minpac#add('vim-jp/vital.vim')

    " MEMO: will install later if needed
    " 'SudoEdit.vim'
    " 'deton/jasegment.vim'
    " 'kana/vim-fakeclip'
    " 'kana/vim-operator-replace'
    "   map [Operator]r <Plug>(operator-replace)
    " 'kana/vim-operator-user'
    " 'kana/vim-tabpagecd'
    " 'kana/vim-textobj-indent'
    " 'kana/vim-textobj-user'
    " 't9md/vim-quickhl'
    "   nmap [Prefix]m <Plug>(quickhl-toggle)
    "   vmap [Prefix]m <Plug>(quickhl-toggle)
    "   nmap [Prefix]M <Plug>(quickhl-reset)
    " 't9md/vim-textmanip'
    " 'thinca/vim-quickrun'
    "   let g:quickrun_no_default_key_mappings = 1
    "   vmap [Prefix]q :QuickRun<CR>
    " 'thinca/vim-ref'
    "   if s:is_mac
    "      let g:ref_refe_cmd = '/opt/local/bin/refe-1_8_7'
    "      let g:ref_refe_encoding = 'utf-8'
    "      let g:ref_refe_rsense_cmd = '/usr/local/lib/rsense-0.2/bin/rsense'
    "      let g:ref_phpmanual_path = expand('~/Documents/phpmanual')
    "   elseif s:is_win
    "      let g:ref_refe_encoding = 'cp932'
    "      let g:ref_phpmanual_path = expand('~/Documents/phpmanual')
    "   endif
    " 'vim-jp/autofmt'
    "    hi ColorColumn guibg=#aaaaaa
    "    autocmd vimrc FileType text,txt
    "   \   setl cc+=72
    "   \|  setl textwidth=72
    "   \|  setl formatexpr=autofmt#japanese#formatexpr()
endif


" ==================== Plugins settings ==================== "
" FileType
augroup vimrc
    " tex
    autocmd FileType plaintex,tex
    \   setlocal foldmethod=expr
    \|  let &l:foldexpr = s:SID_PREFIX() . 'tex_foldexpr(v:lnum)'
    " folding using \section, \subsection, \subsubsection
    function! s:tex_foldexpr(lnum)
        " set fold level as section level
        let matches = matchlist(getline(a:lnum), '^\s*\\\(\(sub\)*\)section')
        if !empty(matches)
            " for example, matches[1] is 'subsub' when line is '\subsubsection'
            return len(matches[1]) / 3 + 1
        else
            " when next line is /\\(sub)*section/, this line is the end of specified section
            let matches = matchlist(getline(a:lnum + 1), '^\s*\\\(\(sub\)*\)section')
            if !empty(matches)
                return '<' . string(len(matches[1]) / 3 + 1)
            " otherwise keep fold level
            else
                return '='
            endif
        endif
    endfunction

    " golang
    autocmd FileType go
    \   setlocal noexpandtab
augroup END

" TOhtml
let g:html_number_lines = 0
let g:html_use_css = 1
let g:use_xhtml = 1
let g:html_use_encoding = 'utf-8'

" markdown-pandoc
let s:pandoc_command = "pandoc \"%s\" -s -c \"%s\" -o \"%s\" &"
let s:pandoc_default_css = 'pandoc.css'
let s:pandoc_default_formats = ['html']
let s:pandoc_output_encoding = s:is_win ? 'cp932' : 'utf-8'

function! s:pandoc_auto_run()
    if exists('b:pandoc_enable') && b:pandoc_enable
        let b:pandoc_auto_run = 1
    endif
endfunction

function! s:pandoc_stop_auto_run()
    let b:pandoc_auto_run = 0
endfunction

function! s:pandoc_run()
    if !exists('b:pandoc_auto_run') || !b:pandoc_auto_run | return | endif

    let input = expand('%')
    let base = expand('%:r')
    let css = exists('b:pandoc_css') ? b:pandoc_css : s:pandoc_default_css
    let formats = exists('b:pandoc_formats') && (type([]) == type(b:pandoc_formats))
                \ ? b:pandoc_formats : s:pandoc_default_formats

    for format in formats
        let c = iconv(printf(s:pandoc_command, input, css, base . '.' . format),
                    \ &encoding, s:pandoc_output_encoding)
        call vimproc#system(c)
        if vimproc#get_last_status() != 0
            echomsg vimproc#get_last_errmsg()
        endif
    endfor
endfunction

function! s:pandoc_parse_local_setting()
    let raw = matchstr(getline('$'), '<!--\zs.\+\ze-->')
    try
        sandbox let data = eval('{' . raw . '}')
        for [k, v] in items(data)
            let b:pandoc_{k} = v
            unlet k v
        endfor
    catch /E121/
        echomsg 'markdown: local setting parse error'
    endtry
endfunction

function! s:markdown_make_title()
    let l = strwidth(getline('.'))
    let n = line('.')
    let s = ''
    for i in range(l)
        let s .= '='
    endfor
    call append(n, s)
endfunction

function! s:pandoc_markdown_to_pdf()
    let oldcwd = getcwd()
    lcd `=expand("%:p:h")`

    let command = "pandoc %s -V documentclass=ltjarticle --latex-engine=lualatex -o %s"
    let input = expand('%')
    let output = expand('%:r') . '.pdf'
    let c = iconv(printf(command, input, output), &encoding, s:pandoc_output_encoding)
    call vimproc#system(c)
    if vimproc#get_last_status() != 0
        echomsg vimproc#get_last_errmsg()
    endif

    lcd `=oldcwd`
endfunction

function! s:pandoc_setup_markdown()
    call s:pandoc_parse_local_setting()
    call s:pandoc_auto_run()

    nnoremap <buffer> [Prefix]T :<C-u>call <SID>markdown_make_title()<CR>

    command! -buffer PandocAutoRun call s:pandoc_auto_run()
    command! -buffer PandocMarkdown2PDF call s:pandoc_markdown_to_pdf()
endfunction
autocmd vimrc BufWritePost *.mkd call s:pandoc_run()
autocmd vimrc FileType markdown call s:pandoc_setup_markdown()

" ==================== Loading vimrc ==================== "
" auto reloading vimrc
" Reference: http://vim-users.jp/2009/09/hack74/
if has('gui_running')
    autocmd vimrc BufWritePost .vimrc,_vimrc,vimrc nested
    \   source $MYVIMRC | source $MYGVIMRC
    autocmd vimrc BufWritePost .gvimrc,_gvimrc,gvimrc nested
    \   source $MYGVIMRC
else
    autocmd vimrc BufWritePost .vimrc,_vimrc,vimrc nested
    \   source $MYVIMRC
endif

if filereadable(expand('~/.vimrc.local'))
    source ~/.vimrc.local
endif

set secure
