let s:prefix = 'HG: changed '
let s:files = map(filter(getline(0, '$'), 'v:val =~ "^" . s:prefix'), 'strpart(v:val, strlen(s:prefix))')

if len(s:files) == 0
  finish
end

new
setlocal filetype=diff bufhidden=delete buftype=nofile previewwindow nobackup noswapfile
execute 'normal :0r!hg diff ' . join(s:files) . "¥n¥<CR>"
setlocal nomodifiable
goto
redraw!
wincmd R
wincmd p
goto
redraw!
