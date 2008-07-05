" VimWiki plugin file
" Language:     Wiki
" Author:       Maxim Kim (habamax at gmail dot com)
" Home:         http://code.google.com/p/vimwiki/
" Filenames:    *.wiki
" Last Change:  (26.05.2008 10:55)
" Version:      0.3.4


if exists("loaded_vimwiki") || &cp
  finish
endif
let loaded_vimwiki = 1

let s:save_cpo = &cpo
set cpo&vim


function! s:default(varname,value)
  if !exists('g:vimwiki_'.a:varname)
    let g:vimwiki_{a:varname} = a:value
  endif
endfunction

"" Could be redefined by users
call s:default('home',"")
call s:default('index',"index")
call s:default('ext','.wiki')
call s:default('upper','A-ZА-Я')
call s:default('lower','a-zа-я')
call s:default('maxhi','1')
call s:default('other','0-9_')
call s:default('smartCR',1)
call s:default('stripsym','_')
" call s:default('addheading','1')

call s:default('history',[])

let upp = g:vimwiki_upper
let low = g:vimwiki_lower
let oth = g:vimwiki_other
let nup = low.oth
let nlo = upp.oth
let any = upp.nup

let g:vimwiki_word1 = '\C['.upp.']['.nlo.']*['.low.']['.nup.']*['.upp.']['.any.']*'
let g:vimwiki_word2 = '\[\[['.upp.low.oth.'[:punct:][:space:]]\{-}\]\]'

let s:wiki_word = '\<'.g:vimwiki_word1.'\>\|'.g:vimwiki_word2
let s:wiki_badsymbols = '[<>|?*/\:"]'

execute 'autocmd! BufNewFile,BufReadPost,BufEnter *'.g:vimwiki_ext.' set ft=vimwiki'


"" Functions {{{
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
function! s:msg(message)"{{{
    echohl WarningMsg
    echomsg 'vimwiki: '.a:message
    echohl None
endfunction"}}}

function! s:getfilename(filename)
    let word = substitute(a:filename, '\'.g:vimwiki_ext, "", "g")
    let word = substitute(word, '.*[/\\]', "", "g")
    return word
endfunction


function! s:editfile(command, filename)
    let fname = escape(a:filename, '% ')
    execute a:command.' '.fname
    
    " if fname is new
    " if g:vimwiki_addheading!=0 && glob(fname) == ''
        " execute 'normal I! '.s:getfilename(fname)
        " update
    " endif
endfunction

function! s:SearchWord(wikiRx,cmd)"{{{
    let hl = &hls
    let lasts = @/
    let @/ = a:wikiRx
    set nohls
    try
        :silent exe 'normal ' a:cmd
    catch /Pattern not found/
        call s:msg('WikiWord not found')
    endt
    let @/ = lasts
    let &hls = hl
endfunction"}}}

function! WikiNextWord()"{{{
    call s:SearchWord(s:wiki_word, 'n')
endfunction"}}}

function! WikiPrevWord()"{{{
    call s:SearchWord(s:wiki_word, 'N')
endfunction"}}}

function! s:WikiGetWordAtCursor(wikiRX) "{{{
    let col = col('.') - 1
    let line = getline('.')
    let ebeg = -1
    let cont = match(line, a:wikiRX, 0)
    while (ebeg >= 0 || (0 <= cont) && (cont <= col))
        let contn = matchend(line, a:wikiRX, cont)
        if (cont <= col) && (col < contn)
            let ebeg = match(line, a:wikiRX, cont)
            let elen = contn - ebeg
            break
        else
            let cont = match(line, a:wikiRX, contn)
        endif
    endwh
    if ebeg >= 0
        return strpart(line, ebeg, elen)
    else
        return ""
    endif
endf "}}}

function! s:WikiStripWord(word, sym)"{{{
    function! s:WikiStripWordHelper(word, sym)
        return substitute(a:word, s:wiki_badsymbols, a:sym, 'g')
    endfunction

    let result = a:word
    if strpart(a:word, 0, 2) == "[["
        let result = s:WikiStripWordHelper(strpart(a:word, 2, strlen(a:word)-4), a:sym)
    endif
    return result
endfunction"}}}

" Check if word is link to a non-wiki file.
" The easiest way is to check if it has extension like .txt or .html
function! s:WikiIsLinkToNonWikiFile(word)"{{{
    if a:word =~ '\.\w\{1,4}$'
        return 1
    endif
    return 0
endfunction"}}}

" history is [['WikiWord.wiki', 11], ['AnotherWikiWord', 3] ... etc]
" where numbers are column positions we should return when coming back.
"" WikiWord history helper functions {{{2
function! s:GetHistoryWord(historyItem)
    return get(a:historyItem, 0)
endfunction
function! s:GetHistoryColumn(historyItem)
    return get(a:historyItem, 1)
endfunction
"2}}}

function! WikiFollowWord(split) "{{{
    if a:split == "split"
        let cmd = ":split "
    elseif a:split == "vsplit"
        let cmd = ":vsplit "
    else
        let cmd = ":e "
    endif
    let word = s:WikiStripWord(s:WikiGetWordAtCursor(s:wiki_word), g:vimwiki_stripsym)
    " insert doesn't work properly inside :if. Check :help :if.
    if word == ""
        execute "normal! \n"
        return
    endif
    if s:WikiIsLinkToNonWikiFile(word)
        call s:editfile(cmd, word)
    else
        call insert(g:vimwiki_history, [expand('%:p'), col('.')])
        call s:editfile(cmd, g:vimwiki_home.word.g:vimwiki_ext)
    endif
endfunction"}}}

function! WikiGoBackWord() "{{{
    if !empty(g:vimwiki_history)
        let word = remove(g:vimwiki_history, 0)
        " go back to saved WikiWord
        execute ":e ".s:GetHistoryWord(word)
        call cursor(line('.'), s:GetHistoryColumn(word))
    endif
endfunction "}}}

"" direction == checkup - use previous line for checking
"" direction == checkdown - use next line for checking
function! WikiNewLine(direction) "{{{
    function! s:WikiAutoListItemInsert(listSym, dir)
        let sym = escape(a:listSym, '*')
        if a:dir=='checkup'
            let linenum = line('.')-1
        else
            let linenum = line('.')+1
        end
        let prevline = getline(linenum)
        if prevline =~ '^\s\+'.sym
            let curline = substitute(getline('.'),'^\s\+',"","g")
            if prevline =~ '^\s*'.sym.'\s*$'
                " there should be easier way ...
                execute 'normal kA '."\<ESC>".'"_dF'.a:listSym.'JX'
                return 1
            endif
            let ind = indent(linenum)
            call setline(line('.'), strpart(prevline, 0, ind).a:listSym.' '.curline)
            call cursor(line('.'), ind+3)
            return 1
        endif
        return 0
    endfunction

    if s:WikiAutoListItemInsert('*', a:direction)
        return
    endif

    if s:WikiAutoListItemInsert('#', a:direction)
        return
    endif

    " delete <space>
    if getline('.') =~ '^\s\+$'
        execute 'normal x'
    else
        execute 'normal X'
    endif
endfunction "}}}

"" file system funcs
"" Delete WikiWord you are in from filesystem
function! WikiDeleteWord()"{{{
    let val = input('Delete ['.expand('%').'] (y/n)? ', "")
    if val!='y'
        return
    endif
    let fname = expand('%:p')
    " call WikiGoBackWord()
    try
        call delete(fname)
    catch /.*/
        call s:msg('Cannot delete "'.expand('%:r').'"!')
        return
    endtry
    execute "bdelete! ".escape(fname, " ")
    
    " delete from g:vimwiki_history list
    call filter (g:vimwiki_history, 's:GetHistoryWord(v:val) != fname')
    " as we got back to previous WikiWord - delete it from history - as much
    " as possible
    let hword = s:GetHistoryWord(remove(g:vimwiki_history, 0))
    while !empty(g:vimwiki_history) && hword == s:GetHistoryWord(g:vimwiki_history[0])
        let hword = s:GetHistoryWord(remove(g:vimwiki_history, 0))
    endwhile

    " reread buffer => deleted WikiWord should appear as non-existent
    execute "e"
endfunction"}}}

"" Rename WikiWord, update all links to renamed WikiWord
function! WikiRenameWord() "{{{
    let wwtorename = expand('%:r')
    let isOldWordComplex = 0
    if wwtorename !~ g:vimwiki_word1
        let wwtorename = substitute(wwtorename,  g:vimwiki_stripsym, s:wiki_badsymbols, "g")
        let isOldWordComplex = 1
    endif

    " there is no file (new one maybe)
    if glob(g:vimwiki_home.expand('%')) == ''
        call s:msg('Cannot rename "'.expand('%').'". It does not exist!')
        return
    endif

    let val = input('Rename "'.expand('%:r').'" (y/n)? ', "")
    if val!='y'
        return
    endif
    let newWord = input('Enter new name: ', "")
    " check newWord - it should be 'good', not empty
    if substitute(newWord, '\s', '', 'g') == ''
        call s:msg('Cannot rename to an empty filename!')
        return
    endif
    if s:WikiIsLinkToNonWikiFile(newWord)
        call s:msg('Cannot rename to a filename with extension (ie .txt .html)!')
        return
    endif

    if newWord !~ g:vimwiki_word1
        " if newWord is 'complex wiki word' then add [[]]
        let newWord = '[['.newWord.']]'
    endif
    let newFileName = s:WikiStripWord(newWord, g:vimwiki_stripsym).g:vimwiki_ext

    " do not rename if word with such name exists
    let fname = glob(g:vimwiki_home.newFileName)
    if fname != ''
        call s:msg('Cannot rename to "'.newFileName.'". File with that name exist!')
        return
    endif
    " rename WikiWord file
    try
        call rename(expand('%'), newFileName)
        bd
        "function call doesn't work
        call s:editfile('e', newFileName)
    catch /.*/
        call s:msg('Cannot rename "'.expand('%:r').'" to "'.newFileName.'"')
        return
    endtry
    
    " save open buffers
    let openbuffers = []
    let bcount = 1
    while bcount<=bufnr("$")
        if bufexists(bcount)
            call add(openbuffers, bufname(bcount))
        endif
        let bcount = bcount + 1
    endwhile
    
    " update links
    execute ':args '.g:vimwiki_home.'*'.g:vimwiki_ext
    if isOldWordComplex
        execute ':silent argdo %s/\[\['.wwtorename.'\]\]/'.newWord.'/geI | update'
    else
        execute ':silent argdo %s/\<'.wwtorename.'\>/'.newWord.'/geI | update'
    endif
    execute ':argd *'.g:vimwiki_ext

    " restore open buffers
    let bcount = 1
    while bcount<=bufnr("$")
        if bufexists(bcount)
            if index(openbuffers, bufname(bcount)) == -1
                execute 'silent bdelete '.escape(bufname(bcount), " ")
            end
        endif
        let bcount = bcount + 1
    endwhile

    "" DONE: after renaming GUI caption is a bit corrupted?
    "" FIXED: buffers menu is also not in the "normal" state, howto Refresh menu?
    execute "emenu Buffers.Refresh\ menu"

endfunction "}}}

function! WikiHighlightWords() "{{{
    let wikies = glob(g:vimwiki_home.'*')
    "" remove .wiki extensions
    let wikies = substitute(wikies, '\'.g:vimwiki_ext, "", "g")
    let g:vimwiki_wikiwords = split(wikies, '\n')
    "" remove paths
    call map(g:vimwiki_wikiwords, 'substitute(v:val, ''.*[/\\]'', "", "g")')
    "" remove backup files (.wiki~)
    call filter(g:vimwiki_wikiwords, 'v:val !~ ''.*\~$''')

    for word in g:vimwiki_wikiwords
        if word =~ g:vimwiki_word1 && !s:WikiIsLinkToNonWikiFile(word)
            execute 'syntax match wikiWord /\<'.word.'\>/'
        else
            execute 'syntax match wikiWord /\[\['.substitute(word,  g:vimwiki_stripsym, s:wiki_badsymbols, "g").'\]\]/'
        endif
    endfor
endfunction "}}}

function! WikiGoHome()"{{{
    execute ':e '.g:vimwiki_home.g:vimwiki_index.g:vimwiki_ext
    let g:vimwiki_history = []
endfunction"}}}

" Functions }}}

"" Commands {{{
command WikiRenameWord call WikiRenameWord()
command WikiDeleteWord call WikiDeleteWord()
command WikiGoHome call WikiGoHome()
command WikiGoBackWord call WikiGoBackWord()
command -nargs=1 WikiFollowWord call WikiFollowWord(<f-args>)
command WikiNextWord call WikiNextWord()
command WikiPrevWord call WikiPrevWord()

"" Commands }}}

nmap <silent><unique> <Leader>ww :call WikiGoHome()<CR>
nmap <silent><unique> <Leader>wh :execute "edit ".g:vimwiki_home."."<CR>
