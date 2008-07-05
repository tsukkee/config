if !exists('g:DOT_newMethod')
    let g:DOT_newMethod = 'vnew'
endif

if !exists('g:DOT_windowSize')
    let g:DOT_windowSize = '30'
endif

if !exists('g:DOT_closeOnJump')
    let g:DOT_closeOnJump = 0
endif

if !exists('g:DOT_useNarrow')
    let g:DOT_useNarrow = 0
endif

" defer
"if !exists('g:DOT_keyMapFunction')
"    let g:DOT_keyMapFunction = function('g:DOT_setDefaultKeyMap')
"endif


" a first step
command!        DOT                     :call <SID>DOT_execute(<line1>)
command!        DotOutlineTree          :call <SID>DOT_execute(<line1>)
" updating
command!        DOTUpdate               :call <SID>DOT_update()
" back to the text buffer
command!        DOTJump                 :call <SID>DOT_jump(<line1>)
command!        DOTEscape               :call <SID>DOT_escape()
command!        DOTQuit                 :call <SID>DOT_quit()
" creation / deletion
command!        DOTCreateSiblingNode    :call <SID>DOT_createSiblingNode(<line1>)
command!        DOTCreateChildNode      :call <SID>DOT_createChildNode(<line1>)
command!        DOTCreateChildNodeL     :call <SID>DOT_createChildNodeL(<line1>)
command!        DOTCreateUncleNode      :call <SID>DOT_createUncleNode(<line1>)
command! -range DOTDeleteNode           :call <SID>DOT_deleteNode(<line1>, <line2>)
" movement
command! -range DOTIncLevel             :call <SID>DOT_incLevel(<line1>, <line2>)
command! -range DOTDecLevel             :call <SID>DOT_decLevel(<line1>, <line2>)
command!        DOTFlipUpward           :call <SID>DOT_flipUpward(<line1>)
command!        DOTFlipDownward         :call <SID>DOT_flipDownward(<line1>)
" undo/redo
command!        DOTUndo                 :call <SID>DOT_undo()
command!        DOTRedo                 :call <SID>DOT_redo()
" clipboard
command! -range DOTCopy                 :call <SID>DOT_copy(<line1>, <line2>)
command!        DOTPaste                :call <SID>DOT_paste_p(<line1>)
command!        DOTPasteP               :call <SID>DOT_paste_P(<line1>)
" debugging
command!        DOTDump                 :call <SID>DOT_dump()


function! g:DOT_setOldDefaultKeyMap()
    call g:DOT_setDefaultKeyMap()

    " creation / deletion
    noremap  <buffer> <silent>  <C-J>   :DOTCreateUncleNode<CR>
    noremap  <buffer> <silent>  <C-K>   :DOTCreateSiblingNode<CR>
    noremap  <buffer> <silent>  <C-L>   :DOTCreateChildNode<CR>
    noremap  <buffer> <silent>  L       :DOTCreateChildNodeL<CR>
endfunction


function! g:DOT_setDefaultKeyMap()
    " updating
    noremap  <buffer> <silent>  r       :DOTUpdate<CR>

    " back to the text buffer
    noremap  <buffer> <silent>  <Enter> :DOTJump<CR>
    noremap  <buffer> <silent>  <Esc>   :DOTEscape<CR>
    noremap  <buffer> <silent>  q       :DOTQuit<CR>

    " creation / deletion
    noremap  <buffer> <silent>  <C-H>   :DOTCreateUncleNode<CR>
    noremap  <buffer> <silent>  <C-J>   :DOTCreateSiblingNode<CR>
    noremap  <buffer> <silent>  o       :DOTCreateSiblingNode<CR>
    noremap  <buffer> <silent>  <C-K>   :DOTCreateChildNode<CR>
    noremap  <buffer> <silent>  <C-L>   :DOTCreateChildNodeL<CR>
    noremap  <buffer> <silent>  d       :DOTDeleteNode<CR>

    " movement
    nnoremap  <buffer> <silent>  <<     :DOTDecLevel<CR>
    nnoremap  <buffer> <silent>  >>     :DOTIncLevel<CR>
    vnoremap  <buffer> <silent>  <      :DOTDecLevel<CR>
    vnoremap  <buffer> <silent>  >      :DOTIncLevel<CR>
    noremap  <buffer> <silent>  <C-U>   :DOTFlipUpward<CR>
    noremap  <buffer> <silent>  <C-D>   :DOTFlipDownward<CR>

    " undo/redo
    noremap  <buffer> <silent>  u       :DOTUndo<CR>
    noremap  <buffer> <silent>  <C-R>   :DOTRedo<CR>

    " clipboard
    noremap  <buffer> <silent>  y       :DOTCopy<CR>
    noremap  <buffer> <silent>  p       :DOTPaste<CR>
    noremap  <buffer> <silent>  P       :DOTPasteP<CR>
endfunction



"--------------------
" Interfacese & main functions
"--------------------

let s:DOT_BUFFER_PREFIX = 'DotOutlineTree'
if !exists('g:DOT_types') | let g:DOT_types = [] | endif


