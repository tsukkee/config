" ku source: quickfix
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
function! ku#quickfix#available_sources()  "{{{2
  return ['quickfix']
endfunction




function! ku#quickfix#on_source_enter(source_name_ext)  "{{{2
  let qflist = getqflist()
    " [[error number, buffer number, number of errors in the buffer], ...]
  let _ = map(range(len(qflist)), '[v:val+1, qflist[v:val].bufnr, 1]')
  let i = 0
  while i + 1 < len(_)
    while i + 1 < len(_) && _[i][1] == _[i+1][1]
      call remove(_, i+1)
      let _[i][2] += 1
    endwhile
    let i += 1
  endwhile

  let s:cached_items = map(_, '{
  \   "word": bufname(v:val[1]),
  \   "menu": v:val[2] . " error" . (v:val[2] == 1 ? "" : "s"),
  \   "ku_quickfix_bufnr": v:val[1],
  \   "ku_quickfix_ccnr": v:val[0],
  \ }')
endfunction




function! ku#quickfix#action_table(source_name_ext)  "{{{2
  return {
  \   'default': 'ku#quickfix#action_open',
  \   'open!': 'ku#quickfix#action_open_x',
  \   'open': 'ku#quickfix#action_open',
  \ }
endfunction




function! ku#quickfix#key_table(source_name_ext)  "{{{2
  return {
  \   "\<C-o>": 'open',
  \   'O': 'open!',
  \   'o': 'open',
  \ }
endfunction




function! ku#quickfix#gather_items(source_name_ext, pattern)  "{{{2
  return s:cached_items
endfunction




function! ku#quickfix#special_char_p(source_name_ext, character)  "{{{2
  return 0
endfunction








" Misc.  "{{{1
function! s:open(bang, item)  "{{{2
  if a:item.ku__completed_p
    let original_switchbuf = &switchbuf
      let &switchbuf = ''
      execute 'cc'.a:bang a:item.ku_quickfix_ccnr
    let &switchbuf = original_switchbuf
    return 0
  else
    return 'No such file: ' . string(a:item.word)
  endif
endfunction




" Actions  "{{{2
function! ku#quickfix#action_open(item)  "{{{3
  return s:open('', a:item)
endfunction


function! ku#quickfix#action_open_x(item)  "{{{3
  return s:open('!', a:item)
endfunction








" __END__  "{{{1
" vim: foldmethod=marker
