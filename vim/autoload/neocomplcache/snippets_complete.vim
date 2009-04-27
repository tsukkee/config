"=============================================================================
" FILE: syntax_complete.vim
" AUTHOR:  Shougo Matsushita <Shougo.Matsu@gmail.com>
" Last Modified: 24 Apr 2009
" Usage: Just source this file.
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
" Version: 1.10, for Vim 7.0
"-----------------------------------------------------------------------------
" ChangeLog: "{{{
"   1.10:
"    - Implemented snipMate like snippet.
"    - Added syntax file.
"    - Detect snippet file.
"    - Fixed default value selection bug.
"   1.09:
"    - Added syntax highlight.
"    - Implemented neocomplcache#snippets_complete#expandable().
"    - Change menu when expandable snippet.
"    - Implemented g:NeoComplCache_SnippetsDir.
"   1.08:
"    - Fixed place holder's default value bug.
"   1.07:
"    - Increment rank when snippet expanded.
"    - Use selection.
"   1.06:
"    - Improved place holder's default value behaivior.
"   1.05:
"    - Implemented place holder.
"   1.04:
"    - Implemented <Plug>(neocomplcache_snippets_expand) keymapping.
"   1.03:
"    - Optimized caching.
"   1.02:
"    - Caching snippets file.
"   1.01:
"    - Refactoring.
"   1.00:
"    - Initial version.
" }}}
"-----------------------------------------------------------------------------
" TODO: "{{{
"     - Nothing.
""}}}
" Bugs"{{{
"     - Nothing.
""}}}
"=============================================================================

let s:begin_snippet = 0
let s:end_snippet = 0

function! neocomplcache#snippets_complete#initialize()"{{{
    " Initialize.
    let s:snippets = {}
    let s:begin_snippet = 0
    let s:end_snippet = 0
    let s:snippet_holder_cnt = 1

    " Set snippets dir.
    let s:snippets_dir = split(globpath(&runtimepath, 'autoload/neocomplcache/snippets_complete'), '\n')
    if exists('g:NeoComplCache_SnippetsDir') && isdirectory(g:NeoComplCache_SnippetsDir)
        call insert(s:snippets_dir, g:NeoComplCache_SnippetsDir)
    endif

    augroup neocomplecache"{{{
        " Caching events
        autocmd CursorHold * call s:caching_event() 
        " Recaching events
        autocmd BufWritePost *.snip call s:caching_snippets(expand('<afile>:t:r')) 
        " Detect syntax file.
        autocmd BufNew,BufRead *.snip setfiletype snippet
    augroup END"}}}

    command! -nargs=? NeoCompleCacheEditSnippets call s:edit_snippets(<q-args>)

    syn match   NeoCompleCacheExpandSnippets         '<expand>\|<\\n>\|\${\d\+\%(:\([^}]*\)\)\?}'
    hi def link NeoCompleCacheExpandSnippets Special
endfunction"}}}

function! neocomplcache#snippets_complete#finalize()"{{{
    delcommand NeoCompleCacheEditSnippets
    hi clear NeoCompleCacheExpandSnippets
endfunction"}}}

function! neocomplcache#snippets_complete#get_keyword_list(cur_keyword_str)"{{{
    if empty(&filetype) || !has_key(s:snippets, &filetype)
        return []
    endif

    return s:keyword_filter(copy(s:snippets[&filetype]), a:cur_keyword_str)
endfunction"}}}

" Dummy function.
function! neocomplcache#snippets_complete#calc_rank(cache_keyword_buffer_list)"{{{
    return
endfunction"}}}

function! neocomplcache#snippets_complete#calc_prev_rank(cache_keyword_buffer_list, prev_word, prepre_word)"{{{
    " Calc previous rank.
    for keyword in a:cache_keyword_buffer_list
        " Set prev rank.
        let keyword.prev_rank = has_key(keyword.prev_word, a:prev_word)? 10+keyword.rank/2 : 0
    endfor
endfunction"}}}

function! neocomplcache#snippets_complete#expandable()"{{{
    return match(getline('.'), '<expand>') >= 0 || search('\${\d\+\%(:\([^}]*\)\)\?}', 'w') > 0
endfunction"}}}

function! s:keyword_filter(list, cur_keyword_str)"{{{
    let l:keyword_escape = neocomplcache#keyword_escape(a:cur_keyword_str)

    " Keyword filter."{{{
    let l:cur_len = len(a:cur_keyword_str)
    if g:NeoComplCache_PartialMatch && !neocomplcache#skipped() && len(a:cur_keyword_str) >= g:NeoComplCache_PartialCompletionStartLength
        " Partial match.
        let l:pattern = printf("v:val.name =~ '%s'", l:keyword_escape)
    else
        " Head match.
        let l:pattern = printf("v:val.name =~ '^%s'", l:keyword_escape)
    endif"}}}

    let l:list = filter(a:list, l:pattern)
    for keyword in l:list
        let keyword.word = keyword.word_save
        while keyword.word =~ '`.*`'
            let keyword.word = substitute(keyword.word, '`[^`]*`', 
                        \eval(matchstr(keyword.word_save, '`\zs.*\ze`')), '')
        endwhile
    endfor
    return l:list
endfunction"}}}

function! s:set_snippet_pattern(dict)"{{{
    let l:abbr_pattern = printf('%%.%ds..%%s', g:NeoComplCache_MaxKeywordWidth-10)

    let l:word = a:dict.word
    if match(a:dict.word, '\${\d\+\%(:\(.*\)\)\?}\|<\\n>') >= 0
        let l:word .= '<expand>'
        let l:menu_pattern = '<Snip> %.'.g:NeoComplCache_MaxFilenameWidth.'s'
    else
        let l:menu_pattern = '[Snip] %.'.g:NeoComplCache_MaxFilenameWidth.'s'
    endif
    let l:abbr = has_key(a:dict, 'abbr')? a:dict.abbr : a:dict.word
    let l:rank = has_key(a:dict, 'rank')? a:dict.rank : 5
    let l:prev_word = {}
    if has_key(a:dict, 'prev_word')
        for l:prev in a:dict.prev_word
            let l:prev_word[l:prev] = 1
        endfor
    endif

    let l:dict = {
                \'word_save' : l:word, 'name' : a:dict.name, 
                \'menu' : printf(l:menu_pattern, a:dict.name), 
                \'prev_word' : l:prev_word, 
                \'rank' : l:rank, 'prev_rank' : 0, 'prepre_rank' : 0
                \}
    let l:dict.abbr_save = 
                \ (len(l:abbr) > g:NeoComplCache_MaxKeywordWidth)? 
                \ printf(l:abbr_pattern, l:abbr, l:abbr[-8:]) : l:abbr
    return l:dict
endfunction"}}}

function! s:caching_event()"{{{
    if empty(&filetype) || has_key(s:snippets, &filetype)
        return
    endif

    call s:caching_snippets(&filetype)
endfunction"}}}
function! s:edit_snippets(filetype)"{{{
    if empty(a:filetype)
        if empty(&filetype)
            echo 'Filetype required'
            return
        endif
        
        let l:filetype = &filetype
    else
        let l:filetype = a:filetype
    endif

    if !empty(s:snippets_dir)
        " Edit snippet file.
        edit `=s:snippets_dir[0].'/'.l:filetype.'.snip'`
    endif
endfunction"}}}

function! s:caching_snippets(filetype)"{{{
    let s:snippets[a:filetype] = []
    let l:snippets_files = split(globpath(join(s:snippets_dir, ','), a:filetype .  '.snip'), '\n')
    for snippets_file in l:snippets_files
        call extend(s:snippets[a:filetype], s:load_snippets(snippets_file))
    endfor
endfunction"}}}

function! s:load_snippets(snippets_file)"{{{
    let l:snippet = []
    let l:snippet_pattern = { 'word' : '' }
    for line in readfile(a:snippets_file)
        if line =~ '^include'
            " Include snippets.
            let l:filetype = matchstr(line, '^\s*include\s\+\zs\h\w*')
            let l:snippets_files = split(globpath(join(s:snippets_dir, ','), l:filetype .  '.snip'), '\n')
            for snippets_file in l:snippets_files
                call extend(l:snippet, s:load_snippets(snippets_file))
            endfor
        elseif line =~ '^snippet\s'
            if has_key(l:snippet_pattern, 'name')
                call add(l:snippet, s:set_snippet_pattern(l:snippet_pattern))
                let l:snippet_pattern = { 'word' : '' }
            endif
            let l:snippet_pattern.name = matchstr(line, '^snippet\s\+\zs.*\ze$')
        elseif line =~ '^abbr\s'
            let l:snippet_pattern.abbr = matchstr(line, '^abbr\s\+\zs.*\ze$')
        elseif line =~ '^rank\s'
            let l:snippet_pattern.rank = matchstr(line, '^rank\s\+\zs\d\+\ze\s*$')
        elseif line =~ '^prev_word\s'
            let l:snippet_pattern.prev_word = []
            for word in split(matchstr(line, '^prev_word\s\+\zs.*\ze$'), ',')
                call add(l:snippet_pattern.prev_word, matchstr(word, "'\\zs[^']*\\ze'"))
            endfor
        elseif line =~ '^\s'
            if empty(l:snippet_pattern['word'])
                let l:snippet_pattern.word = matchstr(line, '^\s\+\zs.*\ze$')
            else
                let l:snippet_pattern.word .= '<\n>' . matchstr(line, '^\s\+\zs.*\ze$')
            endif
        endif
    endfor

    if has_key(l:snippet_pattern, 'name')
        call add(l:snippet, s:set_snippet_pattern(l:snippet_pattern))
    endif

    return l:snippet
endfunction"}}}

function! s:snippets_expand()"{{{
    syn match   NeoCompleCacheExpandSnippets         '<expand>\|<\\n>\|\${\d\+\%(:\([^}]*\)\)\?}'

    if match(getline('.'), '<expand>') >= 0
        call s:expand_newline()
        return
    endif

    if !s:search_snippet_range(s:begin_snippet, s:end_snippet)
        " Not found.
        let s:begin_snippet = 0
        let s:end_snippet = 0
        let s:snippet_holder_cnt = 1

        call s:search_outof_range()
    endif
endfunction"}}}
function! s:expand_newline()"{{{
    " Check expand word.
    if !empty(&filetype) && has_key(s:snippets, &filetype)
        let l:expand = matchstr(getline('.'), '^.*<expand>')
        for keyword in s:snippets[&filetype]
            if keyword.word_save !~ '`[^`]*`' &&
                        \l:expand =~ substitute(escape(keyword.word_save, '" \.^$*[]'), "'", "''", 'g').'$'
                let keyword.rank += 1
                break
            endif
        endfor
    endif

    " Substitute expand marker.
    silent! s/<expand>//

    let l:match = match(getline('.'), '<\\n>')
    let s:begin_snippet = line('.')
    let s:end_snippet = line('.')

    while l:match >= 0
        " Substitute CR.
        silent! s/<\\n>//

        " Return.
        call setpos('.', [0, line('.'), l:match, 0])
        silent execute "normal! a\<CR>"

        " Next match.
        let l:match = match(getline('.'), '<\\n>')
        let s:end_snippet += 1
    endwhile

    let s:snippet_holder_cnt = 1
    call s:search_snippet_range(s:begin_snippet, s:end_snippet)
endfunction"}}}
function! s:search_snippet_range(start, end)"{{{
    let l:line = a:start
    let l:pattern = '\${'.s:snippet_holder_cnt.'\%(:\([^}]*\)\)\?}'
    let l:pattern2 = '\${'.s:snippet_holder_cnt.':\zs[^}]*\ze}'

    while l:line <= a:end
        let l:match = match(getline(l:line), l:pattern)
        if l:match > 0
            let l:match_len2 = len(matchstr(getline(l:line), l:pattern2))

            " Substitute holder.
            silent! execute l:line.'s/'.l:pattern.'/\1/'
            call setpos('.', [0, line('.'), l:match, 0])
            if l:match_len2 > 0
                " Select default value.
                let l:len = l:match_len2-1
                if &l:selection == "exclusive"
                    let l:len += 1
                endif

                if l:len == 0
                    execute "normal! lv\<C-g>"
                else
                    execute "normal! lv".l:len."l\<C-g>"
                endif
            elseif col('.') < col('$')-1
                normal! l
                startinsert
            else
                startinsert!
            endif

            " Next count.
            let s:snippet_holder_cnt += 1
            return 1
        endif

        " Next line.
        let l:line += 1
    endwhile

    return 0
endfunction"}}}
function! s:search_outof_range()"{{{
    if search('\${\d\+\%(:\([^}]*\)\)\?}', 'w') > 0
        let l:match = match(getline('.'), '\${\d\+\%(:\([^}]*\)\)\?}')
        let l:match_len2 = len(matchstr(getline('.'), '\${\d\+:\zs[^}]*\ze}'))

        " Substitute holder.
        silent! s/\${\d\+\%(:\(.*\)\)\?}/\1/
        call setpos('.', [0, line('.'), l:match, 0])
        if l:match_len2 > 0
            " Select default value.
            let l:len = l:match_len2-1
            if &l:selection == "exclusive"
                let l:len += 1
            endif

            if l:len == 0
                execute "normal! lv\<C-g>"
            else
                execute "normal! lv".l:len."l\<C-g>"
            endif

            return
        endif
    endif

    if col('.') < col('$')-1
        normal! l
        startinsert
    else
        startinsert!
    endif
endfunction"}}}

" Plugin key-mappings.
inoremap <silent> <Plug>(neocomplcache_snippets_expand)  <ESC>:<C-u>call <SID>snippets_expand()<CR>
snoremap <silent> <Plug>(neocomplcache_snippets_expand)  <C-g>:<C-u>call <SID>snippets_expand()<CR>

" vim: foldmethod=marker