function! s:DOT_execute(dokozonoLineNum)
    let inTreeBuff = s:DOT__inTreeBuffer(bufnr('%'))

    call s:DOT_update()

    call s:DOT__openTreeBuffWindow(g:DOT_newMethod)
    call s:DOT__renderTree(b:DOT_rootNode.firstChild)

    " place the cursor
    let cursorPos = 0
    if inTreeBuff
        let cursorPos = a:dokozonoLineNum
    else
        let node = s:Node_getNodeByLineNum(b:DOT_rootNode, a:dokozonoLineNum)
        let cursorPos = s:Node_getNodeIndex(b:DOT_rootNode, node)
    endif
    execute cursorPos
endfunction


function! s:DOT__renderTree(node)
    setlocal modifiable

    " clear
    %delete

    " render tree
    call s:DOT__renderTreeInner(a:node)

    execute 0
    delete

    setlocal nomodifiable
endfunction


function! s:DOT__renderTreeInner(node)
    if (a:node is s:Node_NULL) || s:DOT__nodeIsTerminator(a:node) | return | endif
    "if a:node.title == ':NULL:' | return | endif

    call append(line('$'), repeat('  ', a:node.level - 1) . a:node.title)

    call s:DOT__renderTreeInner(a:node.firstChild)
    call s:DOT__renderTreeInner(a:node.nextSibling)
endfunction


function! s:DOT__openTreeBuffWindow(openMethod)
    if s:DOT__inTreeBuffer(bufnr('%'))
        " in a list buffer
        if bufexists(b:DOT_textBuffNum)
            " ok
        else
            " text buffer doesn't exist now
            throw 'text buffer ' . bufname(s:DOT_textBuffNum) . ' doesn''t exist any more'
        endif
    else
        " in a text buffer

        let treeBuffNum = bufnr(s:DOT_BUFFER_PREFIX . bufnr('%'), 1) " create unless it exists
        let b:DOT_treeBuffNum = treeBuffNum

        " open
        let listWinNum = bufwinnr(bufname(b:DOT_treeBuffNum))
        if listWinNum == -1
            " create window
            execute a:openMethod
            if match(a:openMethod, '[vV]') != -1
                execute g:DOT_windowSize . 'wincmd |'
            else
                execute g:DOT_windowSize . 'wincmd _'
            endif

            execute 'buffer ' . treeBuffNum
        else
            " focus
            execute listWinNum . 'wincmd w'
        endif
    endif
    "
    setlocal nowrap nonumber buftype=nofile bufhidden=delete noswapfile
    call g:DOT_keyMapFunction()
endfunction


function! s:DOT_update()
    let inTreeBuffer = s:DOT__inTreeBuffer(bufnr('%'))
    if inTreeBuffer
        let cursorPos = line('.')
        let textBuffNum = b:DOT_textBuffNum
        let treeBuffNum = bufnr('%')
    else
        let textBuffNum = bufnr('%')
        let treeBuffNum = bufnr(s:DOT_BUFFER_PREFIX . bufnr('%'), 1) " create unless it exists
    endif

    call setbufvar(textBuffNum, 'DOT_rootNode', s:DOT__buildNodeTree(textBuffNum))
    call setbufvar(textBuffNum, 'DOT_treeBuffNum', treeBuffNum)
    call setbufvar(treeBuffNum, 'DOT_rootNode', getbufvar(textBuffNum, 'DOT_rootNode'))
    call setbufvar(treeBuffNum, 'DOT_textBuffNum', textBuffNum)

    if inTreeBuffer
        call s:DOT__renderTree(b:DOT_rootNode.firstChild)
        execute cursorPos
    endif

    " using Narrow
    if g:DOT_useNarrow && exists(':Widen')
        silent! execute 'Widen'
    endif
endfunction


function! s:DOT_escape()
    if !s:DOT__inTreeBuffer(bufnr('%')) | return | endif

    execute b:DOT_textBuffNum . 'wincmd w'
endfunction


function! s:DOT_quit()
    if s:DOT__inTreeBuffer(bufnr('%'))
        call s:Util_switchCurrentBuffer(b:DOT_textBuffNum, 'new')
    endif

    if exists('b:DOT_treeBuffNum')
        execute 'bdelete ' . b:DOT_treeBuffNum
        unlet b:DOT_treeBuffNum
    endif
    if exists('b:DOT_rootNode') | unlet b:DOT_rootNode | endif
endfunction


function! s:DOT_jump(dokozonoLineNum)
    if !s:DOT__inTreeBuffer(bufnr('%')) | return | endif

    call s:DOT_update()

    let node = s:Node_getNthNode(b:DOT_rootNode, a:dokozonoLineNum)
    let textBuffLineNum = node.lineNum

    call s:Util_switchCurrentBuffer(b:DOT_textBuffNum, 'new')

    execute textBuffLineNum
    normal zt

    " using Narrow
    if g:DOT_useNarrow && exists(':Narrow')
        let outofNarrowNode = s:Node_getNextNode(s:Node_getLastDescendantNode(node))

        silent! execute 'Widen'
        silent! execute node.lineNum . ',' . (outofNarrowNode.lineNum - 1) . 'Narrow'
    endif

    if g:DOT_closeOnJump | call s:DOT_quit() | endif
endfunction


