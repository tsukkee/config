"=============================================================================
" FILE: tags_complete.vim
" AUTHOR:  Shougo Matsushita <Shougo.Matsu@gmail.com>
" Last Modified: 26 Oct 2009
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
"    - Enable auto-complete.
"    - Optimized.
"
"   1.09:
"    - Supported neocomplcache 3.0.
"
"   1.08:
"    - Improved popup menu.
"    - Ignore case.
"
"   1.07:
"    - Fixed for neocomplcache 2.43.
"
"   1.06:
"    - Improved abbr.
"    - Refactoring.
"
"   1.05:
"    - Improved filtering.
"
"   1.04:
"    - Don't return static member.
"
"   1.03:
"    - Optimized memory.
"
"   1.02:
"    - Escape input keyword.
"    - Supported camel case completion.
"    - Fixed echo.
"
"   1.01:
"    - Not caching.
"
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

function! neocomplcache#plugin#tags_complete#initialize()"{{{
    " Initialize
    let s:tags_list = {}
    
    " Create cache directory.
    if !isdirectory(g:NeoComplCache_TemporaryDir . '/tags_cache')
        call mkdir(g:NeoComplCache_TemporaryDir . '/tags_cache', 'p')
    endif
endfunction"}}}

function! neocomplcache#plugin#tags_complete#finalize()"{{{
endfunction"}}}

function! neocomplcache#plugin#tags_complete#get_keyword_list(cur_keyword_str)"{{{
    if len(a:cur_keyword_str) < g:NeoComplCache_TagsCompletionStartLength
        return []
    endif

    let l:list = []
    let l:key = tolower(a:cur_keyword_str[: g:NeoComplCache_TagsCompletionStartLength-1])
    for tags in split(&l:tags, ',')
        let l:filename = fnamemodify(tags, ':p')
        if filereadable(l:filename)
            if !has_key(s:tags_list, l:filename)
                let s:tags_list[l:filename] = s:initialize_tags(l:filename)
            endif
            if !has_key(s:tags_list[l:filename], l:key)
                let s:tags_list[l:filename][l:key] = []
            endif
            
            let l:list += s:tags_list[l:filename][l:key]
        endif
    endfor
    
    return neocomplcache#keyword_filter(l:list, a:cur_keyword_str)
endfunction"}}}

" Dummy function.
function! neocomplcache#plugin#tags_complete#calc_rank(cache_keyword_buffer_list)"{{{
endfunction"}}}

" Dummy function.
function! neocomplcache#plugin#tags_complete#calc_prev_rank(cache_keyword_buffer_list, prev_word, prepre_word)"{{{
endfunction"}}}

