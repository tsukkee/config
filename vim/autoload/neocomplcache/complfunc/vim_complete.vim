"=============================================================================
" FILE: vim_complete.vim
" AUTHOR:  Shougo Matsushita <Shougo.Matsu@gmail.com>
" Last Modified: 26 Apr 2010
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
"=============================================================================

function! neocomplcache#complfunc#vim_complete#initialize()"{{{
  " Initialize.
  let s:completion_length = neocomplcache#get_completion_length('vim_complete')

  " Set caching event.
  autocmd neocomplcache FileType vim call neocomplcache#complfunc#vim_complete#helper#on_filetype()

  " Add command.
  command! -nargs=? -complete=buffer NeoComplCacheCachingVim call neocomplcache#complfunc#vim_complete#helper#recaching(<q-args>)
endfunction"}}}

function! neocomplcache#complfunc#vim_complete#finalize()"{{{
  delcommand NeoComplCacheCachingVim
endfunction"}}}

function! neocomplcache#complfunc#vim_complete#get_keyword_pos(cur_text)"{{{
  if &filetype != 'vim'
    return -1
  endif

  let l:cur_text = neocomplcache#complfunc#vim_complete#get_cur_text()

  if l:cur_text =~ '^\s*"'
    " Comment.
    return -1
  endif

  let l:pattern = '\.$\|' . neocomplcache#get_keyword_pattern_end('vim')
  let l:cur_keyword_pos = match(a:cur_text, l:pattern)

  if g:NeoComplCache_EnableWildCard
    " Check wildcard.
    let l:cur_keyword_pos = neocomplcache#match_wildcard(a:cur_text, l:pattern, l:cur_keyword_pos)
  endif

  return l:cur_keyword_pos
endfunction"}}}

function! neocomplcache#complfunc#vim_complete#get_complete_words(cur_keyword_pos, cur_keyword_str)"{{{
  if (neocomplcache#is_auto_complete() && a:cur_keyword_str != '.'
        \&& len(a:cur_keyword_str) < s:completion_length)
        \|| a:cur_keyword_str =~ '^\.'
    return []
  endif

  let l:list = []
  let l:cur_text = neocomplcache#complfunc#vim_complete#get_cur_text()
  let l:command = neocomplcache#complfunc#vim_complete#get_command(l:cur_text)
  if a:cur_keyword_str =~ '^&\%([gl]:\)\?'
    " Options.
    let l:prefix = matchstr(a:cur_keyword_str, '&\%([gl]:\)\?')
    let l:options = deepcopy(neocomplcache#complfunc#vim_complete#helper#option(l:cur_text, a:cur_keyword_str))
    for l:keyword in l:options
      let l:keyword.word = l:prefix . l:keyword.word
      let l:keyword.abbr = l:prefix . l:keyword.abbr
    endfor
    let l:list += l:options
  elseif l:cur_text =~ '\<has(''\h\w*$'
    " Features.
    let l:list += neocomplcache#complfunc#vim_complete#helper#feature(l:cur_text, a:cur_keyword_str)
  elseif l:cur_text =~ '^\$'
    " Environment.
    let l:list += neocomplcache#complfunc#vim_complete#helper#environment(l:cur_text, a:cur_keyword_str)
  endif

  if l:cur_text =~ '^[[:digit:],[:space:]$''<>]*\h\w*$'
    " Commands.
    let l:list += neocomplcache#complfunc#vim_complete#helper#command(l:cur_text, a:cur_keyword_str)
  else
    " Commands args.
    let l:list += neocomplcache#complfunc#vim_complete#helper#get_command_completion(l:command, l:cur_text, a:cur_keyword_str)
  endif

  return neocomplcache#keyword_filter(l:list, a:cur_keyword_str)
endfunction"}}}

function! neocomplcache#complfunc#vim_complete#get_rank()"{{{
  return 100
endfunction"}}}

function! neocomplcache#complfunc#vim_complete#get_cur_text()"{{{
  let l:cur_text = neocomplcache#get_cur_text()
  let l:line = line('%')
  while l:cur_text =~ '^\s*\\' && l:line > 1
    let l:cur_text = getline(l:line - 1) . substitute(l:cur_text, '^\s*\\', '', '')
    let l:line -= 1
  endwhile

  return l:cur_text
endfunction"}}}
function! neocomplcache#complfunc#vim_complete#get_command(cur_text)"{{{
  return matchstr(a:cur_text, '\<\%(\d\+\)\?\zs\h\w*\ze!\?\|\<\%([[:digit:],[:space:]$''<>]\+\)\?\zs\h\w*\ze/.*')
endfunction"}}}

" vim: foldmethod=marker
