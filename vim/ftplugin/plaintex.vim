augroup plaintex
    autocmd!
    autocmd FileType plaintex,tex
    \   setlocal foldmethod=expr
    \|  let &l:foldexpr = s:SID_PREFIX() . 'tex_foldexpr(v:lnum)'
augroup END

" get SID prefix of vimrc
" See: :h <SID>
function! s:SID_PREFIX()
    return matchstr(expand('<sfile>'), '<SNR>\d\+_')
endfunction

" folding using \section, \subsection, \subsubsection
function! s:tex_foldexpr(lnum)
    " set fold level as section level
    let matches = matchlist(getline(a:lnum), '^\s*\\\(\(sub\)*\)section')
    if !empty(matches)
        " for example, matches[1] is 'subsub' when line is '\subsubsection'
        return len(matches[1]) / 3 + 1
    else
        " when next line is /\\(sub)*section/, this line is the end of specified section
        let matches = matchlist(getline(a:lnum + 1), '^\s*\\\(\(sub\)*\)section')
        if !empty(matches)
            return '<' . string(len(matches[1]) / 3 + 1)
        " otherwise keep fold level
        else
            return '='
        endif
    endif
endfunction
