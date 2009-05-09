" ku source: mrufile
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
" Interface  "{{{1
function! ku#mrufile#available_sources() "{{{2
  return ['mrufile']
endfunction




function! ku#mrufile#action_table(source_name_ext) "{{{2
  return ku#file#action_table(a:source_name_ext)
endfunction




function! ku#mrufile#key_table(source_name_ext) "{{{2
  return ku#file#key_table(a:source_name_ext)
endfunction




function! ku#mrufile#gather_items(source_name_ext, pattern) "{{{2
  return s:mrufile_load()
endfunction








" Misc {{{1
function! ku#mrufile#add()
  call s:mrufile_add()
endfunction




" Variables {{{2
if !exists('g:ku_mrufile_size')
  let g:ku_mrufile_size = 100
endif

let s:PATH_SEP = exists('+shellslash') && &shellslash ? '\' : '/'
let s:MRUFILE_FILE = 'info/ku/mrufile'




" Utilities {{{2
function! s:mrufile_file() "{{{3
  return split(&runtimepath, ',')[0] . s:PATH_SEP . s:MRUFILE_FILE
endfunction




function! s:mrufile_load() "{{{3
  let _ = []
  let file = s:mrufile_file()
  if filereadable(file)
    for line in readfile(file, '', g:ku_mrufile_size)
      let [word, _time] = split(line, '\t')
      if filereadable(word) || isdirectory(word)
        call add(_, {
        \      'word': word,
        \      'abbr': fnamemodify(word, ':~:.'), 
        \      'menu': getftype(word),
        \      '_time': _time,
        \      'ku__sort_priority': - str2nr(_time),
        \    })
      endif
    endfor
  endif
  return _
endfunction




function! s:mrufile_save(list) "{{{3
  let file = s:mrufile_file()
  let directory = fnamemodify(file, ':h')
  if !isdirectory(directory)
    call mkdir(directory, 'p')
  endif

  call writefile(map(a:list, 'v:val.word ."\t". v:val._time'), file)
endfunction




function! s:mrufile_add() "{{{3
  let new_word = expand("%:p")

  if !empty(&buftype) || expand('%') !~ '\S'
    return
  endif

  let _ = s:mrufile_load()
  call filter(_, 'v:val.word != new_word')
  call insert(_, {
  \      'word': new_word,
  \      '_time': localtime(),
  \    })
  call s:mrufile_save(_)
endfunction








" __END__  "{{{1
" vim: foldmethod=marker ts=2 sw=2 sts=0
