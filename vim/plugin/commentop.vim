" =============================================================================
" commentop.vim - commands and operators to comment/uncomment lines
"=============================================================================
"
" Author:  Takahiro SUZUKI <takahiro.suzuki.ja@gmDELETEMEail.com>
" Version: 1.1.0 (Vim 7.1)
" Licence: MIT Licence
" URL:     http://www.vim.org/scripts/script.php?script_id=2708
"
"=============================================================================
" Document: {{{1
"
"-----------------------------------------------------------------------------
" Description:
"   This plugin provides a set of commands and operators  to comment or
"   uncomment lines. Linewise comment token (such as double quote in vim
"   script) is detected automatically by looking up filetype of the file.
"   Filetypes working well by default:
"     vim, python, perl, ruby, haskell, sh, bash, zsh, java, javascript,
"     Makefile, tex
"   With definition in this script, these also work:
"     (c), cpp, csharp, php, matlab
"
"   You can also easily define your own comment token for filetype. Add below
"   in your .vimrc:
"     CommentopSetCommentType FILETYPE REMOVEPATTERN INSERTSTRING
"
"   plugin keymaps:
"     <Plug>CommentopToggleNV    " (n/v) toggle comment [count] or visual lines
"     <Plug>CommentopAppendNV    " (n/v) comment out [count] or visual lines
"     <Plug>CommentopRemoveNV    " (n/v) uncomment [count] or visual lines
"
"     <Plug>CommentopToggleOP    " (n op) toggle comment {motion}
"     <Plug>CommentopAppendOP    " (n op) comment out {motion}
"     <Plug>CommentopRemoveOP    " (n op) uncomment {motion}Re
"
"   default mapping:
"     co       <Plug>CommentopToggleNV
"     cO       <Plug>CommentopAppendNV
"     c<C-O>   <Plug>CommentopRemoveNV
"
"     go       <Plug>CommentopToggleOP
"     gO       <Plug>CommentopAppendOP
"     g<C-O>   <Plug>CommentopRemoveOP
"
"-----------------------------------------------------------------------------
" Installation:
"   Place this file in /usr/share/vim/vim*/plugin or ~/.vim/plugin/
"
"-----------------------------------------------------------------------------
" Examples:
"   in normal mode:
"      co          " toggle comment for this line
"      3cO         " comment out 3 lines
"
"   in normal mode (operator):
"      goip        " toggle comment for this paragraph
"      gOa{        " comment out this {} block
"
"   in visual mode:
"      c<C-O>      " remove comments in visual selection
"
"-----------------------------------------------------------------------------
" ChangeLog:
"   1.1.0:
"     - simplified <Plug> maps (no backward compatibility for 1.0.2 or before)
"     - determine the comment string automatically (using 'commentstring')
"   1.0.2:
"     - bug fix (wrong comment string with ft=vim)
"   1.0.1:
"     - bug fix (gO was mapped to comment out operator)
"   1.0:
"     - Initial release
"
"-----------------------------------------------------------------------------
" Special Thanks:
"   Andy Woukla
"
" }}}1
"=============================================================================

function! s:CountHeadSpace()
  let p = getpos('.')
  if p[2]==1 | return 0 | endif
  let line = getline('.')[0:p[2]-2]
  let len = 0
  while len < strlen(line)
    if line[len]=~"[ \<TAB>]" | let len += 1 | else | break | endif
  endwhile
  return len
endfunction


"mode 0:off 1:on 2:toggle
function! s:Comment(mode, count)
  " determine the comment type
  if has_key(s:comment_types, &ft)
    let commentmatch = s:comment_types[&ft]['match']
    let commentinsertstr = s:comment_types[&ft]['insert']
  else
    " generate it from filetype
    let pat = split(&commentstring, '%s') " something linke '#%s'
    if len(pat)==1
      let commentmatch = '^' . pat[0] . "[ \<TAB>]\\{,1}"
      let commentinsertstr = pat[0] . ' '
      let s:comment_types[&ft] = {'match': commentmatch, 'insert': commentinsertstr}
    else
      return
    endif
  endif

  let c = a:count
  " count head spaces
  normal! ^
  let p = getpos('.')
  let mh = -1
  while c>0
    let hs = s:CountHeadSpace()
    if hs<mh || mh==-1 | let mh = hs | endif
    normal! j
    let c -= 1
  endwhile
  " insert/remove comments
  call setpos('.', p)
  let c = a:count
  while c>0
    let iscomment = getline('.')[mh :] =~ commentmatch
    let prevstr = (mh>0) ? getline('.')[0:mh-1] : ''
    if a:mode==0 || (a:mode==2 && iscomment)
      " remove
      call setline('.', prevstr . substitute(getline('.')[mh :], commentmatch, '', ''))
    else
      " insert
     call setline('.', prevstr . commentinsertstr . getline('.')[mh :])
    endif
    normal! j
    let c -= 1
  endwhile
  call setpos('.', p)
