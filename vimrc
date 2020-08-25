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

if s:is_win
    let s:runtimepath = expand('~/vimfiles')
else
    let s:runtimepath = expand('~/.vim')
endif

if s:is_win
  let s:data_dir = expand('$LOCALAPPDATA/vimrc')
elseif $XDG_DATA_HOME !=# ''
  let s:data_dir = expand('$XDG_DATA_HOME/vimrc')
else
  let s:data_dir = expand('~/.local/share/vimrc')
endif

" define and reset augroup used in vimrc
augroup vimrc
    autocmd!
augroup END

" get SID prefix of vimrc
" See: :h <SID>
function! s:SID_PREFIX()
    return matchstr(expand('<sfile>'), '<SNR>\d\+_')
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
let g:vim_indent_cont = 0

" input
set backspace=indent,eol,start
set formatoptions+=mM
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
set directory& directory-=. " don't save tmp swap file in current directory
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
set ambiwidth=single
set laststatus=2
set showtabline=2

" display cursorline only in active window
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

" use 'fileencoding' for 'encoding' if the file doesn't contain multibyte characters,
" and give up searching multibyte characters when searching time is over 100 ms
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

" save and load views automatically
set viewoptions=cursor,folds
let &viewdir = s:data_dir . '/view'
call mkdir(&viewdir, 'p')
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
set sessionoptions=curdir,folds,resize,tabpages,terminal,winsize
let s:sessiondir = s:data_dir . '/session'
call mkdir(s:sessiondir, 'p')
command! -bar MkSession execute 'mksession! ' . s:sessiondir . '/Session.vim'
command! Q MkSession <bar> wqa
command! LoadSession execute 'source ' . s:sessiondir . '/Session.vim'

" persistent undo
set undofile
let &undodir = s:data_dir . '/undo'
call mkdir(&undodir, 'p')

" enable mouse wheel with iTerm2
set mouse=a
set ttymouse=xterm2

" binary editing (See: :h xxd)
augroup vimrc
    autocmd BufReadPost,BufNewFile *.bin,*.exe,*.dll,*.swf,*.bmp setlocal filetype=xxd
    autocmd BufReadPost * if &l:binary | setlocal filetype=xxd | endif
augroup END


" ==================== Keybind and commands ==================== "
" prefix
nnoremap [Prefix] <Nop>
vnoremap [Prefix] <Nop>
nmap <Space> [Prefix]
vmap <Space> [Prefix]
noremap [Operator] <Nop>
map , [Operator]

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
inoremap <expr> <C-u> (pumvisible() ? "\<C-e>" : "") . "\<C-g>u\<C-u>"
inoremap <C-w> <C-g>u<C-w>
inoremap <CR> <C-g>u<CR>

" input path in command mode
cnoremap <expr> <C-x> expand('%:p:h') . "/"
cnoremap <expr> <C-z> expand('%:p:r')

" write file easely
nmap <silent> [Prefix]w :<C-u>:update<CR>

" reset highlight
nnoremap <silent> gh :<C-u>nohlsearch<CR>

" copy and paste
nnoremap gy "*y
vnoremap gy "*y
nnoremap gp "*p
vnoremap gp "*p

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
    " based on SpecialKey
    if &termguicolors
        execute 'highlight ZenkakuSpace guibg=' synIDattr(synIDtrans(hlID('SpecialKey')), 'fg')
    else
        execute 'highlight ZenkakuSpace ctermbg=' synIDattr(synIDtrans(hlID('SpecialKey')), 'fg')
    endif
endfunction

syntax enable

" colorscheme
if exists('+termguicolors')
    set termguicolors
    colorscheme gruvbox
elseif &t_Co == 256 || has('gui')
    let g:solarized_contrast = 'high'
    set background=dark
    colorscheme solarized
else
    colorscheme desert
endif

" ==================== Plugins ==================== "