function! s:DOT__inTreeBuffer(buffNum)
    return (getbufvar(a:buffNum, 'DOT_textBuffNum') != '')
endfunction


function! s:DOT_createSiblingNode(dokozonoLineNum)
    call s:DOT__createNode(a:dokozonoLineNum, 0, 'Sibling')
endfunction


function! s:DOT_createChildNode(dokozonoLineNum)
    call s:DOT_update()

    let inTreeBuffer = s:DOT__inTreeBuffer(bufnr('%'))
    if inTreeBuffer
        let cursorPos = line('.')
        let buffNum = b:DOT_textBuffNum
        let node = s:Node_getNthNode(b:DOT_rootNode, a:dokozonoLineNum)
    else
        let buffNum = bufnr('%')
        let node = s:Node_getNodeByLineNum(b:DOT_rootNode, a:dokozonoLineNum)
    endif

    if node is b:DOT_rootNode.lastChild
        echo 'You can''t create any node after the terminal node.'
        return
    endif

    call s:Util_switchCurrentBuffer(buffNum, 'new')

    let title = input('First Child: ')
    if strlen(title) == 0 | return | endif

    let lineNumToInsert = s:Node_getNextNode(node).lineNum - 1 " insert just before the next node

    "echoe 'base:' . baseNode.title
    "echoe 'dest:' . lastNode.title
    "echoe 'lineNumToInsert:' . lineNumToInsert

    let sttype = getbufvar(buffNum, 'DOT_type')
    if strlen(sttype) == 0 | let sttype = 'base' | endif

    call s:Text_insertHeading(
                \ lineNumToInsert,
                \ title,
                \ node.level + 1,
                \ 'g:DOT_' . sttype . 'DecorateHeading')

    if inTreeBuffer
        call s:DOT_execute(line('.'))
        execute cursorPos + 1
    endif
endfunction


function! s:DOT_createChildNodeL(dokozonoLineNum)
    call s:DOT__createNode(a:dokozonoLineNum, 1, 'Last Child')
endfunction


function! s:DOT_createUncleNode(dokozonoLineNum)
    call s:DOT__createNode(a:dokozonoLineNum, -1, 'Uncle')
endfunction


function! s:DOT_deleteNode(dokoLineNum1, dokoLineNum2)
    call s:DOT_update()

    let inTreeBuffer = s:DOT__inTreeBuffer(bufnr('%'))
    if inTreeBuffer
        let cursorPos = line('.')
        let buffNum = b:DOT_textBuffNum
        let node1 = s:Node_getNthNode(b:DOT_rootNode, a:dokoLineNum1)
        let node2 = s:Node_getNthNode(b:DOT_rootNode, a:dokoLineNum2)
    else
        let buffNum = bufnr('%')
        let node1 = s:Node_getNodeByLineNum(b:DOT_rootNode, a:dokoLineNum1)
        let node2 = s:Node_getNodeByLineNum(b:DOT_rootNode, a:dokoLineNum2)
    endif

    if node1 is b:DOT_rootNode
        echo 'You can''t delete nothing but nodes.'
        return
    endif
    if node2 is b:DOT_rootNode.lastChild
        echo 'You can''t delete the terminal node.'
        return
    endif

    let lastNode1 = s:Node_getLastDescendantNode(node1)
    let lastNode2 = s:Node_getLastDescendantNode(node2)

    let msg = 'Are you sure to delete '
    if (node1 is node2) 
        if (node1 isnot lastNode1)
            let msg = msg . '''' . node1.title . ''' and its decendants?'
        else
            let msg = msg . '''' . node1.title . ''' ?'
        endif
    else
         let msg = msg . 'these nodes?'
    endif

    echo msg . ' [y/N] '
    let answer = tolower(nr2char(getchar()))
    " clear
    normal :<Esc>
    if answer != 'y' | return | endif

    call s:Util_switchCurrentBuffer(buffNum, 'new')

    let lastLineNum = max([
                \ s:Node_getNextNode(lastNode1).lineNum - 1,
                \ s:Node_getNextNode(lastNode2).lineNum - 1])
    call s:Text_deleteLines(node1.lineNum, lastLineNum)

    if inTreeBuffer
        call s:DOT_execute(line('.'))
        execute cursorPos
    endif
endfunction


function! s:DOT_incLevel(dokoLineNum1, dokoLineNum2)
    call s:DOT_update()

    let inTreeBuffer = s:DOT__inTreeBuffer(bufnr('%'))
    if inTreeBuffer
        let cursorPos = line('.')
        let buffNum = b:DOT_textBuffNum
        let node1 = s:Node_getNthNode(b:DOT_rootNode, a:dokoLineNum1)
        let node2 = s:Node_getNthNode(b:DOT_rootNode, a:dokoLineNum2)
    else
        let buffNum = bufnr('%')
        let node1 = s:Node_getNodeByLineNum(b:DOT_rootNode, a:dokoLineNum1)
        let node2 = s:Node_getNodeByLineNum(b:DOT_rootNode, a:dokoLineNum2)
    endif

    if node1 is b:DOT_rootNode
        echo 'You can''t inclement nothing but nodes.'
        return
    endif
    if node2 is b:DOT_rootNode.lastChild
        echo 'You can''t inclement level of the terminal node.'
        return
    endif
    if node1 is b:DOT_rootNode.firstChild
        echo 'You can''t inclement level of the first top node.'
        return
    endif

    let lastNode = s:Node_getNextNode(s:Node_getLastDescendantNode(node2))
    let node = node1

    let sttype = getbufvar(buffNum, 'DOT_type')
    if strlen(sttype) == 0 | let sttype = 'base' | endif

    call s:Util_switchCurrentBuffer(buffNum, 'new')

    while node isnot lastNode
        call s:Text_setHeading(node.title, node.level + 1, node.lineNum, 'g:DOT_' . sttype . 'SetHeading')
        let node = s:Node_getNextNode(node)
    endwhile

    if inTreeBuffer
        call s:DOT_execute(line('.'))
        execute cursorPos
    endif
