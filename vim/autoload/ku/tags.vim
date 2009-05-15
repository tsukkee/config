" ku source: tags
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

let s:cached_items = []








" Interface  "{{{1
function! ku#tags#available_sources() "{{{2
  return ['tags', 'tags/help']
endfunction




function! ku#tags#on_source_enter(source_name_ext)  "{{{2
  let saved_buftype = &l:buftype
  if a:source_name_ext == "help"
    let &l:buftype = "help"
  endif

  let _ = []
  for tagfile in s:Unique(tagfiles())
    for line in readfile(tagfile)
      let [word, file] = split(line, "\t")[0:1]
      if stridx(word, "!") != 0
        call add(_, {
        \      'word': word,
        \      'menu': file,
        \      'dup': 1,
        \      '_ext': a:source_name_ext,
        \    })
      endif
    endfor
  endfor
  let s:cached_items = _

  let &l:buftype = saved_buftype
endfunction




function! ku#tags#action_table(source_name_ext) "{{{2
  return {
  \   'default': 'ku#tags#lookup',
  \   'lookup': 'ku#tags#lookup',
  \   'input': 'ku#tags#input',
  \ }
endfunction




function! ku#tags#key_table(source_name_ext) "{{{2
  return {
  \   'i': 'input',
  \ }
endfunction




function! ku#tags#gather_items(source_name_ext, pattern) "{{{2
  " for small tagfile
  if len(s:cached_items) < g:ku_tags_limit_for_filtering
    return s:cached_items

  " for huge tagfile
  else
    if empty(a:pattern)
      return []
    endif
      
    let pattern = filter(split(a:pattern, " "), "!empty(v:val)")[0]
    " heading matching for short word
    if len(pattern) < g:ku_tags_matching_threshold
      return filter(copy(s:cached_items), "v:val.word =~# '^'.pattern")

    " global matching for long word
    else
      return filter(copy(s:cached_items), "v:val.word =~# pattern")
    endif
  endif
endfunction




function! ku#tags#special_char_p(source_name_ext, char)  "{{{2
  return len(s:cached_items) >= g:ku_tags_limit_for_filtering
endfunction








" Misc {{{1
" from fuzzyfinder.vim
function! s:Unique(in)
  let sorted = sort(a:in)
  if len(sorted) < 2
    return sorted
  endif
  let last = remove(sorted, 0)
  let result = [last]
  for item in sorted
    if item != last
      call add(result, item)
      let last = item
    endif
  endfor
  return result
endfunction




" Variables {{{2
if !exists('g:ku_tags_matching_threshold')
  let g:ku_tags_matching_threshold = 2
endif

if !exists('g:ku_tags_limit_for_filtering')
  let g:ku_tags_limit_for_filtering = 1000
endif




" Actions {{{2
" TODO: help!, tjump, stjump etc..
function! ku#tags#lookup(item) "{{{3
  let command = a:item._ext == "help" ? "help " : "tjump "
  execute command . a:item.word
endfunction




function! ku#tags#input(item) "{{{3
  let command = a:item._ext == "help" ? ":help " : ":tjump "
  call feedkeys(command . a:item.word, 'n')
endfunction








" __END__  "{{{1
" vim:foldmethod=marker:ts=2:sw=2:sts=0:
