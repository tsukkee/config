" ku source: source
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
let s:the_old_input_pattern = ''








" Interface  "{{{1
function! ku#source#available_sources()  "{{{2
  return ['source']
endfunction




function! ku#source#on_source_enter(source_name_ext)  "{{{2
  let s:cached_items = map(copy(ku#available_sources()), '{"word": v:val}')
  let s:the_old_input_pattern = ku#set_the_current_input_pattern('')
endfunction




function! ku#source#on_source_leave(source_name_ext)  "{{{2
  call ku#set_the_current_input_pattern(s:the_old_input_pattern)
endfunction




function! ku#source#action_table(source_name_ext)  "{{{2
  return {
  \   'default': 'ku#source#action_open',
  \   'open': 'ku#source#action_open',
  \ }
endfunction




function! ku#source#key_table(source_name_ext)  "{{{2
  return {
  \   "\<C-o>": 'open',
  \   'o': 'open',
  \ }
endfunction




function! ku#source#gather_items(source_name_ext, pattern)  "{{{2
  return s:cached_items
endfunction




function! ku#source#special_char_p(source_name_ext, character)  "{{{2
  return 0
endfunction








" Misc.  "{{{1
" Actions  "{{{2
function! ku#source#action_open(item)  "{{{3
  let source = a:item.word  " FIXME: How about if this source is unavailable?
  call ku#start(source, s:the_old_input_pattern)
  return
endfunction








" __END__  "{{{1
" vim: foldmethod=marker