" do NOT load plugins when git commit
if $HOME != $USERPROFILE && $GIT_EXEC_PATH != ''
  finish
end

filetype plugin indent on

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
    call minpac#add('aereal/vim-colors-japanesque')
    call minpac#add('morhetz/gruvbox')

    " enhance statusline and tabline
    call minpac#add('itchyny/lightline.vim')
    set noshowmode " hide mode when using lightline
    let g:lightline = {
    \    'colorscheme': 'gruvbox',
    \    'tabline': { 'right': [ [  ] ] },
    \    'active': {
    \       'left': [ [ 'mode', 'paste' ],
    \               [ 'readonly', 'filename', 'modified' ],
    \               [ 'gitrepo', 'gitstatus' ] ]
    \    },
    \    'component_function': {
    \       'method': s:SID_PREFIX() . 'nearestMethodOrFunction',
    \       'gitrepo': 'gina#component#repo#preset',
    \       'gitstatus': 'gina#component#status#preset'
    \    }
    \}

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
    call minpac#add('editorconfig/editorconfig-vim')

    " file manager
    call minpac#add('lambdalisue/fern.vim')
    nmap <silent> [Prefix]f :<C-u>Fern . -drawer -reveal=% -keep -toggle<CR>
    nmap <silent> [Prefix]F :<C-u>Fern . -drawer -reveal=%<CR>
    function! s:init_fern() abort
        nmap <buffer> y <Plug>(fern-action-copy)
        nmap <buffer> cd <Plug>(fern-action-cd)
        nmap <buffer> ct <Plug>(fern-action-tcd)
    endfunction
    augroup vimrc
        autocmd FileType fern call s:init_fern()
    augroup END

    call minpac#add('lambdalisue/gina.vim')

    " finder
    call minpac#add('liuchengxu/vim-clap')
    let g:clap_layout = {
    \   'relative': 'editor',
    \   'width': '70%', 'col': '15%',
    \   'height': '40%', 'row': 3
    \}
    nmap [Prefix]cc :<C-u>Clap!<CR>
    nmap [Prefix]cb :<C-u>Clap! buffers<CR>
    nmap [Prefix]cf :<C-u>Clap! files<CR>
    nmap [Prefix]cg :<C-u>Clap! grep<CR>

    call minpac#add('liuchengxu/vista.vim')
    nmap [Prefix]v :<C-u>Vista!!<CR>

    function! s:nearestMethodOrFunction() abort
      return get(b:, 'vista_nearest_method_or_function', '')
    endfunction
    autocmd vimrc VimEnter * call vista#RunForNearestMethodOrFunction()

    " completion
    call minpac#add('prabirshrestha/vim-lsp')
    call minpac#add('prabirshrestha/asyncomplete.vim')
    call minpac#add('prabirshrestha/asyncomplete-lsp.vim')
    call minpac#add('mattn/vim-lsp-settings')

    function! s:on_lsp_setup()
        let g:lsp_signs_error = {'text': '󿚆' }
        let g:lsp_signs_warning = {'text': '󿙿' }
        let g:lsp_signs_information = {'text': '󿙽' }
        let g:lsp_signs_hint = {'text': '󿚅' }
    endfunction

    function! s:on_lsp_buffer_enabled() abort
        setlocal omnifunc=lsp#complete
        setlocal tagfunc=lsp#tagfunc
        setlocal signcolumn=yes
        nmap <buffer> gd <plug>(lsp-definition)
        nmap <buffer> gr <plug>(lsp-references)
        nmap <buffer> gi <plug>(lsp-implementation)
        nmap <buffer> ge <plug>(lsp-type-definition)
        nmap <buffer> <f2> <plug>(lsp-rename)
        if &filetype !=# 'vim'
            nmap <buffer> K <plug>(lsp-hover)
        endif
    endfunction

    augroup vimrc
      autocmd User lsp_setup call s:on_lsp_setup()
      autocmd User lsp_buffer_enabled call s:on_lsp_buffer_enabled()
    augroup END
    command! LspDebug let lsp_log_verbose=1 | let lsp_log_file = expand('~/lsp.log')

    let g:asyncomplete_auto_popup = 1
    let g:asyncomplete_auto_completeopt = 0
    let g:asyncomplete_popup_delay = 200
    let g:lsp_diagnostics_enabled = 1
    let g:lsp_diagnostics_echo_cursor = 1
    let g:lsp_text_edit_enabled = 1
    let g:lsp_signs_enabled = 1
    let g:lsp_settings_filetype_html = ['html-languageserver', 'angular-language-server']

    set completeopt& completeopt+=menuone,popup,noinsert,noselect
    set completepopup=height:10,width:60,highlight:InfoPopup

    call minpac#add('hrsh7th/vim-vsnip')
    call minpac#add('hrsh7th/vim-vsnip-integ')
    let g:vsnip_snippet_dirs = [
    \   s:runtimepath . '/vsnip',
    \   s:data_dir . '/vsnip-vscode'
    \]
    for dir in g:vsnip_snippet_dirs
        call mkdir(dir, 'p')
    endfor

    function! RetrieveVSCodeSnippets() abort
        let files = {
        \   'typescript': 'https://raw.githubusercontent.com/microsoft/vscode/master/extensions/typescript-basics/snippets/typescript.code-snippets',
        \   'ruby': 'https://raw.githubusercontent.com/rubyide/vscode-ruby/master/packages/vscode-ruby/snippets/ruby.json',
        \   'python': 'https://raw.githubusercontent.com/microsoft/vscode-python/master/snippets/python.json'
        \}

        for [type, url] in items(files)
            call job_start(['curl', url, '-o', s:data_dir . '/vsnip-vscode/' . type . '.json'])
        endfor
    endfunction

    imap <expr> <C-l>   vsnip#available(1)  ? '<Plug>(vsnip-expand-or-jump)' : '<C-l>'
    smap <expr> <C-l>   vsnip#available(1)  ? '<Plug>(vsnip-expand-or-jump)' : '<C-l>'
    imap <expr> <Tab>   vsnip#jumpable(1)   ? '<Plug>(vsnip-jump-next)'      : '<Tab>'
    smap <expr> <Tab>   vsnip#jumpable(1)   ? '<Plug>(vsnip-jump-next)'      : '<Tab>'
    imap <expr> <S-Tab> vsnip#jumpable(-1)  ? '<Plug>(vsnip-jump-prev)'      : '<S-Tab>'
    smap <expr> <S-Tab> vsnip#jumpable(-1)  ? '<Plug>(vsnip-jump-prev)'      : '<S-Tab>'

    " linter
    call minpac#add('dense-analysis/ale')

    " vital
    call minpac#add('vim-jp/vital.vim')

    " edita
    " call minpac#add('kyoh86/vim-editerm')
    call minpac#add('lambdalisue/edita.vim')
    let g:edita_enable = 0

    " MEMO: will install later if needed
    " 'SudoEdit.vim'
    " 'deton/jasegment.vim'
    " 'kana/vim-operator-replace'
    "   map [Operator]r <Plug>(operator-replace)
    " 'kana/vim-operator-user'
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

" ==================== Others ==================== "
" FileType
augroup vimrc
    " golang
    autocmd FileType go setlocal noexpandtab
augroup END

" TOhtml
let g:html_number_lines = 0
let g:html_use_css = 1
let g:use_xhtml = 1
let g:html_use_encoding = 'utf-8'

" Ranger
let g:ranger_map = {
\   'S': 'botright split <<file>>',
\   'ct': 'tcd <<dir>>',
\   'T': 'tabnew <<DIR>> | tcd <<DIR>>',
\}
let g:ranger_opener = 'edit'
let g:ranger_rows = 12

" auto reloading vimrc
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