endfunction

" normal / visual mode
function! s:LinewiseComment(mode)
  if exists('s:lastmode') && s:lastmode =~ "[vV\<C-V>]"
    call s:Comment(a:mode, getpos("'>")[1]-getpos("'<")[1]+1)
  else
    call s:Comment(a:mode, v:count1)
  endif
endfunction

" toggle / append / remove comment operator
function! s:SetCommentMode(mode)
  let s:commentmode = a:mode
endfunction
function! s:LinewiseCommentOperator(type)
  call s:Comment(s:commentmode, getpos("']")[1]-getpos("'[")[1]+1)
endfunction

" save mode
function! <SID>SaveMode()
  let s:lastmode = mode()
  return ':'
endfunction
noremap <expr> <SID>: <SID>SaveMode()

" function and command to set the comment type from file type
let s:comment_types = {}
function! s:SetCommentType(...)
  " 1:filetype, 2:match, 3:insert
  let s:comment_types[a:1] = {'match': a:2, 'insert': a:3}
endfunction

" We do not need this for most filetypes because v1.2.0 or later
" determines it automatically from &comments.
" If you want to override the default comment string, adding like these:
"   :CommentopSetCommentType vim       ^\"[\ <TAB>]\\{,1}   "\ 
"   :CommentopSetCommentType python    ^#[\ <TAB>]\\{,1}    #\ 
" in your .vimrc will do.
command! -nargs=* CommentopSetCommentType :call s:SetCommentType(<f-args>)

CommentopSetCommentType cpp        ^//[\ <TAB>]\\{,1}   //\ 
CommentopSetCommentType cs         ^//[\ <TAB>]\\{,1}   //\ 
CommentopSetCommentType matlab     ^%[\ <TAB>]\\{,1}    %\ 
CommentopSetCommentType php        ^//[\ <TAB>]\\{,1}   //\ 
" not correct, but for pragmatism:
CommentopSetCommentType c          ^//[\ <TAB>]\\{,1}   //\ 

" default keymaps (you can override this in your .vimrc)
if !hasmapto('<Plug>CommentopToggleNV', 'nv')
  map  co     <Plug>CommentopToggleNV
endif
if !hasmapto('<Plug>CommentopAppendNV', 'nv')
  map  cO     <Plug>CommentopAppendNV
endif
if !hasmapto('<Plug>CommentopRemoveNV', 'nv')
  map  c<C-O> <Plug>CommentopRemoveNV
endif
if !hasmapto('<Plug>CommentopToggleOP', 'n')
  nmap go     <Plug>CommentopToggleOP
endif
if !hasmapto('<Plug>CommentopAppendOP', 'n')
  nmap gO     <Plug>CommentopAppendOP
endif
if !hasmapto('<Plug>CommentopRemoveOP', 'n')
  nmap g<C-O> <Plug>CommentopRemoveOP
endif

" === plugin keymaps
" normal and visual
noremap <script><silent> <Plug>CommentopRemoveNV <SID>:<C-U>call <SID>LinewiseComment(0)<CR>
noremap <script><silent> <Plug>CommentopAppendNV <SID>:<C-U>call <SID>LinewiseComment(1)<CR>
noremap <script><silent> <Plug>CommentopToggleNV <SID>:<C-U>call <SID>LinewiseComment(2)<CR>

" operator
nnoremap <script><silent> <Plug>CommentopRemoveOP <SID>:<C-U>call <SID>SetCommentMode(0)<CR>:set opfunc=<SID>LinewiseCommentOperator<CR>g@
nnoremap <script><silent> <Plug>CommentopAppendOP <SID>:<C-U>call <SID>SetCommentMode(1)<CR>:set opfunc=<SID>LinewiseCommentOperator<CR>g@
nnoremap <script><silent> <Plug>CommentopToggleOP <SID>:<C-U>call <SID>SetCommentMode(2)<CR>:set opfunc=<SID>LinewiseCommentOperator<CR>g@