endfunction


function! s:DOT_decLevel(dokoLineNum1, dokoLineNum2)
    call s:DOT_update()

    let inTreeBuffer = s:DOT__inTreeBuffer(bufnr('%'))
    if inTreeBuffer
        let cursorPos = line('.')
        let buffNum = b:DOT_textBuffNum
        let node1 = s:Node_getNthNode(b:DOT_rootNode, a:dokoLineNum1)
        let node2 = s:Node_getNthNode(b:DOT_rootNode, a:dokoLineNum2)
    else
        let buffNum = bufnr('%')
        let node1 = s:Node_getNodeByLineNum(b:DOT_rootNode, a:dokoLineNum1)
        let node2 = s:Node_getNodeByLineNum(b:DOT_rootNode, a:dokoLineNum2)
    endif

    if node1 is b:DOT_rootNode
        echo 'You can''t declement nothing but nodes.'
        return
    endif
    if node2 is b:DOT_rootNode.lastChild
        echo 'You can''t declement level of the terminal node.'
        return
    endif
    if node1 is b:DOT_rootNode.firstChild
        echo 'You can''t declement level of the first top node.'
        return
    endif

    let lastNode = s:Node_getNextNode(s:Node_getLastDescendantNode(node2))

    " test run
    let node = node1
    while node isnot lastNode
        if node.level == 1
            echo 'Some node is top-level.'
            return
        endif
        let node = s:Node_getNextNode(node)
    endwhile

    let sttype = getbufvar(buffNum, 'DOT_type')
    if strlen(sttype) == 0 | let sttype = 'base' | endif

    call s:Util_switchCurrentBuffer(buffNum, 'new')

    " run
    let node = node1
    while node isnot lastNode
        call s:Text_setHeading(node.title, node.level - 1, node.lineNum, 'g:DOT_' . sttype . 'SetHeading')
        let node = s:Node_getNextNode(node)
    endwhile

    if inTreeBuffer
        call s:DOT_execute(line('.'))
        execute cursorPos
    endif
endfunction


function! s:DOT_undo()
    let inTreeBuffer = s:DOT__inTreeBuffer(bufnr('%'))
    if inTreeBuffer
        let cursorPos = line('.')
        call s:Util_switchCurrentBuffer(b:DOT_textBuffNum, 'new')
    endif

    undo

    if inTreeBuffer
        call s:DOT_execute(line('.'))
        execute cursorPos
    endif
endfunction


function! s:DOT_flipUpward(dokozonoLineNum)
    call s:DOT_update()

    let inTreeBuffer = s:DOT__inTreeBuffer(bufnr('%'))
    if inTreeBuffer
        let cursorPos = line('.')
        let buffNum = b:DOT_textBuffNum
        let node = s:Node_getNthNode(b:DOT_rootNode, a:dokozonoLineNum)
    else
        let buffNum = bufnr('%')
        let node = s:Node_getNodeByLineNum(b:DOT_rootNode, a:dokozonoLineNum)
    endif

    let lastNode = s:Node_getLastDescendantNode(node)

    let destNode = node
    while destNode isnot b:DOT_rootNode && node.level < s:Node_getPrevNode(destNode).level
        let destNode = s:Node_getPrevNode(destNode)
    endwhile
    let destNode = s:Node_getPrevNode(destNode)

    " error
    if s:DOT__nodeIsTerminator(node)
        echo 'You can''t move the terminal node.'
        return
    elseif destNode is s:Node_NULL || destNode is b:DOT_rootNode
        echo 'you can''t move any nodes over the first node.'
        return
    endif

    " used moving the cursor
    let srcNodeIndex = s:Node_getNodeIndex(b:DOT_rootNode, node)
    let lastNodeIndex = s:Node_getNodeIndex(b:DOT_rootNode, lastNode)
    let destNodeIndex = s:Node_getNodeIndex(b:DOT_rootNode, destNode)

    call s:Util_switchCurrentBuffer(buffNum, 'new')

    let firstLineNum = node.lineNum
    let lastLineNum = s:Node_getNextNode(lastNode).lineNum - 1

    " copy
    let lines = s:Text_getLines(firstLineNum, lastLineNum)
    " delete
    call s:Text_deleteLines(firstLineNum, lastLineNum)
    " paste
    call s:Text_insertLines(
                \ destNode.lineNum - 1,
                \ lines)

    if inTreeBuffer
        call s:DOT_execute(line('.'))
        execute cursorPos - (srcNodeIndex - destNodeIndex)
    endif
