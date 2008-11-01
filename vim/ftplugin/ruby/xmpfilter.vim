" Toggle # => markers
vmap <silent> <Space>x :rubydo $_ = $_.match(/(^.*?)\s*# =>.*$/) ? $~[1] : $_ + " # =>"<CR>
nmap <silent> <Space>x V<Space>x<Esc>
imap <silent> <C-f> <Esc><Space>xa

" Generate RSpec expectations
vmap <silent> <Space>S !xmpfilter -s<CR>
nmap <silent> <Space>S V<Space>S<Esc>

" Plain annotations
vmap <silent> <Space>X !xmpfilter -a<CR>
nmap <silent> <Space>X mzggVG!xmpfilter -a<CR>'z