function! s:initialize_tags(filename)"{{{
    " Initialize tags list.

    let l:keyword_lists = s:load_from_cache(a:filename)
    if !empty(l:keyword_lists)
        return l:keyword_lists
    endif
    
    let l:abbr_pattern = printf('%%.%ds..%%s', g:NeoComplCache_MaxKeywordWidth-10)
    let l:menu_pattern = '[T] %.'. g:NeoComplCache_MaxFilenameWidth . 's'
    let l:dup_check = {}
    let l:lines = readfile(a:filename)
    let l:max_lines = len(l:lines)
    
    if l:max_lines > 1000
        redraw
        echo 'Caching tags... please wait.'
    endif
    if l:max_lines > 10000
        let l:print_cache_percent = l:max_lines / 9
    elseif l:max_lines > 5000
        let l:print_cache_percent = l:max_lines / 6
    elseif l:max_lines > 3000
        let l:print_cache_percent = l:max_lines / 5
    elseif l:max_lines > 2000
        let l:print_cache_percent = l:max_lines / 4
    elseif l:max_lines > 1000
        let l:print_cache_percent = l:max_lines / 3
    elseif l:max_lines > 500
        let l:print_cache_percent = l:max_lines / 2
    else
        let l:print_cache_percent = -1
    endif
    let l:line_cnt = l:print_cache_percent
    
    let l:line_num = 1
    for l:line in l:lines"{{{
        " Percentage check."{{{
        if l:line_cnt == 0
            if g:NeoComplCache_CachingPercentInStatusline
                let &l:statusline = printf('Caching: %d%%', l:line_num*100 / l:max_lines)
                redrawstatus!
            else
                redraw
                echo printf('Caching: %d%%', l:line_num*100 / l:max_lines)
            endif
            let l:line_cnt = l:print_cache_percent
        endif
        let l:line_cnt -= 1"}}}
        
        let l:tag = split(l:line, "\<Tab>")
        " Add keywords.
        if l:line !~ '^!' && len(l:tag[0]) >= g:NeoComplCache_MinKeywordLength
            let l:option = {}
            let l:match = matchlist(l:line, '.*\t.*\t/^\(.*\)/;"\t\(\a\)\(.*\)')
            if empty(l:match)
                let l:match = split(l:line, '\t')
                let [l:option['cmd'], l:option['kind'], l:opt] = [l:match[2], l:match[3], join(l:match[4:], '\t')]
            else
                let [l:option['cmd'], l:option['kind'], l:opt] = [l:match[1], l:match[2], l:match[3]]
            endif
            for op in split(l:opt, '\t')
                let l:key = matchstr(op, '^\h\w*\ze:')
                let l:option[l:key] = matchstr(op, '^\h\w*:\zs.*')
            endfor
            
            if has_key(l:option, 'file') || (has_key(l:option, 'access') && l:option.access != 'public')
                        \|| has_key(l:dup_check, l:tag[0])
                let l:line_num += 1
                continue
            endif
            let l:dup_check[l:tag[0]] = 1
            
            let l:abbr = (l:tag[3] == 'd')? l:tag[0] :
                        \ substitute(substitute(substitute(l:tag[2], '^/\^\=\s*\|\$\=/;"$', '', 'g'),
                        \           '\s\+', ' ', 'g'), '\\/', '/', 'g')
            let l:keyword = {
                        \ 'word' : l:tag[0], 'rank' : 5, 'prev_rank' : 0, 'prepre_rank' : 0, 'icase' : 1,
                        \ 'abbr' : (len(l:abbr) > g:NeoComplCache_MaxKeywordWidth)? 
                        \   printf(l:abbr_pattern, l:abbr, l:abbr[-8:]) : l:abbr, 
                        \ 'kind' : l:option['kind']
                        \}
            if has_key(l:option, 'struct')
                let keyword.menu = printf(l:menu_pattern, l:option.struct)
            elseif has_key(l:option, 'class')
                let keyword.menu = printf(l:menu_pattern, l:option.class)
            elseif has_key(l:option, 'enum')
                let keyword.menu = printf(l:menu_pattern, l:option.enum)
            else
                let keyword.menu = '[T]'
            endif

            let l:key = tolower(l:keyword.word[: g:NeoComplCache_TagsCompletionStartLength-1])
            if !has_key(l:keyword_lists, l:key)
                let l:keyword_lists[l:key] = []
            endif
            call add(l:keyword_lists[l:key], l:keyword)
        endif

        let l:line_num += 1
    endfor"}}}

    if l:max_lines > 200
        call s:save_cache(a:filename, l:keyword_lists)
    endif
    
    if l:max_lines > 1000
        if g:NeoComplCache_CachingPercentInStatusline
            let &l:statusline = l:statusline_save
            redrawstatus
        else
            redraw
            echo ''
            redraw
        endif
    endif
    
    return l:keyword_lists
endfunction"}}}
function! s:load_from_cache(filename)"{{{
    let l:cache_name = g:NeoComplCache_TemporaryDir . '/tags_cache/' .
                \substitute(substitute(a:filename, ':', '=-', 'g'), '[/\\]', '=+', 'g') . '='
    if getftime(l:cache_name) == -1 || getftime(l:cache_name) <= getftime(a:filename)
        return {}
    endif
    
    let l:keyword_lists = {}
    let l:lines = readfile(l:cache_name)
    let l:max_lines = len(l:lines)
    
    if l:max_lines > 3000
        redraw
        echo 'Caching tags... please wait.'
    endif
    if l:max_lines > 10000
        let l:print_cache_percent = l:max_lines / 5
    elseif l:max_lines > 5000
        let l:print_cache_percent = l:max_lines / 4
    elseif l:max_lines > 3000
        let l:print_cache_percent = l:max_lines / 3
    else
        let l:print_cache_percent = -1
    endif
    let l:line_cnt = l:print_cache_percent
    
    let l:line_num = 1
    for l:line in l:lines"{{{
        " Percentage check."{{{
        if l:line_cnt == 0
            if g:NeoComplCache_CachingPercentInStatusline
                let &l:statusline = printf('Caching: %d%%', l:line_num*100 / l:max_lines)
                redrawstatus!
            else
                redraw
                echo printf('Caching: %d%%', l:line_num*100 / l:max_lines)
            endif
            let l:line_cnt = l:print_cache_percent
        endif
        let l:line_cnt -= 1"}}}
        
        let l:cache = split(l:line, '!!!', 1)
        let l:keyword = {
                    \ 'word' : l:cache[0], 'rank' : 5, 'prev_rank' : 0, 'prepre_rank' : 0, 'icase' : 1,
                    \ 'abbr' : l:cache[1], 'menu' : l:cache[2], 'kind' : l:cache[3]
                    \}

        let l:key = tolower(l:keyword.word[: g:NeoComplCache_TagsCompletionStartLength-1])
        if !has_key(l:keyword_lists, l:key)
            let l:keyword_lists[l:key] = []
        endif
        call add(l:keyword_lists[l:key], l:keyword)
        
        let l:line_num += 1
    endfor"}}}
    
    if l:max_lines > 3000
        if g:NeoComplCache_CachingPercentInStatusline
            let &l:statusline = l:statusline_save
            redrawstatus
        else
            redraw
            echo ''
            redraw
        endif
    endif
    
    return l:keyword_lists
endfunction"}}}
function! s:save_cache(filename, keyword_lists)"{{{
    let l:cache_name = g:NeoComplCache_TemporaryDir . '/tags_cache/' .
                \substitute(substitute(a:filename, ':', '=-', 'g'), '[/\\]', '=+', 'g') . '='

    " Output tags.
    let l:word_list = []
    for keyword_list in values(a:keyword_lists)
        for keyword in keyword_list
            call add(l:word_list, printf('%s!!!%s!!!%s!!!%s', keyword.word, keyword.abbr, keyword.menu, keyword.kind))
        endfor
    endfor
    call writefile(l:word_list, l:cache_name)
endfunction"}}}

" Global options definition."{{{
if !exists('g:NeoComplCache_TagsCompletionStartLength')
    let g:NeoComplCache_TagsCompletionStartLength = 2
endif
"}}}

" vim: foldmethod=marker