endfunction


function! s:DOT_flipDownward(dokozonoLineNum)
    call s:DOT_update()

    let inTreeBuffer = s:DOT__inTreeBuffer(bufnr('%'))
    if inTreeBuffer
        let cursorPos = line('.')
        let buffNum = b:DOT_textBuffNum
        let node = s:Node_getNthNode(b:DOT_rootNode, a:dokozonoLineNum)
    else
        let buffNum = bufnr('%')
        let node = s:Node_getNodeByLineNum(b:DOT_rootNode, a:dokoLineNum1)
    endif

    let lastNode = s:Node_getLastDescendantNode(node)

    let destNode = s:Node_getNextNode(lastNode)
    while !s:DOT__nodeIsTerminator(destNode) && node.level < s:Node_getNextNode(destNode).level
        let destNode = s:Node_getNextNode(destNode)
    endwhile
    let destNode = s:Node_getNextNode(destNode)

   " error
    if s:DOT__nodeIsTerminator(node)
        echo 'You can''t move the terminal node.'
        return
    elseif destNode is s:Node_NULL
        echo 'you can''t move any nodes over the terminal node.'
        return
    endif

    " used moving the cursor
    let srcNodeIndex = s:Node_getNodeIndex(b:DOT_rootNode, node)
    let lastNodeIndex = s:Node_getNodeIndex(b:DOT_rootNode, lastNode)
    let destNodeIndex = s:Node_getNodeIndex(b:DOT_rootNode, destNode)

    call s:Util_switchCurrentBuffer(buffNum, 'new')

    let firstLineNum = node.lineNum
    let lastLineNum = s:Node_getNextNode(lastNode).lineNum - 1

    " copy
    let lines = s:Text_getLines(firstLineNum, lastLineNum)
    " paste
    call s:Text_insertLines(
                \ destNode.lineNum - 1,
                \ lines)
    " delete
    call s:Text_deleteLines(firstLineNum, lastLineNum)

    if inTreeBuffer
        call s:DOT_execute(line('.'))
        execute cursorPos + (destNodeIndex - lastNodeIndex - 1)
    endif
endfunction


function! s:DOT_redo()
    let inTreeBuffer = s:DOT__inTreeBuffer(bufnr('%'))
    if inTreeBuffer
        let cursorPos = line('.')
        call s:Util_switchCurrentBuffer(b:DOT_textBuffNum, 'new')
    endif

    redo

    if inTreeBuffer
        call s:DOT_execute(line('.'))
        execute cursorPos
    endif
endfunction


function! s:DOT_copy(dokoLineNum1, dokoLineNum2)
    call s:DOT_update()

    let inTreeBuffer = s:DOT__inTreeBuffer(bufnr('%'))
    if inTreeBuffer
        let cursorPos = line('.')
        let buffNum = b:DOT_textBuffNum
        let node1 = s:Node_getNthNode(b:DOT_rootNode, a:dokoLineNum1)
        let node2 = s:Node_getNthNode(b:DOT_rootNode, a:dokoLineNum2)
    else
        let buffNum = bufnr('%')
        let node1 = s:Node_getNodeByLineNum(b:DOT_rootNode, a:dokoLineNum1)
        let node2 = s:Node_getNodeByLineNum(b:DOT_rootNode, a:dokoLineNum2)
    endif

    call s:Util_switchCurrentBuffer(buffNum, 'new')

    call s:Text_copy(node1.lineNum, s:Node_getNextNode(node2).lineNum - 1)

    if inTreeBuffer
        call s:DOT_execute(line('.'))
        execute cursorPos
    endif
endfunction


function! s:DOT_paste_p(dokozonoLineNum)
    call s:DOT_update()

    let inTreeBuffer = s:DOT__inTreeBuffer(bufnr('%'))
    if inTreeBuffer
        let cursorPos = line('.')
        let buffNum = b:DOT_textBuffNum
        let node1 = s:Node_getNthNode(b:DOT_rootNode, a:dokozonoLineNum)
    else
        let buffNum = bufnr('%')
        let node1 = s:Node_getNodeByLineNum(b:DOT_rootNode, a:dokozonoLineNum)
    endif

    call s:Util_switchCurrentBuffer(buffNum, 'new')

    call s:Text_paste(s:Node_getNextNode(node1).lineNum)

    if inTreeBuffer
        call s:DOT_execute(line('.'))
        execute cursorPos
    endif
endfunction


function! s:DOT_paste_P(dokozonoLineNum)
    call s:DOT_update()

    let inTreeBuffer = s:DOT__inTreeBuffer(bufnr('%'))
    if inTreeBuffer
        let cursorPos = line('.')
        let buffNum = b:DOT_textBuffNum
        let node1 = s:Node_getNthNode(b:DOT_rootNode, a:dokozonoLineNum)
    else
        let buffNum = bufnr('%')
        let node1 = s:Node_getNodeByLineNum(b:DOT_rootNode, a:dokozonoLineNum)
    endif

    call s:Util_switchCurrentBuffer(buffNum, 'new')

    call s:Text_paste(node1.lineNum)

    if inTreeBuffer
        call s:DOT_execute(line('.'))
        execute cursorPos
    endif
endfunction


function! s:DOT_dump()
    call s:DOT_update()
    call s:DOT__dumpTree(b:DOT_rootNode)
endfunction


function! s:DOT__detectType(buffNum)
    let lines = getbufline(a:buffNum, 1, '$')

    " defined by the user
    let type = getbufvar(a:buffNum, 'DOT_type')
    if index(g:DOT_types, type, 0, 1) != -1 | return type | endif

    " defined by the text buffer
    let TYPE_DECLARATOR_PATTERN = '\v.*%(%(vi|vim|ex)%([^:]*:)|outline)%([^:]*:)[^<]*\<\s*([^>]+)\s*\>.*' " very magic
    let i = 0
    while i < min([&modelines, len(lines)])
        " downward
        let type = substitute(lines[i], TYPE_DECLARATOR_PATTERN, '\1', 'i')
        if index(g:DOT_types, type, 0, 1) != -1 | return type | endif

        " upward
        let type = substitute(lines[len(lines) - 1 - i], TYPE_DECLARATOR_PATTERN, '\1', 'i')
        if index(g:DOT_types, type, 0, 1) != -1 | return type | endif

        let i += 1
    endwhile

    return 'base' " default type
endfunction


function! s:DOT__buildNodeTree(buffNum)
    let rootNode = s:Node_create(':ROOT:', 0, 0)

    let sttype = s:DOT__detectType(a:buffNum)

    let Init = function('g:DOT_' . sttype . 'Init')
    call Init()
    let headings = s:Text_collectHeadings(
                        \ a:buffNum, 
                        \ function('g:DOT_' . sttype . 'DetectHeading'), 
                        \ function('g:DOT_' . sttype . 'ExtractTitle'),
                        \ function('g:DOT_' . sttype . 'ExtractLevel'))
    let addedTerminator = 0
    let lastNode = rootNode
    for h in headings
        if h.level == 1 && strlen(substitute(h.title, ' ', '', 'g')) == 0
            let h.title = ''
            let addedTerminator = 1
        endif
        let lastNode = s:Node_add(lastNode, h.title, h.level, h.lineNum)
    endfor

    if !addedTerminator
        call s:Node_add(lastNode, '', 1, len(getbufline(a:buffNum, 1, '$')) + 1)
    endif

    " maybe built the tree successfully
    call setbufvar(a:buffNum, 'DOT_type', sttype)

    return rootNode
endfunction


function! s:DOT__nodeIsTerminator(node)
    return (a:node.title == '')
endfunction


function! s:DOT__createNode(dokozonoLineNum, levelDelta, titlePrompt)
    call s:DOT_update()

    let inTreeBuffer = s:DOT__inTreeBuffer(bufnr('%'))
    if inTreeBuffer
        let cursorPos = line('.')
        let buffNum = b:DOT_textBuffNum
        let node = s:Node_getNthNode(b:DOT_rootNode, a:dokozonoLineNum)
    else
        let buffNum = bufnr('%')
        let node = s:Node_getNodeByLineNum(b:DOT_rootNode, a:dokozonoLineNum)
    endif

    if node is b:DOT_rootNode.lastChild
        echo 'You can''t create any node after the terminal node.'
        return
    endif
    if node.level + a:levelDelta < 1
        echo 'You can''t create 0-level node.'
        return
    endif

    let title = input(a:titlePrompt . ': ')
    if strlen(title) == 0 | return | endif

    call s:Util_switchCurrentBuffer(buffNum, 'new')

    let lastNode = s:Node_getLastDescendantNode(node)
    let lineNumToInsert = s:Node_getNextNode(lastNode).lineNum - 1 " insert just before the next node

    "echoe 'base:' . baseNode.title
    "echoe 'dest:' . lastNode.title
    "echoe 'lineNumToInsert:' . lineNumToInsert

    let sttype = getbufvar(buffNum, 'DOT_type')
    if strlen(sttype) == 0 | let sttype = 'base' | endif

    call s:Text_insertHeading(
                \ lineNumToInsert,
                \ title,
                \ node.level + a:levelDelta,
                \ 'g:DOT_' . sttype . 'DecorateHeading')

    if inTreeBuffer
        let cursorPos = s:Node_getNodeIndex(b:DOT_rootNode, lastNode) + 1
        call s:DOT_execute(line('.'))
        execute cursorPos
    endif
endfunction


function! s:DOT__dumpTree(node)
    if a:node is s:Node_NULL | return | endif
    "if a:node.title == ':NULL:' | return | endif

    echom a:node.lineNum . ' : [' . a:node.level . '] ' . a:node.title

    call s:DOT__dumpTree(a:node.firstChild)
    call s:DOT__dumpTree(a:node.nextSibling)
endfunction


let s:DOT_REGEXP = '^\(\.\+\)\s*\(.*\)$'

function! g:DOT_baseDecorateHeading(title, level)
    return {'lines':[repeat('.', a:level) . ' ' . a:title, '', '', ''], 'cursorPos': [1, 0]}
endfunction


function! g:DOT_baseInit()
endfunction


function! g:DOT_baseDetectHeading(targetLine, targetLineIndex, entireLines)
    return (a:targetLine =~ s:DOT_REGEXP)
