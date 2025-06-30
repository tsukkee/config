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
" shell
set shell=/bin/zsh
if s:is_win
    set shellslash
endif

set spelllang=en,cjk

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
set nrformats=bin,hex,unsigned
set iminsert=0
set imsearch=0
set ttimeoutlen=10

" command completion
set wildmenu
" set wildmode=list:longest,full
set wildoptions=pum,fuzzy

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
    autocmd WinLeave * if &filetype !~# "^lsp-quickpick" | setlocal nocursorline | endif
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
    set fileencodings=iso-2022-jp,utf-8,euc-jp,cp932,latin1
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

" search with rg
function! s:grep(word, dir='') abort
    cgetexpr system(printf("rg --vimgrep --smart-case --fixed-strings --hidden -g '!.git/' %s %s", shellescape(a:word), a:dir))
endfunction
command! -nargs=+ Grep call <SID>grep(<f-args>)
command! -nargs=? GrepCursor call histdel('cmd', -1) | call histadd('cmd', 'Grep ' .. expand("<cword>")) | call <SID>grep(expand("<cword>"), <f-args>)

nnoremap [q <cmd>cprev<CR>
nnoremap ]q <cmd>cnext<CR>
function! s:qf_map() abort
    nnoremap <buffer> <silent> H <cmd>colder<CR>
    nnoremap <buffer> <silent> L <cmd>cnewer<CR>
endfunction
autocmd vimrc FileType qf call s:qf_map()

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

" don't use Ex-mode
nnoremap Q <Nop>

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
nmap <silent> [Prefix]w <Cmd>update<CR>

" reset highlight
nnoremap <silent> gh <Cmd>nohlsearch<CR>

" copy and paste
nnoremap gy "*y
vnoremap gy "*y
nnoremap gp "*p
vnoremap gp "*p

" fix syntax highlight (especially for long vue/ts files)
autocmd vimrc BufEnter * syntax sync fromstart

" utility command for Mac
if s:is_mac
    command! Here silent call system('open ' . expand('%:p:h'))
    command! This silent call system('open ' . expand('%:p'))
    command! -nargs=1 -complete=file OpenWithSystem silent call system('open ' . shellescape(expand(<f-args>), 1))
endif

" utility command for Windows
if s:is_win
    command! Here silent execute '!explorer' expand('%:p:h')
    command! This silent execute '!start cmd /c "%"'
    command! -nargs=1 -complete=file OpenWithSystem silent execute '!explorer' shellescape(expand(<f-args>), 1)
endif

" fix typo
abbreviate stirng string

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

    " ALE
    highlight ALEError ctermfg=NONE guifg=NONE cterm=undercurl gui=undercurl
    highlight ALEWarning ctermfg=NONE guifg=NONE cterm=undercurl gui=undercurl

    " Background
    highlight Normal ctermbg=NONE guibg=NONE
endfunction

syntax enable

" colorscheme
set background=dark
if exists('+termguicolors')
    set termguicolors

    " see :h undercurl
    let &t_Cs = "\e[4:3m"
    let &t_Ce = "\e[4:0m"

    " see :h xterm-true-color
    let &t_8f = "\<Esc>[38;2;%lu;%lu;%lum"
    let &t_8b = "\<Esc>[48;2;%lu;%lu;%lum"

    " see :h termcap-cursor-shape
    let &t_SH = 2        " steady block
    let &t_SI = "\e[6 q" " steady bar
    let &t_SR = "\e[4 q" " steady underline
    let &t_EI = "\e[2 q" " steady block

    let g:nord_bold_vertical_split_line = 1
    let g:nord_italic = 1
    let g:nord_italic_comments = 1
    set fillchars=vert:\ 

    colorscheme nord
elseif &t_Co == 256 || has('gui')
    let g:solarized_contrast = 'high'
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

if !exists('g:loaded_minpac')
    " minpac is not available
