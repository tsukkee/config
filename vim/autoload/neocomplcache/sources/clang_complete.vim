" original: http://github.com/Rip-Rip/clang_complete

" File: clang_complete.vim
" Author: Xavier Deguillard <deguilx@gmail.com>
" Modified by: eagletmt <eagletmt@gmail.com>
"
" Description: Use of clang to complete in C/C++.
"
" Configuration: Each project can have a .clang_complete at his root,
"                containing the compiler options. This is useful if
"                you're using some non-standard include paths.
"                For simplicity, please don't put relative and
"                absolute include path on the same line. It is not
"                currently correctly handled.
"
" Options: g:clang_complete_copen: if equal to 1, open quickfix window
"                                  on error. WARNING: segfault on
"                                  unpatched vim!
"                                  Default: 0
"
" Todo: - Fix bugs
"       - Add snippets on Pattern and OVERLOAD (is it possible?)
"

let s:source = {
      \ 'name': 'clang_complete',
      \ 'kind': 'ftplugin',
      \ 'filetypes': { 'c': 1, 'cpp': 1, 'objc': 1, 'objcpp': 1 },
      \ }

function s:ClangCompleteInit()
    let b:should_overload = 0

    let l:local_conf = findfile(".clang_complete", '.;')
    let b:clang_user_options = ''
    if l:local_conf != ""
        let l:opts = readfile(l:local_conf)
        for l:opt in l:opts
            " Better handling of absolute path
            " I don't know if those pattern will work on windows
            " platform
            if matchstr(l:opt, '-I\s*/') != ""
                let l:opt = substitute(l:opt, '-I\s*\(/\%(\w\|\\\s\)*\)',
                            \ '-I' . '\1', "g")
            else
                let l:opt = substitute(l:opt, '-I\s*\(\%(\w\|\\\s\)*\)',
                            \ '-I' . l:local_conf[:-16] . '\1', "g")
            endif
            let b:clang_user_options .= " " . l:opt
        endfor
    endif

    if !exists('g:clang_complete_copen')
        let g:clang_complete_copen = 0
    endif

    let b:clang_exec = 'clang'
    let b:clang_parameters = '-x c'

    if &filetype == 'objc'
        let b:clang_parameters = '-x objective-c'
    endif

    if &filetype == 'cpp' || &filetype == 'objcpp'
        let b:clang_parameters .= '++'
    endif

    if expand('%:e') =~ 'h*'
        let b:clang_parameters .= '-header'
    endif

endfunction

function! s:get_kind(proto)
    if a:proto == ""
        return 't'
    endif
    let l:ret = match(a:proto, '^\[#')
    let l:params = match(a:proto, '(')
    if l:ret == -1 && l:params == -1
        return 't'
    endif
    if l:ret != -1 && l:params == -1
        return 'v'
    endif
    if l:params != -1
        return 'f'
    endif
    return 'm'
endfunction

function! s:source.initialize()
    au neocomplcache FileType c,cpp,objc,objcpp call s:ClangCompleteInit()
    if &l:filetype == 'c' || &l:filetype == 'cpp' || &l:filetype == 'objc' || &l:filetype == 'objcpp'
        call s:ClangCompleteInit()
    endif
endfunction

function! s:source.finalize()
endfunction

function! s:ClangQuickFix(clang_output)
    let l:list = []
    for l:line in a:clang_output
        let l:erridx = stridx(l:line, "error:")
        if l:erridx == -1
            continue
        endif
        let l:bufnr = bufnr("%")
        let l:pattern = '\.*:\(\d*\):\(\d*\):'
        let tmp = matchstr(l:line, l:pattern)
        let l:lnum = substitute(tmp, l:pattern, '\1', '')
        let l:col = substitute(tmp, l:pattern, '\2', '')
        let l:text = l:line
        let l:type = 'E'
        let l:item = {
                    \ "bufnr": l:bufnr,
                    \ "lnum": l:lnum,
                    \ "col": l:col,
                    \ "text": l:text[l:erridx + 7:],
                    \ "type": l:type }
        let l:list = add(l:list, l:item)
    endfor
    call setqflist(l:list)
    " The following line cause vim to segfault. A patch is ready on vim
    " mailing list but not currently upstream, I will update it as soon
    " as it's upstream. If you want to have error reporting will you're
    " coding, you could open at hand the quickfix window, and it will be
    " updated.
    " http://groups.google.com/group/vim_dev/browse_thread/thread/5ff146af941b10da
    if g:clang_complete_copen == 1
        copen
    endif
