let s:cached_items = []
let s:types = {'cmd': ':', 'search': '/'}


function! ku#mrucommand#available_sources()
    return ['mrucommand']
endfunction


function! ku#mrucommand#on_source_enter(source_name_ext)
    let _ = []
    let l = len(max(map(copy(s:types), 'histnr(v:key)')))
    for [type, prefix] in items(s:types)
        let n = histnr(type)
        for i in range(0, n)
            let cmd = histget(type, i)
            if(cmd != "")
                call add(_, {
                \      'word': prefix . cmd,
                \      'menu': type,
                \      'ku__sort_priority': &history - i
                \    })
            endif
        endfor
    endfor
    let s:cached_items = _
endfunction


function! ku#mrucommand#action_table(source_name_ext)
    return {
    \   'default': 'ku#mrucommand#execute',
    \   'input': 'ku#mrucommand#input',
    \ }
endfunction


function! ku#mrucommand#key_table(source_name_ext)
    return {
    \   'i': 'input',
    \ }
endfunction


function! ku#mrucommand#gather_items(source_name_ext, pattern)
    return s:cached_items
endfunction


function! ku#mrucommand#special_char_p(source_name_ext, character)
    return 0
endfunction


function! ku#mrucommand#execute(item)
    " execute a:item.word
    call feedkeys(a:item.word . "\<CR>")
endfunction


function! ku#mrucommand#input(item)
    call feedkeys(a:item.word)
endfunction

