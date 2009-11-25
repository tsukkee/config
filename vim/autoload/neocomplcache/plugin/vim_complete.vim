"=============================================================================
" FILE: vim_complete.vim
" AUTHOR:  Shougo Matsushita <Shougo.Matsu@gmail.com>
" Last Modified: 24 Nov 2009
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
" Version: 1.02, for Vim 7.0
"-----------------------------------------------------------------------------
" ChangeLog: "{{{
"   1.02:
"    - Implemented intellisense like prototype echo.
"    - Display kind.
"
"   1.01:
"    - Poweruped.
"    - Supported backslash.
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

function! neocomplcache#plugin#vim_complete#initialize()"{{{
    " Initialize.
    let s:internal_candidates_list = {}
    let s:global_candidates_list = {}
    let s:script_candidates_list = {}
    let s:completion_length = neocomplcache#get_completion_length('vim_complete')

    " Global caching.
    call s:global_caching()
    
    " Set caching event.
    autocmd neocomplcache FileType vim call s:script_caching_check()

    " Add command.
    command! -nargs=? -complete=buffer NeoComplCacheCachingVim call s:recaching(<q-args>)
endfunction"}}}

function! neocomplcache#plugin#vim_complete#finalize()"{{{
    delcommand NeoComplCacheCachingVim
endfunction"}}}

function! neocomplcache#plugin#vim_complete#get_keyword_list(cur_keyword_str)"{{{
    if &filetype != 'vim'
        return []
    endif

    let l:list = []
    
    let l:cur_text = neocomplcache#get_cur_text()
    let l:line = line('%')
    while l:cur_text =~ '^\s*\\' && l:line > 1
        let l:cur_text = getline(l:line - 1) . substitute(l:cur_text, '^\s*\\', '', '')
        let l:line -= 1
    endwhile

    if l:cur_text =~ '\<"'
        " Comment.
        return []
    endif
    
    let l:script_candidates_list = has_key(s:script_candidates_list, bufnr('%')) ?
                \ s:script_candidates_list[bufnr('%')] : { 'functions' : [], 'variables' : [] }


    if g:NeoComplCache_EnableDispalyParameter"{{{
        " Echo prototype.
        let l:prototype_name = matchstr(l:cur_text, '\%(<[sS][iI][dD]>\|[sSgGbBwWtTlL]:\)\=\%(\i\|[#.]\|{.\{-1,}}\)*\s*(\ze[^)].*$')
        if l:prototype_name != ''
            if has_key(s:internal_candidates_list.functions_prototype, l:prototype_name)
                echo s:internal_candidates_list.functions_prototype[l:prototype_name]
            elseif has_key(s:global_candidates_list.functions_prototype, l:prototype_name)
                echo s:global_candidates_list.functions_prototype[l:prototype_name]
            elseif has_key(l:script_candidates_list.functions_prototype, l:prototype_name)
                echo l:script_candidates_list.functions_prototype[l:prototype_name]
            endif
        else
            " Search command name.
            let l:prototype_name = matchstr(l:cur_text, '\<\h\w*')
            if has_key(s:internal_candidates_list.commands_prototype, l:prototype_name)
                echo s:internal_candidates_list.commands_prototype[l:prototype_name]
            elseif has_key(s:global_candidates_list.commands_prototype, l:prototype_name)
                echo s:global_candidates_list.commands_prototype[l:prototype_name]
            endif
        endif
    endif"}}}
    
    if l:cur_text =~ '\<\%(setl\%[ocal]\|setg\%[lobal]\|set\)\>'
        let l:list += s:internal_candidates_list.options
    elseif a:cur_keyword_str =~ '^&\%([gl]:\)\?'
        let l:prefix = matchstr(a:cur_keyword_str, '&\%([gl]:\)\?')
        let l:options = deepcopy(s:internal_candidates_list.options)
        for l:keyword in l:options
            let l:keyword.word = l:prefix . l:keyword.word
            let l:keyword.abbr = l:prefix . l:keyword.abbr
        endfor
        let l:list += l:options
    endif
    
    if l:cur_text =~ '\<has(''\h\w*$'
        let l:list += s:internal_candidates_list.features
    endif
    if l:cur_text =~ '\<map\|cm\%[ap]\|cno\%[remap]\|im\%[ap]\|ino\%[remap]\|lm\%[ap]\|ln\%[oremap]\|nm\%[ap]\|nn\%[oremap]\|no\%[remap]\|om\%[ap]\|ono\%[remap]\|smap\|snor\%[emap]\|vm\%[ap]\|vn\%[oremap]\|xm\%[ap]\|xn\%[oremap]\>'
        let l:list += s:internal_candidates_list.mappings
        let l:list += s:global_candidates_list.mappings
    endif
    if l:cur_text =~ '\<au\%[tocmd]!\?'
        let l:list += s:internal_candidates_list.autocmds
    endif
    if l:cur_text =~ '\<au\%[tocmd]!\?\s*\h\w*$\|\<aug\%[roup]'
        let l:list += s:global_candidates_list.augroups
    endif
    if l:cur_text =~ '\<com\%[mand]!\?\>'
        let l:list += s:internal_candidates_list.command_args
        let l:list += s:internal_candidates_list.command_replaces
    endif
    if l:cur_text =~ '\%(^\||sil\%[ent]!\?\)\s*\h\w*$'
        let l:list += s:internal_candidates_list.commands
        let l:list += s:global_candidates_list.commands
        
        if a:cur_keyword_str =~ '^en\%[d]'
            let l:list += s:get_endlist()
        endif
    else
        if l:cur_text !~ '\<let\s\+\a[[:alnum:]_:]*$'
            " Functions.
            if a:cur_keyword_str =~ '^s:'
                let l:list += l:script_candidates_list.functions
            elseif a:cur_keyword_str =~ '^\a:'
                let l:functions = deepcopy(l:script_candidates_list.functions)
                for l:keyword in l:functions
                    let l:keyword.word = '<SID>' . l:keyword.word[2:]
                    let l:keyword.abbr = '<SID>' . l:keyword.abbr[2:]
                endfor
                let l:list += l:functions
            else
                let l:list += s:internal_candidates_list.functions
                let l:list += s:global_candidates_list.functions
            endif
        endif
        
        if l:cur_text !~ '\<call\s\+\%(<[sS][iI][dD]>\|[sSgGbBwWtTlL]:\)\=\%(\i\|[#.]\|{.\{-1,}}\)*\s*(\?$'
            " Variables.
            if a:cur_keyword_str =~ '^s:'
                let l:list += l:script_candidates_list.variables
            elseif a:cur_keyword_str =~ '^\a:'
                let l:list += s:global_candidates_list.variables
            endif

            let l:list += s:get_localvariablelist()
        endif
    endif

    return neocomplcache#keyword_filter(l:list, a:cur_keyword_str)
endfunction"}}}

" Dummy function.
function! neocomplcache#plugin#vim_complete#calc_rank(cache_keyword_buffer_list)"{{{
    return
endfunction"}}}

function! neocomplcache#plugin#vim_complete#calc_prev_rank(cache_keyword_buffer_list, prev_word, prepre_word)"{{{
endfunction"}}}

function! s:global_caching()"{{{
    " Caching.

    let s:global_candidates_list.commands = s:get_cmdlist()
    let s:global_candidates_list.variables = s:get_variablelist()
    let s:global_candidates_list.functions = s:get_functionlist()
    let s:global_candidates_list.augroups = s:get_augrouplist()
    let s:global_candidates_list.mappings = s:get_mappinglist()

    let s:internal_candidates_list.functions = s:caching_from_dict('functions', 'f', 5)
    let s:internal_candidates_list.options = s:caching_from_dict('options', 'o', 10)
    let s:internal_candidates_list.features = s:caching_from_dict('features', '', 10)
    let s:internal_candidates_list.mappings = s:caching_from_dict('mappings', '', 10)
    let s:internal_candidates_list.commands = s:caching_from_dict('commands', 'c', 10)
    let s:internal_candidates_list.command_args = s:caching_from_dict('command_args', '', 10)
    let s:internal_candidates_list.autocmds = s:caching_from_dict('autocmds', '', 10)
    let s:internal_candidates_list.command_replaces = s:caching_from_dict('command_replaces', '', 10)

    let l:functions_prototype = {}
    for function in s:internal_candidates_list.functions
        let l:functions_prototype[function.word] = function.abbr
    endfor
    let s:internal_candidates_list.functions_prototype = l:functions_prototype
    
    let l:commands_prototype = {}
    for command in s:internal_candidates_list.commands
        let l:commands_prototype[command.word] = command.abbr
    endfor
    let s:internal_candidates_list.commands_prototype = l:commands_prototype
endfunction"}}}
function! s:script_caching_check()"{{{
    " Caching script candidates.
    
    let l:bufnumber = 1

    " Check buffer.
    while l:bufnumber <= bufnr('$')
        if getbufvar(l:bufnumber, '&filetype') == 'vim' && buflisted(l:bufnumber)
                    \&& !has_key(s:script_candidates_list, l:bufnumber)
            let s:script_candidates_list[l:bufnumber] = s:get_scriptcandidatelist(l:bufnumber)
        endif

        let l:bufnumber += 1
    endwhile
endfunction"}}}
function! s:recaching(bufname)"{{{
    " Caching script candidates.
    
    let l:bufnumber = a:bufname != '' ? bufnr(a:bufname) : bufnr('%')

    " Caching.
    let s:global_candidates_list.commands = s:get_cmdlist()
    let s:global_candidates_list.variables = s:get_variablelist()
    let s:global_candidates_list.functions = s:get_functionlist()
    let s:global_candidates_list.augroups = s:get_augrouplist()
    let s:global_candidates_list.mappings = s:get_mappinglist()
    
    if getbufvar(l:bufnumber, '&filetype') == 'vim' && buflisted(l:bufnumber)
        let s:script_candidates_list[l:bufnumber] = s:get_scriptcandidatelist(l:bufnumber)
    endif
endfunction"}}}

function! s:caching_from_dict(dict_name, kind, rank)"{{{
    let l:dict_files = split(globpath(&runtimepath, 'autoload/neocomplcache/plugin/vim_complete/'.a:dict_name.'.dict'), '\n')
    if empty(l:dict_files)
        return []
    endif

    let l:abbr_pattern = printf('%%.%ds..%%s', g:NeoComplCache_MaxKeywordWidth-10)
    let l:menu_pattern = '[V] '.a:dict_name[: -2]
    let l:keyword_pattern = '^\%('.neocomplcache#get_keyword_pattern('vim').'\m\)'
    let l:keyword_list = []
    for line in readfile(l:dict_files[-1])
        let l:word = matchstr(line, l:keyword_pattern)
        if len(l:word) > s:completion_length
            let l:keyword =  {
                        \ 'word' : l:word, 'menu' : l:menu_pattern, 'icase' : 1,
                        \ 'kind' : a:kind, 
                        \ 'rank' : a:rank, 'prev_rank' : a:rank, 'prepre_rank' : a:rank
                        \}
            let l:keyword.abbr =  (len(line) > g:NeoComplCache_MaxKeywordWidth)? 
                        \ printf(l:abbr_pattern, line, line[-8:]) : line

            call add(l:keyword_list, l:keyword)
        endif
    endfor

    return l:keyword_list
endfunction"}}}

function! s:get_cmdlist()"{{{
    " Get command list.
    redir => l:redir
    silent! command
    redir END
    
    let l:keyword_list = []
    let l:commands_prototype = {}
    let l:abbr_pattern = printf('%%.%ds..%%s', g:NeoComplCache_MaxKeywordWidth-10)
    let l:menu_pattern = '[V] command'
    for line in split(l:redir, '\n')[1:]
        let l:word = matchstr(line, '\a\w*')
        let l:keyword =  {
                    \ 'word' : l:word, 'menu' : l:menu_pattern, 'icase' : 1, 'kind' : 'c', 
                    \ 'rank' : 10, 'prev_rank' : 10, 'prepre_rank' : 10
                    \}
        let l:keyword.abbr =  (len(l:word) > g:NeoComplCache_MaxKeywordWidth)? 
                    \ printf(l:abbr_pattern, l:word, l:word[-8:]) : l:word

        call add(l:keyword_list, l:keyword)
        let l:commands_prototype[l:word] = l:word
    endfor
    let s:global_candidates_list.commands_prototype = l:commands_prototype
    
    return l:keyword_list
endfunction"}}}
function! s:get_variablelist()"{{{
    " Get variable list.
    redir => l:redir
    silent! let
    redir END
    
    let l:keyword_list = []
    let l:abbr_pattern = printf('%%.%ds..%%s', g:NeoComplCache_MaxKeywordWidth-10)
    let l:menu_pattern = '[V] variable'
    let l:kind_dict = ['0', '""', '()', '[]', '{}', '.']
    for line in split(l:redir, '\n')
        let l:word = matchstr(line, '^\a[[:alnum:]_:]*')
        if l:word !~ '^\a:'
            let l:word = 'g:' . l:word
        elseif l:word =~ '[^gv]:'
            continue
        endif
        let l:keyword =  {
                    \ 'word' : l:word, 'menu' : l:menu_pattern, 'icase' : 1,
                    \ 'kind' : exists(l:word)? l:kind_dict[type(eval(l:word))] : '', 
                    \ 'rank' : 5, 'prev_rank' : 5, 'prepre_rank' : 5
                    \}
        let l:keyword.abbr =  (len(l:word) > g:NeoComplCache_MaxKeywordWidth)? 
                    \ printf(l:abbr_pattern, l:word, l:word[-8:]) : l:word

        call add(l:keyword_list, l:keyword)
    endfor
    return l:keyword_list
endfunction"}}}
function! s:get_functionlist()"{{{
    " Get function list.
    redir => l:redir
    silent! function
    redir END
    
    let l:keyword_list = []
    let l:functions_prototype = {}
    let l:abbr_pattern = printf('%%.%ds..%%s', g:NeoComplCache_MaxKeywordWidth-10)
    let l:menu_pattern = '[V] function'
    let l:keyword_pattern = '^\%('.neocomplcache#get_keyword_pattern('vim').'\m\)'
    for l:line in split(l:redir, '\n')
        let l:line = l:line[9:]
        let l:orig_line = l:line
        let l:word = matchstr(l:line, l:keyword_pattern)
        if l:word =~ '^<SNR>\d\+_'
            continue
        endif
        let l:keyword =  {
                    \ 'word' : l:word, 'menu' : l:menu_pattern, 'icase' : 1,
                    \ 'rank' : 5, 'prev_rank' : 5, 'prepre_rank' : 5
                    \}
        if len(l:line) > g:NeoComplCache_MaxKeywordWidth
            let l:line = substitute(l:line, '\(\h\)\w*#', '\1.\~', 'g')
            if len(l:line) > g:NeoComplCache_MaxKeywordWidth
                let l:args = split(matchstr(l:line, '(\zs[^)]*\ze)'), '\s*,\s*')
                let l:line = substitute(l:line, '(\zs[^)]*\ze)', join(map(l:args, 'v:val[:5]'), ', '), '')
            endif
        endif
        if len(l:line) > g:NeoComplCache_MaxKeywordWidth
            let l:keyword.abbr = printf(l:abbr_pattern, l:line, l:line[-8:])
        else
            let keyword.abbr = l:line
        endif

        call add(l:keyword_list, l:keyword)
        
        let l:functions_prototype[l:word] = l:orig_line
    endfor
    
    let s:global_candidates_list.functions_prototype = l:functions_prototype
    
    return l:keyword_list
endfunction"}}}
function! s:get_augrouplist()"{{{
    " Get function list.
    redir => l:redir
    silent! augroup
    redir END
    
    let l:keyword_list = []
    let l:abbr_pattern = printf('%%.%ds..%%s', g:NeoComplCache_MaxKeywordWidth-10)
    let l:menu_pattern = '[V] augroup'
    for l:group in split(l:redir, '\s')
        let l:keyword =  {
                    \ 'word' : l:group, 'menu' : l:menu_pattern, 'icase' : 1,
                    \ 'rank' : 10, 'prev_rank' : 10, 'prepre_rank' : 10
                    \}
            let l:keyword.abbr =  (len(l:group) > g:NeoComplCache_MaxKeywordWidth)? 
                        \ printf(l:abbr_pattern, l:group, l:group[-8:]) : l:group

        call add(l:keyword_list, l:keyword)
    endfor
    return l:keyword_list
endfunction"}}}
function! s:get_mappinglist()"{{{
    " Get function list.
    redir => l:redir
    silent! map
    redir END
    
    let l:keyword_list = []
    let l:abbr_pattern = printf('%%.%ds..%%s', g:NeoComplCache_MaxKeywordWidth-10)
    let l:menu_pattern = '[V] mapping'
    for line in split(l:redir, '\n')
        let l:map = matchstr(line, '^\a*\s*\zs\S\+')
        if l:map !~ '^<'
            continue
        endif
        let l:keyword =  {
                    \ 'word' : l:map, 'menu' : l:menu_pattern, 'icase' : 1,
                    \ 'rank' : 10, 'prev_rank' : 10, 'prepre_rank' : 10
                    \}
            let l:keyword.abbr =  (len(l:map) > g:NeoComplCache_MaxKeywordWidth)? 
                        \ printf(l:abbr_pattern, l:map, l:map[-8:]) : l:map

        call add(l:keyword_list, l:keyword)
    endfor
    return l:keyword_list
endfunction"}}}
function! s:get_localvariablelist()"{{{
    " Get local variable list.
    
    let l:keyword_dict = {}
    let l:abbr_pattern = printf('%%.%ds..%%s', g:NeoComplCache_MaxKeywordWidth-10)
    let l:menu_pattern = '[V] variable'

    " Search function.
    let l:line_num = line('.') - 1
    let l:end_line = (line('.') < 100) ? line('.') - 100 : 1
    while l:line_num >= l:end_line
        let l:line = getline(l:line_num)
        if l:line =~ '\<endf\%[nction]\>'
            break
        elseif l:line =~ '\<fu\%[nction]!\?\s\+'
            " Get function arguments.
            for l:arg in split(matchstr(l:line, '^[^(]*(\zs[^)]*'), '\s*,\s*')
                let l:word = 'a:' . (l:arg == '...' ?  '000' : l:arg)
                let l:keyword =  {
                            \ 'word' : l:word, 'menu' : l:menu_pattern, 'icase' : 1,
                            \ 'kind' : '', 
                            \ 'rank' : 5, 'prev_rank' : 5, 'prepre_rank' : 5
                            \}
                let l:keyword.abbr =  (len(l:word) > g:NeoComplCache_MaxKeywordWidth)? 
                            \ printf(l:abbr_pattern, l:word, l:word[-8:]) : l:word

                let l:keyword_dict[l:word] = l:keyword
            endfor
            break
        endif
        
        let l:line_num -= 1
    endwhile
    let l:line_num += 1
    
    let l:end_line = line('.') - 1
    while l:line_num <= l:end_line
        let l:line = getline(l:line_num)
        
        if l:line =~ '\<\%(let\|for\)\s\+\a[[:alnum:]_:]*'
            let l:word = matchstr(l:line, '\<\%(let\|for\)\s\+\zs\a[[:alnum:]_:]*')
            if !has_key(l:keyword_dict, l:word) 
                let l:expression = matchstr(l:line, '\<let\s\+\a[[:alnum:]_:]*\s*=\zs.*$')
                let l:keyword =  {
                            \ 'word' : l:word, 'menu' : l:menu_pattern, 'icase' : 1,
                            \ 'kind' : s:get_variable_type(l:expression), 
                            \ 'rank' : 5, 'prev_rank' : 5, 'prepre_rank' : 5
                            \}
                let l:keyword.abbr =  (len(l:word) > g:NeoComplCache_MaxKeywordWidth)? 
                            \ printf(l:abbr_pattern, l:word, l:word[-8:]) : l:word

                let l:keyword_dict[l:word] = l:keyword
            endif
        endif

        let l:line_num += 1
    endwhile
    
    return values(l:keyword_dict)
endfunction"}}}
function! s:get_endlist()"{{{
    " Get end command list.
    
    let l:keyword_dict = {}
    let l:abbr_pattern = printf('%%.%ds..%%s', g:NeoComplCache_MaxKeywordWidth-10)
    let l:menu_pattern = '[V] end'
    let l:line_num = line('.') - 1
    let l:end_line = (line('.') < 100) ? line('.') - 100 : 1
    let l:cnt = {
                \ 'endfor' : 0, 'endfunction' : 0, 'endtry' : 0, 
                \ 'endwhile' : 0, 'endif' : 0
                \}
    let l:word = ''
    
    while l:line_num >= l:end_line
        let l:line = getline(l:line_num)
        
        if l:line =~ '\<endfo\%[r]\>'
            let l:cnt['endfor'] -= 1
        elseif l:line =~ '\<endf\%[nction]\>'
            let l:cnt['endfunction'] -= 1
        elseif l:line =~ '\<endt\%[ry]\>'
            let l:cnt['endtry'] -= 1
        elseif l:line =~ '\<endw\%[hile]\>'
            let l:cnt['endwhile'] -= 1
        elseif l:line =~ '\<en\%[dif]\>'
            let l:cnt['endif'] -= 1
            
        elseif l:line =~ '\<for\>'
            let l:cnt['endfor'] += 1
            if l:cnt['endfor'] > 0
                let l:word = 'endfor'
                break
            endif
        elseif l:line =~ '\<fu\%[nction]!\?\s\+'
            let l:cnt['endfunction'] += 1
            if l:cnt['endfunction'] > 0
                let l:word = 'endfunction'
            endif
            break
        elseif l:line =~ '\<try\>'
            let l:cnt['endtry'] += 1
            if l:cnt['endtry'] > 0
                let l:word = 'endtry'
                break
            endif
        elseif l:line =~ '\<wh\%[ile]\>'
            let l:cnt['endwhile'] += 1
            if l:cnt['endwhile'] > 0
                let l:word = 'endwhile'
                break
            endif
        elseif l:line =~ '\<if\>'
            let l:cnt['endif'] += 1
            if l:cnt['endif'] > 0
                let l:word = 'endif'
                break
            endif
        endif
                    
        let l:line_num -= 1
    endwhile
    
    if l:word == ''
        return []
    else
        let l:keyword =  {
                    \ 'word' : l:word, 'menu' : l:menu_pattern, 'icase' : 1,
                    \ 'kind' : 'c', 
                    \ 'rank' : 20, 'prev_rank' : 20, 'prepre_rank' : 20
                    \}
        let l:keyword.abbr =  (len(l:word) > g:NeoComplCache_MaxKeywordWidth)? 
                    \ printf(l:abbr_pattern, l:word, l:word[-8:]) : l:word

        return [l:keyword]
    endif
endfunction"}}}
function! s:get_scriptcandidatelist(bufnumber)"{{{
    " Get script candidate list.
    
    let l:function_dict = {}
    let l:variable_dict = {}
    let l:functions_prototype = {}
    
    let l:abbr_pattern = printf('%%.%ds..%%s', g:NeoComplCache_MaxKeywordWidth-10)
    let l:menu_pattern_func = '[V] function'
    let l:menu_pattern_var = '[V] variable'
    let l:keyword_pattern = '^\%('.neocomplcache#get_keyword_pattern('vim').'\m\)'
    
    if g:NeoComplCache_CachingPercentInStatusline
        let l:statusline_save = &l:statusline
        let &l:statusline = 'Caching vim from '. bufname(a:bufnumber) .' ... please wait.'
        redrawstatus
    else
        redraw
        echo 'Caching vim from '. bufname(a:bufnumber) .' ... please wait.'
    endif
    
    for l:line in getbufline(a:bufnumber, 1, '$')
        if l:line =~ '\<fu\%[nction]!\?\s\+s:'
            " Get script function.
            let l:line = substitute(matchstr(l:line, '\<fu\%[nction]!\?\s\+\zs.*'), '".*$', '', '')
            let l:orig_line = l:line
            let l:word = matchstr(l:line, l:keyword_pattern)
            if !has_key(l:function_dict, l:word) 
                let l:keyword =  {
                            \ 'word' : l:word, 'menu' : l:menu_pattern_func, 'icase' : 1,
                            \ 'kind' : 'f', 
                            \ 'rank' : 5, 'prev_rank' : 5, 'prepre_rank' : 5
                            \}
                if len(l:line) > g:NeoComplCache_MaxKeywordWidth
                    let l:line = substitute(l:line, '\(\h\)\w*#', '\1.\~', 'g')
                    if len(l:line) > g:NeoComplCache_MaxKeywordWidth
                        let l:args = split(matchstr(l:line, '(\zs[^)]*\ze)'), '\s*,\s*')
                        let l:line = substitute(l:line, '(\zs[^)]*\ze)', join(map(l:args, 'v:val[:5]'), ', '), '')
                    endif
                endif
                if len(l:word) > g:NeoComplCache_MaxKeywordWidth
                    let l:keyword.abbr = printf(l:abbr_pattern, l:word, l:word[-8:])
                else
                    let keyword.abbr = l:word
                endif

                let l:function_dict[l:word] = l:keyword
                let l:functions_prototype[l:word] = l:orig_line
            endif
        elseif l:line =~ '\<let\s\+s:*'
            " Get script variable.
            let l:word = matchstr(l:line, '\<let\s\+\zs\a[[:alnum:]_:]*')
            if !has_key(l:variable_dict, l:word) 
                let l:expression = matchstr(l:line, '\<let\s\+\a[[:alnum:]_:]*\s*=\zs.*$')
                let l:keyword =  {
                            \ 'word' : l:word, 'menu' : l:menu_pattern_var, 'icase' : 1,
                            \ 'kind' : s:get_variable_type(l:expression), 
                            \ 'rank' : 5, 'prev_rank' : 5, 'prepre_rank' : 5
                            \}
                let l:keyword.abbr =  (len(l:word) > g:NeoComplCache_MaxKeywordWidth)? 
                            \ printf(l:abbr_pattern, l:word, l:word[-8:]) : l:word

                let l:variable_dict[l:word] = l:keyword
            endif
        endif
    endfor
    
    if g:NeoComplCache_CachingPercentInStatusline
        let &l:statusline = l:statusline_save
        redrawstatus
    else
        redraw
        echo ''
        redraw
    endif
    
    return { 'functions' : values(l:function_dict), 'variables' : values(l:variable_dict), 'functions_prototype' : l:functions_prototype }
endfunction"}}}
function! s:get_variable_type(expression)"{{{
    " Analyze variable type.
    if a:expression =~ '\s*\d\+\.\d\+'
        return '.'
    elseif a:expression =~ '\s*\d\+'
        return '0'
    elseif a:expression =~ '\s*["'']'
        return '""'
    elseif a:expression =~ '\<function('
        return '()'
    elseif a:expression =~ '\s*\['
        return '[]'
    elseif a:expression =~ '\s*{'
        return '{}'
    else
        return ''
    endif
endfunction"}}}
" vim: foldmethod=marker
