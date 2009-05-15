" ku source: mrucommand
" Version: 0.0.1
" Copyright (C) 2009 tsukkee <http://relaxedcolumn.blog8.fc2.com/>
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

let s:TYPES = {'cmd': ':', 'search': '/'}








" Interface  "{{{1
function! ku#mrucommand#available_sources() "{{{2
  return ['mrucommand']
endfunction








function! ku#mrucommand#action_table(source_name_ext) "{{{2
  return {
  \   'default': 'ku#mrucommand#execute',
  \   'execute': 'ku#mrucommand#execute',
  \   'input': 'ku#mrucommand#input',
  \ }
endfunction




function! ku#mrucommand#key_table(source_name_ext) "{{{2
  return {
  \   'i': 'input',
  \ }
endfunction




function! ku#mrucommand#gather_items(source_name_ext, pattern) "{{{2
  let _ = []
  for [type, prefix] in items(s:TYPES)
    let n = histnr(type)
    for i in range(0, n)
      let cmd = histget(type, i)
      if(cmd != "")
        call add(_, {
        \      'word': prefix . cmd,
        \      'menu': type,
        \      'ku__sort_priority': - i
        \    })
      endif
    endfor
  endfor
  return _
endfunction








" Misc {{{1
" Actions {{{2
function! ku#mrucommand#execute(item) "{{{3
  call feedkeys(a:item.word . "\<CR>", 'n')
endfunction




function! ku#mrucommand#input(item) "{{{3
  call feedkeys(a:item.word, 'n')
endfunction








" __END__  "{{{1
" vim:foldmethod=marker:ts=2:sw=2:sts=0:
