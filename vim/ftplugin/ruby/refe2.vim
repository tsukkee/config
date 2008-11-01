"
" some codes are from 'refe.vim':
"   http://rails2u.com/projects/refe.vim/
"
if exists("g:loaded_refe2")
  finish
endif
let g:loaded_refe2 = 1

if !has('ruby')
  echo "---------------------------------------"
  echo "Error: Required vim compiled with +ruby"
  echo "---------------------------------------"
  finish
endif

let s:bitclust_path="/usr/local/src/ruby-refm-1.9.0-dynamic/bitclust"

function! s:Refe2Clear()
  "call s:ErrorMsg('call Refe2Clear')
  "unlet! s:Refe2Stack
  "let s:Refe2Stack = []
endfunction


let s:Refe2BufNo = -1
function! s:Refe2ViewBufShow()
  if s:Refe2BufNo == -1 || s:Refe2BufNo != bufnr('%')
    exec 'to sp' . '[Refe2]'
    let s:Refe2BufNo = bufnr('%')
  end

  setlocal nomodifiable
  setlocal nobuflisted 
  setlocal nonumber 
  setlocal noswapfile
  setlocal buftype=nofile
  setlocal bufhidden=delete
  setlocal noshowcmd
  setlocal nowrap 
  " setlocal foldmethod=syntax

  au BufHidden <buffer> call <SID>Refe2Clear()
endfunction

function! s:RubyRefe2(args)
  ruby << EOR
  bitclust_path = VIM::evaluate("s:bitclust_path")
  db_path       = bitclust_path + '/../db-1_9_0'
  args          = ['-d', db_path, VIM::evaluate("a:args")]
  $LOAD_PATH << bitclust_path + '/lib'

  require 'stringio'
  old_stdout = $stdout
  $stdout = StringIO.new

  require 'bitclust/searcher'
  require 'kconv'
  refe = BitClust::Searcher.new('refe.rb')
  refe.parse args
  refe.exec nil, args
  str = $stdout.string.toutf8

  buf = VIM::Buffer.current
  while buf.count > 1
    puts buf.count
    buf.delete 1
  end
  buf.delete 1

  str.split(/\n/).each do |line|
    buf.append buf.count, line.toutf8
  end

  $stdout = old_stdout
EOR
endfunction

function! Refe2(args)
  call s:Refe2ViewBufShow()
  setlocal modifiable
  call s:RubyRefe2(a:args)
  setlocal nomodifiable
endfunction

"nnoremap K :<C-u>call Refe2(expand('<cword>'))<Return>
nnoremap K :<C-u>call Refe2(expand('<cWORD>'))<Return>
