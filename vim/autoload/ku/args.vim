" ku source: args
" Version: 0.1.1
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
function! ku#args#available_sources()  "{{{2
  return ['args']
endfunction




function! ku#args#on_source_enter(source_name_ext)  "{{{2
  let s:cached_items = map(argv(), '{"word": v:val}')
  if 0 < argc()
    let s:cached_items[argidx()].menu = '*'
  endif
endfunction




function! ku#args#action_table(source_name_ext)  "{{{2
  return {
  \   'argdelete': 'ku#args#action_argdelete',
  \   'default': 'ku#args#action_open',
  \   'open!': 'ku#args#action_open_x',
  \   'open': 'ku#args#action_open',
  \ }
endfunction




function! ku#args#key_table(source_name_ext)  "{{{2
  return {
  \   "\<C-o>": 'open',
  \   'D': 'argdelete',
  \   'O': 'open!',
  \   'o': 'open',
  \ }
endfunction




function! ku#args#gather_items(source_name_ext, pattern)  "{{{2
  return s:cached_items
endfunction




function! ku#args#special_char_p(source_name_ext, character)  "{{{2
  return 0
endfunction








" Misc.  "{{{1
function! s:open(bang, item)  "{{{2
  let bufnr = bufnr(fnameescape(a:item.word))
  if bufnr != -1
    execute bufnr 'buffer'.a:bang
    return 0
  else
    return 'No such buffer: ' . string(a:item.word)
  endif
endfunction




" Actions  "{{{2
function! ku#args#action_open(item)  "{{{3
  return s:open('', a:item)
endfunction


function! ku#args#action_open_x(item)  "{{{3
  return s:open('!', a:item)
endfunction


function! ku#args#action_argdelete(item)  "{{{3
  let v:errmsg = ''
  silent! execute 'argdelete' fnameescape(a:item.word)
  return v:errmsg == '' ? 0 : v:errmsg
endfunction








" __END__  "{{{1
" vim: foldmethod=marker