endfunction


function! g:DOT_baseExtractTitle(targetLine, targetLineIndex, entireLines)
    return substitute(a:targetLine, s:DOT_REGEXP, '\2', '')
endfunction


function! g:DOT_baseExtractLevel(targetLine, targetLineIndex, entireLines)
    return strlen(substitute(a:targetLine, s:DOT_REGEXP, '\1', ''))
endfunction


function! g:DOT_baseSetHeading(title, level, lineNum)
    call setline(a:lineNum, repeat('.', a:level) . ' ' . a:title)
endfunction



"--------------------
" Accessors to text buffer
"--------------------

function! s:Text_collectHeadings(buffNum, headingDetector, titleExtractor, levelExtractor)
    let lines = getbufline(a:buffNum, 1, '$')

    let lineNum = 1
    let headings = []
    for line in lines
        if a:headingDetector(line, lineNum - 1, lines)
            call add(headings, {
                     \ 'lineNum': lineNum,
                     \ 'title': a:titleExtractor(line, lineNum - 1, lines),
                     \ 'level': a:levelExtractor(line, lineNum - 1, lines),
                     \ })
        endif

        let lineNum += 1
    endfor

    return headings
endfunction


function! s:Text_setHeading(title, level, lineNum, headingSetter)
    call function(a:headingSetter)(a:title, a:level, a:lineNum)
endfunction


function! s:Text_getLines(firstLineNum, lastLineNum)
    return getline(a:firstLineNum, a:lastLineNum)
endfunction


" deletes   lines[firstLineNum, firstLineNum + 1, ... , lastLineNum]
function! s:Text_deleteLines(firstLineNum, lastLineNum)
    execute a:firstLineNum . ',' . a:lastLineNum . 'delete'
endfunction


function! s:Text_insertLines(lineNum, contents)
    call append(a:lineNum, a:contents)
endfunction


function! s:Text_insertHeading(lineNum, title, level, headingDecorator)
    let Fn = function(a:headingDecorator)
    let headingInfo = Fn(a:title, a:level)
    call append(a:lineNum, headingInfo.lines)

    let pos = getpos('.')
    let pos[1] = a:lineNum + 1 + headingInfo.cursorPos[0]
    let pos[2] += headingInfo.cursorPos[1]
    call setpos('.', pos)
endfunction


function! s:Text_copy(firstLineNum, lastLineNum)
    execute a:firstLineNum . ',' . a:lastLineNum . 'yank'
endfunction


function! s:Text_paste(lineNum)
    execute a:lineNum
    normal "0P
endfunction



"--------------------
" Node definitions & creations
"--------------------


" NULL node
if !exists('s:Node_NULL')
    let s:Node_NULL = {'title': ':NULL:', 'level':0, 'lineNum':0}
    " has no relationships
endif


function! s:Node_create(title, level, lineNum)
    return {
          \ 'title' : a:title,
          \ 'level' : a:level,
          \ 'lineNum' : a:lineNum,
          \ 'nextSibling' : s:Node_NULL,
          \ 'previousSibling' : s:Node_NULL,
          \ 'parentNode' : s:Node_NULL,
          \ 'firstChild' : s:Node_NULL,
          \ 'lastChild' : s:Node_NULL,
          \ 'childNodes' : [],
          \ }
endfunction


function! s:Node_add(rootNode, title, level, lineNum)
    let lastNode = s:Node_getLastNode(a:rootNode)

    let newNode = s:Node_create(a:title, a:level, a:lineNum)
    if lastNode.level + 1 < newNode.level
        let newNode.level -= lastNode.level + 1
    endif

    if newNode.level < lastNode.level
        let parentNode = lastNode
        while newNode.level <= parentNode.level
            let parentNode = parentNode.parentNode
        endwhile
        call s:Node_appendChild(parentNode, newNode)
    elseif lastNode.level < newNode.level
        call s:Node_appendChild(lastNode, newNode)
    else " ==
        call s:Node_appendChild(lastNode.parentNode, newNode)
    endif

    return newNode
endfunction


function! s:Node_appendChild(parentNode, childNode)
    let oldLastChild = a:parentNode.lastChild

    let oldLastChild.nextSibling = a:childNode
    let a:childNode.previousSibling = oldLastChild

    let a:childNode.parentNode = a:parentNode
    if a:parentNode.firstChild is s:Node_NULL | let a:parentNode.firstChild = a:childNode | endif
    let a:parentNode.lastChild = a:childNode
    call add(a:parentNode.childNodes, a:childNode)
endfunction


function! s:Node_getLastNode(rootNode)
    if a:rootNode.lastChild is s:Node_NULL | return a:rootNode | endif
    return s:Node_getLastNode(a:rootNode.lastChild)
endfunction


function! s:Node_getNodeByLineNum(rootNode, lineNum)
    let candidate = a:rootNode
    for c in a:rootNode.childNodes
        if a:lineNum < c.lineNum | break | endif " found?
        let candidate = c
    endfor

    if candidate is a:rootNode | return a:rootNode | endif

    " search among childNodes
    return s:Node_getNodeByLineNum(candidate, a:lineNum)
endfunction


function! s:Node_getNthNode(node, n)
    if (a:n == 0 || a:node is s:Node_NULL) | return a:node | endif

    if a:node.firstChild isnot s:Node_NULL
        let nextNode = a:node.firstChild
    elseif a:node.nextSibling isnot s:Node_NULL
        let nextNode = a:node.nextSibling
    else
        let nextNode = a:node.parentNode
        while (nextNode isnot s:Node_NULL) && (nextNode.nextSibling is s:Node_NULL)
            let nextNode = nextNode.parentNode
        endwhile
        if nextNode isnot s:Node_NULL | let nextNode = nextNode.nextSibling | endif
    endif

    return s:Node_getNthNode(nextNode, a:n - 1)
endfunction


function! s:Node_getNextNode(node)
    return s:Node_getNthNode(a:node, 1)
endfunction


function! s:Node_getPrevNode(node)
    if a:node is s:Node_NULL | return a:node | endif

    let p = a:node.parentNode
    while p isnot s:Node_NULL && s:Node_getNextNode(p) isnot a:node
        let p = s:Node_getNextNode(p)
    endwhile

    return p
endfunction


function! s:Node_getLastDescendantNode(node)
    if ((a:node is s:Node_NULL) || (a:node.lastChild is s:Node_NULL)) | return a:node | endif

    return s:Node_getLastDescendantNode(a:node.lastChild)
endfunction


function! s:Node_getNodeIndex(rootNode, node)
    return s:Node_getNodeIndexInner(a:rootNode, a:node, 0)
endfunction


function! s:Node_getNodeIndexInner(rootNode, node, currIndex)
    if a:rootNode is a:node | return a:currIndex | endif
    if a:rootNode is s:Node_NULL | return -1 | endif

    return s:Node_getNodeIndexInner(s:Node_getNextNode(a:rootNode), a:node, a:currIndex + 1)
endfunction


"--------------------
" Misc
"--------------------

function! s:Util_switchCurrentBuffer(buffNum, newcmd)
    if bufnr('%') == a:buffNum | return a:buffNum | endif

    let prevBuffNum = bufnr('#')
    let winNum = bufwinnr(a:buffNum)
    if winNum == -1
        execute a:newcmd 
        execute 'buffer ' a:buffNum
    else
        execute winNum . 'wincmd w'
    endif

    return prevBuffNum
endfunction


"--------------------
" deferred
"--------------------

if !exists('g:DOT_keyMapFunction')
    let g:DOT_keyMapFunction = function('g:DOT_setDefaultKeyMap')
endif


"--------------------
" making one object file
"--------------------

"reStructuredText plugin for DOT
"===============================
"
"Summary 
"-------
"ThisIs:
"   A plugin for DOT.
"   With this plugin, DOT can make outline tree from reStrucredText.
"
"Usage:
"   Add a new line to the target buffer.
"       > outline: <rest>
"   or
"       > vim: set hoge : <rest>

if index(g:DOT_types, 'rest') == -1
    call add(g:DOT_types, 'rest')
endif

function! g:DOT_restInit()
    let b:DOT_restSectionMarks = []
endfunction

" section 1.            <- detected
" ===============       <- not detected
function! g:DOT_restDetectHeading(targetLine, targetLineIndex, entireLines)
    let detected = 0

    if a:targetLineIndex == len(a:entireLines) - 1 | return 0 | endif

    let commentpattern = '\v' . substitute(escape(&commentstring, '.*\()[]{}?'), '%s', '\\(.*\\)', '')
    let nextLine = substitute(a:entireLines[a:targetLineIndex + 1], commentpattern, '\1', '')
    if nextLine =~ '^[-=`:.''"~^_*+#]\{2,\}$'
        if a:targetLine !~ '^[-=`:.''"~^_*+#]\{2,\}$'
            let detected = 1

            " add if no entry
            let mark = nextLine[0]
            if index(b:DOT_restSectionMarks, mark) == -1
                call add(b:DOT_restSectionMarks, mark)
            endif
        endif
    endif

    return detected
endfunction


function! g:DOT_restExtractTitle(targetLine, targetLineIndex, entireLines)
    return a:targetLine
endfunction


function! g:DOT_restExtractLevel(targetLine, targetLineIndex, entireLines)
    let mark = a:entireLines[a:targetLineIndex + 1][0]
    return index(b:DOT_restSectionMarks, mark) + 1
endfunction


function! g:DOT_restSetHeading(title, level, lineNum)
    let mark = ':'
    if a:level <= len(b:DOT_restSectionMarks) | let mark = b:DOT_restSectionMarks[a:level - 1] | endif

    call setline(a:lineNum, [a:title, repeat(mark, 20)])
endfunction


function! g:DOT_restDecorateHeading(title, level)
    let mark = ':'
    if a:level <= len(b:DOT_restSectionMarks) | let mark = b:DOT_restSectionMarks[a:level - 1] | endif

    return {'lines':[a:title, repeat(mark, 20), '', ''], 'cursorPos': [2, 0]}
endfunction
"
" vim: set et ff=unix fenc=utf-8 sts=4 sw=4 ts=4 : <rest>

" vim: set fenc=utf-8 ff=unix ts=4 sts=4 sw=4 et : 