endfunction

function! s:DemangleProto(prototype)
    let l:proto = substitute(a:prototype, '[#', "", "g")
    let l:proto = substitute(l:proto, '#]', ' ', "g")
    let l:proto = substitute(l:proto, '#>', "", "g")
    let l:proto = substitute(l:proto, '<#', "", "g")
    " TODO: add a candidate for each optional parameter
    let l:proto = substitute(l:proto, '{#', "", "g")
    let l:proto = substitute(l:proto, '#}', "", "g")

    return l:proto
endfunction

function! s:source.get_keyword_pos(cur_text)
    let l:line = getline('.')
    let l:start = col('.') - 1
    let l:wsstart = l:start
    if l:line[l:wsstart - 1] =~ '\s'
        while l:wsstart > 0 && l:line[l:wsstart - 1] =~ '\s'
            let l:wsstart -= 1
        endwhile
    endif
    if l:line[l:wsstart - 1] =~ '[(,]'
        let b:should_overload = 1
        return l:wsstart
    endif
    let b:should_overload = 0
    while l:start > 0 && l:line[l:start - 1] =~ '\i'
        let l:start -= 1
    endwhile
    return l:start
endfunction

function! s:source.get_complete_words(cur_keyword_pos, cur_keyword_str)
    if neocomplcache#is_auto_complete()
        " auto complete is very slow!
        return []
    endif

    let l:buf = getline(1, '$')
    let l:tempfile = expand('%:p:h') . '/' . localtime() . expand('%:t')
    call writefile(l:buf, l:tempfile)
    let l:escaped_tempfile = shellescape(l:tempfile)

    let l:command = b:clang_exec . " -cc1 -fsyntax-only -code-completion-at="
                \ . l:escaped_tempfile . ":" . line('.') . ":" . (a:cur_keyword_pos+1)
                \ . " " . l:escaped_tempfile
                \ . " " . b:clang_parameters . " " . b:clang_user_options . " -o -"
    let l:clang_output = split(neocomplcache#system(l:command), "\n")
    call delete(l:tempfile)
    if v:shell_error
        call s:ClangQuickFix(l:clang_output)
        return []
    endif
    if l:clang_output == []
        return []
    endif
    let l:list = []
    for l:line in l:clang_output
        if l:line[:11] == 'COMPLETION: ' && b:should_overload != 1
            let l:value = l:line[12:]

            if l:value !~ '^' . a:cur_keyword_str
                continue
            endif

            " We can do something smarter for Pattern.
            " My idea is to have some sort of snippets.
            " It could be great if it can be done.
            if l:value =~ 'Pattern'
                let l:value = l:value[10:]
            endif

            let l:colonidx = stridx(l:value, " : ")
            if l:colonidx == -1
                let l:word = s:DemangleProto(l:value)
                let l:proto = l:value
            else
                let l:word = l:value[:l:colonidx - 1]
                let l:proto = l:value[l:colonidx + 3:]
            endif

            " WTF is that?
            if l:word =~ '(Hidden)'
                let l:word = l:word[:-10]
            endif

            let l:kind = s:get_kind(l:proto)
            let l:proto = s:DemangleProto(l:proto)

        elseif l:line[:9] == 'OVERLOAD: ' && b:should_overload == 1

            " The comment on Pattern also apply here.
            let l:value = l:line[10:]
            let l:word = substitute(l:value, '.*<#', "", "g")
            let l:word = substitute(l:word, '#>.*', "", "g")
            let l:proto = s:DemangleProto(l:value)
            let l:kind = ""

        else
            continue
        endif

        let l:item = {
                    \ "word": l:word,
                    \ "menu": '[clang] ' . l:proto,
                    \ "dup": 1,
                    \ }

        call add(l:list, l:item)
    endfor
    return l:list
endfunction

function! neocomplcache#sources#clang_complete#define()
    return s:source
endfunction
