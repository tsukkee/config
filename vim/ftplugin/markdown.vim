" markdown-pandoc
let s:pandoc_command = "pandoc \"%s\" -s -c \"%s\" -o \"%s\" &"
let s:pandoc_default_css = 'pandoc.css'
let s:pandoc_default_formats = ['html']
let s:pandoc_output_encoding = has('win32') ? 'cp932' : 'utf-8'

function! s:pandoc_auto_run()
    if exists('b:pandoc_enable') && b:pandoc_enable
        let b:pandoc_auto_run = 1
    endif
endfunction

function! s:pandoc_stop_auto_run()
    let b:pandoc_auto_run = 0
endfunction

function! s:pandoc_run()
    if !exists('b:pandoc_auto_run') || !b:pandoc_auto_run | return | endif

    let input = expand('%')
    let base = expand('%:r')
    let css = exists('b:pandoc_css') ? b:pandoc_css : s:pandoc_default_css
    let formats = exists('b:pandoc_formats') && (type([]) == type(b:pandoc_formats))
                \ ? b:pandoc_formats : s:pandoc_default_formats

    for format in formats
        let c = iconv(printf(s:pandoc_command, input, css, base . '.' . format),
                    \ &encoding, s:pandoc_output_encoding)
        call system(c)
    endfor
endfunction

function! s:pandoc_parse_local_setting()
    let raw = matchstr(getline('$'), '<!--\zs.\+\ze-->')
    try
        sandbox let data = eval('{' . raw . '}')
        for [k, v] in items(data)
            let b:pandoc_{k} = v
            unlet k v
        endfor
    catch /E121/
        echomsg 'markdown: local setting parse error'
    endtry
endfunction

function! s:markdown_make_title()
    let l = strwidth(getline('.'))
    let n = line('.')
    let s = ''
    for i in range(l)
        let s .= '='
    endfor
    call append(n, s)
endfunction

function! s:pandoc_markdown_to_pdf()
    let oldcwd = getcwd()
    lcd `=expand("%:p:h")`

    let command = "pandoc %s -V documentclass=ltjarticle --latex-engine=lualatex -o %s"
    let input = expand('%')
    let output = expand('%:r') . '.pdf'
    let c = iconv(printf(command, input, output), &encoding, s:pandoc_output_encoding)
    call system(c)
    if vimproc#get_last_status() != 0
        echomsg vimproc#get_last_errmsg()
    endif

    lcd `=oldcwd`
endfunction

function! s:pandoc_setup_markdown()
    call s:pandoc_parse_local_setting()
    call s:pandoc_auto_run()

    nnoremap <buffer> [Prefix]T :<C-u>call <SID>markdown_make_title()<CR>

    command! -buffer PandocAutoRun call s:pandoc_auto_run()
    command! -buffer PandocMarkdown2PDF call s:pandoc_markdown_to_pdf()
endfunction

augroup pandoc
    autocmd!
    autocmd BufWritePost *.mkd call s:pandoc_run()
    autocmd FileType markdown call s:pandoc_setup_markdown()
augroup END