else
    call minpac#init()
    call minpac#add('k-takata/minpac', {'type': 'opt'})

    " colorscheme
    call minpac#add('altercation/vim-colors-solarized')
    " call minpac#add('cocopon/iceberg.vim')
    " call minpac#add('aereal/vim-colors-japanesque')
    " call minpac#add('morhetz/gruvbox')
    " call minpac#add('ulwlu/elly.vim')
    call minpac#add('arcticicestudio/nord-vim')

    " enhance statusline and tabline
    call minpac#add('itchyny/lightline.vim')
    call minpac#add('maximbaz/lightline-ale')
    set noshowmode " hide mode when using lightline
    let g:lightline = {
    \    'colorscheme': 'nord',
    \    'tabline': { 'right': [ [  ] ] },
    \    'separator': { 'left': "\ue0b0", 'right': "\ue0b2" },
    \    'subseparator': { 'left': "\ue0b1", 'right': "\ue0b3" },
    \    'active': {
    \       'left': [ [ 'mode', 'paste' ],
    \                 [ 'readonly', 'filename', 'modified', 'method' ] ],
    \       'right': [ [ 'lineinfo', 'percent' ],
    \                  [ 'fileformat', 'fileencoding', 'filetype' ],
    \                  [ 'linter_checking', 'linter_errors', 'linter_warnings', 'linter_infos', 'linter_ok' ] ]
    \    },
    \    'component_function': {
    \       'method': s:SID_PREFIX() . 'nearestMethodOrFunction',
    \    },
    \    'component_expand': {
    \       'linter_checking': 'lightline#ale#checking',
    \       'linter_infos': 'lightline#ale#infos',
    \       'linter_warnings': 'lightline#ale#warnings',
    \       'linter_errors': 'lightline#ale#errors',
    \       'linter_ok': 'lightline#ale#ok',
    \    },
    \    'component_type': {
    \       'linter_checking': 'right',
    \       'linter_infos': 'right',
    \       'linter_warnings': 'warning',
    \       'linter_errors': 'error',
    \       'linter_ok': 'right',
    \    }
    \}
    let g:lightline#ale#indicator_checking = "\uf110 "
    let g:lightline#ale#indicator_infos = "\uf129 "
    let g:lightline#ale#indicator_warnings = "\uf071 "
    let g:lightline#ale#indicator_errors = "\uf05e "
    let g:lightline#ale#indicator_ok = "\uf00c "

    " enhance key mappings
    call minpac#add('kana/vim-submode')
    let g:submode_timeoutlen=600
    packadd vim-submode

    " tab move
    call submode#enter_with('tabmove', 'n', '', 'gt', 'gt')
    call submode#enter_with('tabmove', 'n', '', 'gT', 'gT')
    call submode#map('tabmove', 'n', '', 't', 'gt')
    call submode#map('tabmove', 'n', '', 'T', 'gT')

    " window resizing
    call submode#enter_with('winsize', 'n', '', '<C-w>>', '<C-w>>')
    call submode#enter_with('winsize', 'n', '', '<C-w><', '<C-w><')
    call submode#enter_with('winsize', 'n', '', '<C-w>+', '<C-w>+')
    call submode#enter_with('winsize', 'n', '', '<C-w>-', '<C-w>-')
    call submode#map('winsize', 'n', '', '>', '<C-w>>')
    call submode#map('winsize', 'n', '', '<', '<C-w><')
    call submode#map('winsize', 'n', '', '+', '<C-w>+')
    call submode#map('winsize', 'n', '', '-', '<C-w>-')

    call minpac#add('markstory/vim-zoomwin')
    nmap [Prefix]z <Cmd>ZoomToggle<CR>

    " text editting
    call minpac#add('andymass/vim-matchup')
    let g:matchup_matchparen_offscreen = {'method': 'popup'}
    call minpac#add('machakann/vim-sandwich')
    nmap s <Nop>
    xmap s <Nop>
    call minpac#add('tyru/caw.vim')
    call minpac#add('junegunn/vim-easy-align')
    call minpac#add('editorconfig/editorconfig-vim')
    call minpac#add('Yggdroot/indentLine')
    let g:indentLine_char = '┊'
    call minpac#add('markonm/traces.vim')
    call minpac#add('rbtnn/vim-ambiwidth')
    let g:ambiwidth_cica_enabled = v:false

    " file manager
    " call minpac#add('lambdalisue/fern.vim')
    " nmap <silent> [Prefix]f <Cmd>Fern . -drawer -reveal=% -keep -toggle<CR>
    " nmap <silent> [Prefix]F <Cmd>Fern . -drawer -reveal=%<CR>
    " function! s:init_fern() abort
    "     nmap <buffer> y <Plug>(fern-action-copy)
    "     nmap <buffer> cd <Plug>(fern-action-cd)
    "     nmap <buffer> ct <Plug>(fern-action-tcd)
    " endfunction
    " augroup vimrc
    "     autocmd FileType fern call s:init_fern()
    " augroup END

    " call minpac#add('lambdalisue/gina.vim')

    call minpac#add('tsukkee/vim-rangeriv')
    let g:rangeriv_map = {
    \   '<enter>': 'execute "normal! \<C-W>\<C-P>" | edit <<file>>',
    \   'S': 'botright split <<file>>',
    \   'V': 'execute "normal! \<C-W>\<C-P>" | belowright vsplit <<file>>',
    \   'T': 'tabnew <<file>> | tcd <<dir>>',
    \   'ct': 'tcd <<dir>>',
    \   'q': 'call timer_start(0, { -> execute("quit") })'
    \}
    let g:rangeriv_opener = 'edit'
    let g:rangeriv_rows = 12
    let g:rangeriv_close_on_vimexit = v:true
    nmap [Prefix]r <Cmd>Rangeriv<CR>

    " finder
    call minpac#add('liuchengxu/vim-clap')
    let g:clap_layout = {
    \   'relative': 'editor',
    \   'width': '70%', 'col': '15%',
    \   'height': '40%', 'row': 3
    \}
    let g:clap_popup_move_manager = {
    \ "\<C-N>": "\<Down>",
    \ "\<C-P>": "\<Up>",
    \ }
    let g:clap_preview_direction = 'UD'

    function! g:ClapProviderHistoryCustomFilter(line) abort
        return !isabsolutepath(a:line)
    endfunction

    nmap [Prefix]pc <Cmd>Clap<CR>
    nmap [Prefix]pb <Cmd>Clap buffers<CR>
    nmap [Prefix]pf <Cmd>Clap files<CR>
    nmap [Prefix]pg <Cmd>Clap grep<CR>
    nmap [Prefix]pt <Cmd>Clap tags<CR>
    nmap [Prefix]pp <Cmd>Clap proj_tags<CR>
    nnoremap <C-p>  <Cmd>Clap history<CR>

    call minpac#add('liuchengxu/vista.vim')
    nmap [Prefix]v <Cmd>Vista!!<CR>

    let g:vista_executive_for = {
    \   'typescript': 'vim_lsp',
    \   'vue': 'vim_lsp',
    \   'scss': 'vim_lsp',
    \   'css': 'vim_lsp',
    \   'python': 'vim_lsp',
    \   'go': 'vim_lsp',
    \   'ruby': 'vim_lsp',
    \}

    let g:vista#renderer#icons = {
    \    'func': nr2char(0xff794),
    \    'function': nr2char(0xff794),
    \    'functions': nr2char(0xff794),
    \    'var': nr2char(0xff71b),
    \    'variable': nr2char(0xff71b),
    \    'variables': nr2char(0xff71b),
    \    'const': nr2char(0xff8ff),
    \    'constant': nr2char(0xff8ff),
    \    'constructor': nr2char(0xff976),
    \    'method': nr2char(0xff6a6),
    \    'package': nr2char(0xe612),
    \    'packages': nr2char(0xe612),
    \    'enum': nr2char(0xff702),
    \    'enummember': nr2char(0xf282),
    \    'enumerator': nr2char(0xff702),
    \    'module': nr2char(0xf136),
    \    'modules': nr2char(0xf136),
    \    'type': nr2char(0xff7fd),
    \    'typedef': nr2char(0xff7fd),
    \    'types': nr2char(0xff7fd),
    \    'field': nr2char(0xf30b),
    \    'fields': nr2char(0xf30b),
    \    'macro': nr2char(0xff8a3),
    \    'macros': nr2char(0xff8a3),
    \    'map': nr2char(0xffb44),
    \    'class': nr2char(0xf0e8),
    \    'augroup': nr2char(0xffb44),
    \    'struct': nr2char(0xf318),
    \    'union': nr2char(0xffacd),
    \    'member': nr2char(0xf02b),
    \    'target': nr2char(0xff893),
    \    'property': nr2char(0xffab6),
    \    'interface': nr2char(0xff7fe),
    \    'namespace': nr2char(0xf475),
    \    'subroutine': nr2char(0xff9af),
    \    'implementation': nr2char(0xff776),
    \    'typeParameter': nr2char(0xf278),
    \    'default': nr2char(0xf29c)
    \}

    function! s:nearestMethodOrFunction() abort
      return get(b:, 'vista_nearest_method_or_function', '')
    endfunction
    autocmd vimrc VimEnter * call vista#RunForNearestMethodOrFunction()

    " completion
    call minpac#add('prabirshrestha/vim-lsp')
    call minpac#add('prabirshrestha/asyncomplete.vim')
    call minpac#add('prabirshrestha/asyncomplete-lsp.vim')
    call minpac#add('mattn/vim-lsp-settings')
    call minpac#add('rhysd/vim-lsp-ale')

    function! s:on_lsp_buffer_enabled() abort
        setlocal omnifunc=lsp#complete
        setlocal tagfunc=lsp#tagfunc
        setlocal signcolumn=yes
        nmap <buffer> gd <plug>(lsp-definition)
        nmap <buffer> gr <plug>(lsp-references)
        nmap <buffer> gi <plug>(lsp-implementation)
        nmap <buffer> ge <plug>(lsp-type-definition)
        nmap <buffer> gR <plug>(lsp-rename)
        " nmap <buffer> g] <Plug>(lsp-next-diagnostic)
        " nmap <buffer> g[ <Plug>(lsp-previous-diagnostic)
        nmap <buffer> gA <Plug>(lsp-code-action)
        nmap <buffer> gs <Plug>(lsp-document-symbol-search)

        if &filetype !=# 'vim'
            nmap <buffer> K <plug>(lsp-hover)
        endif

        if &filetype ==# 'ruby'
            nnoremap <buffer><expr><silent> K lsp#internal#document_hover#under_cursor#do({'server': 'sorbet'})
        elseif &filetype ==# 'vue' || &filetype ==# 'typescript'
            " nnoremap <buffer><expr> gR lsp#ui#vim#rename({'server': 'typescript-language-server'})
            nnoremap <buffer><expr> gR lsp#ui#vim#rename({'server': 'vtsls'})
        endif
    endfunction

    augroup vimrc
      autocmd User lsp_buffer_enabled call s:on_lsp_buffer_enabled()
    augroup END
    command! LspDebug let lsp_log_verbose=1 | let lsp_log_file = expand('~/lsp.log')

    " let g:asyncomplete_auto_popup = 1
    " let g:asyncomplete_auto_completeopt = 0
    " let g:asyncomplete_popup_delay = 200

    " let g:lsp_inlay_hints_enabled = 1
    let g:lsp_experimental_workspace_folders = 1
    let g:lsp_use_native_client = 1
    let g:lsp_fold_enabled = 0 " for performance
    let g:lsp_code_action_ui = 'float'

    let g:lsp_settings_filetype_ruby = ['sorbet', 'ruby-lsp']
    " let g:lsp_settings_filetype_vue = ['typescript-language-server', 'volar-server']
    let g:lsp_settings_filetype_vue = ['vtsls', 'volar-server']
    let g:lsp_settings_filetype_typescript = ['vtsls']
    let g:lsp_settings_filetype_javascript = ['vtsls']
    let g:lsp_settings = {
    \   'sorbet': {
    \       'args': ['--watchman-path=/opt/homebrew/bin/watchman']
    \   },
    \}

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

    call minpac#add('github/copilot.vim')

    " linter
    call minpac#add('dense-analysis/ale')
    let g:ale_floating_preview = 1
    let g:ale_floating_window_border = ['│', '─', '┌', '┐', '┘', '└']
    let g:ale_virtualtext_cursor = 'disabled'
    let g:ale_linters_explicit = 1
    let g:ale_fix_on_save = 1
    let g:ale_fixers = {
    \   'javascript': ['eslint', 'prettier'],
    \   'typescript': ['eslint', 'prettier'],
    \   'typescriptreact': ['eslint', 'prettier'],
    \   'vue': ['eslint', 'stylelint', 'prettier'],
    \   'scss': ['stylelint', 'prettier'],
    \   'rust': ['rustfmt'],
    \   'go': ['gofmt'],
    \   'python': ['black', 'isort'],
    \   'ruby': ['rubocop'],
    \   'dart': ['dart-format'],
    \   'terraform': ['terraform']
    \}
    let g:ale_linters = {
    \   'javascript': ['eslint', 'cspell'],
    \   'typescript': ['eslint', 'cspell'],
    \   'typescriptreact': ['eslint', 'cspell'],
    \   'vue': ['eslint', 'stylelint', 'cspell'],
    \   'scss': ['stylelint', 'cspell'],
    \   'rust': ['clippy'],
    \   'proto': ['cspell'],
    \   'python': ['flake8', 'mypy'],
    \   'ruby': ['rubocop', 'cspell'],
    \   'dart': ['cspell'],
    \   'terraform': ['tflint']
    \}
    let g:ale_linter_aliases = {'vue': ['vue', 'typescript', 'scss']}

    let g:ale_ruby_rubocop_executable = 'bundle'
    let g:ale_python_auto_poetry = 1
    let g:ale_python_auto_pipenv = 1
    let g:ale_python_auto_virtualenv = 1
    let g:ale_cspell_use_global = 1

    nmap <C-K> <Plug>(ale_detail)
    nmap g] <Plug>(ale_next_error)
    nmap g} <Plug>(ale_next)
    nmap g[ <Plug>(ale_previous_error)
    nmap g{ <Plug>(ale_previous)
    set previewheight=5

    " documents
    call minpac#add('girishji/devdocs.vim')
    nmap [Prefix]d <Cmd>DevdocsFind<CR>

    " vital
    call minpac#add('vim-jp/vital.vim')

    " git
    call minpac#add('rhysd/committia.vim')
    let g:committia_hooks = {}
    function! g:committia_hooks.edit_open(info)
        setlocal spell
        setlocal spelllang=en,cjk
    endfunction

    " syntax
    call minpac#add('dag/vim-fish')
    call minpac#add('tmux-plugins/vim-tmux')
    call minpac#add('cespare/vim-toml')
    call minpac#add('hashivim/vim-terraform')

    call minpac#add('Shougo/context_filetype.vim')

    " test
    " call minpac#add('vim-test/vim-test')
endif

" load ghostty vimfiles
if exists('$GHOSTTY_RESOURCES_DIR')
   execute 'set runtimepath+=' .. $GHOSTTY_RESOURCES_DIR .. '/../vim/vimfiles'
end

" ==================== Others ==================== "
" FileType
augroup vimrc
    " golang
    autocmd FileType go setlocal noexpandtab

    " proto
    autocmd FileType proto setlocal tabstop=2 shiftwidth=2 softtabstop=2

    " JS
    autocmd FileType javascript setlocal tabstop=2 shiftwidth=2 softtabstop=2
    autocmd FileType html setlocal tabstop=2 shiftwidth=2 softtabstop=2
    autocmd FileType typescript,js,vue,css,scss setlocal tabstop=2 shiftwidth=2 softtabstop=2

    " Markdown
    autocmd FileType markdown setlocal conceallevel=0

    " direnv
    autocmd BufReadPost,BufNewFile .envrc,.env setlocal filetype=bash
augroup END

" JSON
let g:vim_json_conceal = 0

" TOhtml
let g:html_number_lines = 0
let g:html_use_css = 1
let g:use_xhtml = 1
let g:html_use_encoding = 'utf-8'

" cspell helper
let s:cspell_config_file = $HOME .. '/.cspell.json'
function! s:add_word_to_cspell() abort
    if !filewritable(s:cspell_config_file)
        echomsg 'Error: ' .. s:cspell_config_file .. ' is not writable.'
        return
    endif

    if !executable('jq')
        echomsg 'Error: jq is needed.'
        return
    endif

    let [_, loc] = ale#util#FindItemAtCursor(bufnr(''))
    if !has_key(loc, 'text')
        return
    endif
    let word = tolower(matchstr(loc.text, 'Unknown Word (\zs\w\+\ze)'))
    if empty(word)
        return
    endif

    let json = json_decode(join(readfile(s:cspell_config_file), ''))
    if index(json.words, word) != -1
        return
    endif
    let json.words = add(json.words, word)
    let json.words = sort(json.words)
    let jsonStr = system("echo '" .. json_encode(json) .. "' | jq .")
    call writefile(split(jsonStr, "\n"), s:cspell_config_file)
    echo word .. ' is added to ' .. s:cspell_config_file
endfunction
nmap [Prefix]c <Cmd>call <SID>add_word_to_cspell()<CR>


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

" load settings for each location.
function! s:vimrc_local(loc)
    let files = findfile('.vimrc.local', escape(a:loc, ' ') . ';', -1)
    for i in reverse(filter(files, 'filereadable(v:val)'))
        source `=i`
    endfor
endfunction
let g:lsp_settings_root_markers = [
\   '.git',
\   '.git/',
\   '.svn',
\   '.hg',
\   '.bzr'
\ ]
call s:vimrc_local(lsp_settings#root_path([]))

" im test
function! ImStatusFunc()
    let status = system('im-select')
    echo status
    if status == 'jp.sourceforge.inputmethod.aquaskk.Ascii'
        return 0
    endif
    return 1
endfunction
" set imstatusfunc=ImStatusFunc

function ImActivateFunc(active)
    if a:active
        call system('im-select jp.sourceforge.inputmethod.aquaskk.Hiragana')
    else
        call system('im-select jp.sourceforge.inputmethod.aquaskk.Ascii')
    endif
endfunction
" set imactivatefunc=ImActivateFunc

" secure
set secure
