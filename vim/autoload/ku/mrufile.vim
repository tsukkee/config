let s:cached_items = []


function! ku#mrufile#available_sources()
    return ['mrufile']
endfunction


function! ku#mrufile#on_source_enter(source_name_ext)
    let s:cached_items = s:mrufile_load()
endfunction


function! ku#mrufile#action_table(source_name_ext)
    return ku#file#action_table(a:source_name_ext)
endfunction


function! ku#mrufile#key_table(source_name_ext)
    return ku#file#key_table(a:source_name_ext)
endfunction


function! ku#mrufile#gather_items(source_name_ext, pattern)
    return s:cached_items
endfunction


function! ku#mrufile#special_char_p(source_name_ext, character)
    return 0
endfunction


augroup ku-mrufile
    autocmd!
    autocmd BufEnter * call s:mrufile_add()
    autocmd BufWritePost * call s:mrufile_add()
augroup END

" most of below codes were copied from ku.vim
if !exists('g:ku_mrufile_size')
    let g:ku_mrufile_size = 100
endif

let s:PATH_SEP = exists('+shellslash') && &shellslash ? '\' : '/'
let s:MRUFILE_FILE = 'info/ku/mrufile'


function! s:mrufile_file()
    return split(&runtimepath, ',')[0] . s:PATH_SEP . s:MRUFILE_FILE
endfunction


function! s:mrufile_load()
    let _ = []
    if filereadable(s:mrufile_file())
        for line in readfile(s:mrufile_file(), '', g:ku_mrufile_size)
            let columns = split(line, '\t')
            call add(_, {
            \      'word': columns[0],
            \      'time': str2nr(columns[1]),
            \      'menu': isdirectory(columns[0]) ? "dir" : "file",
            \      'ku__sort_priorities': - str2nr(columns[1]),
            \    })
        endfor
    endif
    return _
endfunction


function! s:mrufile_save(list)
    let file = s:mrufile_file()
    let directory = fnamemodify(file, ':h')
    if !isdirectory(directory)
        call mkdir(directory, 'p')
    endif

    call writefile(map(a:list, 'v:val.word ."\t". v:val.time'), file)
endfunction


function! s:mrufile_add()
    if !empty(&buftype) || expand('%') !~ '\S'
        return
    endif

    let _ = s:mrufile_load()
    let new_word = expand("%:p")
    let _ = filter(_, 'v:val.word != new_word')
    call add(_, {
    \       'word': new_word,
    \       'time': localtime(),
    \    })
    call s:mrufile_save(_)
endfunction
