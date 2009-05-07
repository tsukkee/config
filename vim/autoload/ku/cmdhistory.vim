let s:cached_items = []
let s:types = {'cmd': ':', 'search': '/'}


function! ku#cmdhistory#available_sources()
    return ['cmdhistory']
endfunction


function! ku#cmdhistory#on_source_enter(source_name_ext)
    let _ = []
    let l = len(max(map(copy(s:types), 'histnr(v:key)')))
    for [type, prefix] in items(s:types)
        let n = histnr(type)
        for i in range(0, n)
            let cmd = histget(type, i)
            if(cmd != "")
                call add(_, {
                \      'word': prefix . cmd,
                \      'menu': printf('cmd history %*d', l, i),
                \      'dup': 1,
                \      'ku_buffer_nr': i,
                \      'ku__sort_priority': 0
                \    })
            endif
        endfor
    endfor
    let s:cached_items = _
endfunction


function! ku#cmdhistory#action_table(source_name_ext)
    return {
    \   'default': 'ku#cmdhistory#execute',
    \   'input': 'ku#cmdhistory#input',
    \ }
endfunction


function! ku#cmdhistory#key_table(source_name_ext)
    return {
    \   'i': 'input',
    \ }
endfunction


function! ku#cmdhistory#gather_items(source_name_ext, pattern)
    return s:cached_items
endfunction


function! ku#cmdhistory#special_char_p(source_name_ext, character)
    return 0
endfunction


function! ku#cmdhistory#execute(item)
    " execute a:item.word
    call feedkeys(a:item.word . "\<CR>")
endfunction


function! ku#cmdhistory#input(item)
    call feedkeys(a:item.word)
endfunction

