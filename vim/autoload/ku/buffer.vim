" ku source: buffer
" Version: 0.1.0
" Copyright (C) 2008-2009 kana <http://whileimautomaton.net/>
" License: MIT license  {{{
"     Permission is hereby granted, free of charge, to any person obtaining
"     a copy of this software and associated documentation files (the
"     "Software"), to deal in the Software without restriction, including
"     without limitation the rights to use, copy, modify, merge, publish,
"     distribute, sublicense, and/or sell copies of the Software, and to
"     permit persons to whom the Software is furnished to do so, subject to
"     the following conditions:
"
"     The above copyright notice and this permission notice shall be included
"     in all copies or substantial portions of the Software.
"
"     THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
"     OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
"     MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
"     IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
"     CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
"     TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
"     SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
" }}}
" Variables  "{{{1

let s:cached_items = []








" Interface  "{{{1
function! ku#buffer#available_sources()  "{{{2
  return ['buffer']
endfunction




function! ku#buffer#on_source_enter(source_name_ext)  "{{{2
  " FIXME: better caching
  let _ = []
  for i in range(1, bufnr('$'))
    if bufexists(i) && buflisted(i)
      let bufname = bufname(i)
      call add(_, {
      \      'word': bufname,
      \      'menu': printf('buffer %*d', len(bufnr('$')), i),
      \      'dup': 1,
      \      'ku_buffer_nr': i,
      \      'ku__sort_priority': bufname ==# fnamemodify(bufname, ':p')
      \    })
    endif
  endfor
  let s:cached_items = _
endfunction




function! ku#buffer#action_table(source_name_ext)  "{{{2
  return {
  \   'default': 'ku#buffer#action_open',
  \   'delete': 'ku#buffer#action_delete',
  \   'open!': 'ku#buffer#action_open_x',
  \   'open': 'ku#buffer#action_open',
  \   'unload': 'ku#buffer#action_unload',
  \   'wipeout': 'ku#buffer#action_wipeout',
  \ }
endfunction




function! ku#buffer#key_table(source_name_ext)  "{{{2
  return {
  \   "\<C-o>": 'open',
  \   'D': 'delete',
  \   'O': 'open!',
  \   'U': 'unload',
  \   'W': 'wipeout',
  \   'o': 'open',
  \ }
endfunction




function! ku#buffer#gather_items(source_name_ext, pattern)  "{{{2
  return s:cached_items
endfunction




function! ku#buffer#special_char_p(source_name_ext, character)  "{{{2
  return 0
endfunction








" Misc.  "{{{1
function! s:open(bang, item)  "{{{2
  if a:item.ku__completed_p
    execute a:item.ku_buffer_nr 'buffer'.a:bang
  else
    execute 'edit'.a:bang fnameescape(a:item.word)
  endif
endfunction




function! s:delete(delete_command, item)  "{{{2
  if a:item.ku__completed_p
    execute a:item.ku_buffer_nr a:delete_command
  else
    echoerr 'No such buffer:' string(a:item.word)
  endif
endfunction




" Actions  "{{{2
function! ku#buffer#action_delete(item)  "{{{3
  call s:delete('bdelete', a:item)
  return
endfunction


function! ku#buffer#action_open(item)  "{{{3
  call s:open('', a:item)
  return
endfunction


function! ku#buffer#action_open_x(item)  "{{{3
  call s:open('!', a:item)
  return
endfunction


function! ku#buffer#action_unload(item)  "{{{3
  call s:delete('bunload', a:item)
  return
endfunction


function! ku#buffer#action_wipeout(item)  "{{{3
  call s:delete('bwipeout', a:item)
  return
endfunction








" __END__  "{{{1
" vim: foldmethod=marker
