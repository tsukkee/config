" Toggle # => markers
vmap <buffer> <silent> <Space>x :rubydo $_ = $_.match(/(^.*?)\s*# =>.*$/) ? $~[1] : $_ + " # =>"<CR>
nmap <buffer> <silent> <Space>x V<Space>x<Esc>
imap <buffer> <silent> <C-f> <Esc><Space>xa

" Generate RSpec expectations
vmap <buffer> <silent> <Space>S !xmpfilter -s<CR>
nmap <buffer> <silent> <Space>S V<Space>S<Esc>

" Plain annotations
vmap <buffer> <silent> <Space>X !xmpfilter -a<CR>
nmap <buffer> <silent> <Space>X mzggVG!xmpfilter -a<CR>'z
