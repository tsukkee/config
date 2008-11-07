" settings for arpeggio.vim
call arpeggio#load()

" NERD_tree
Arpeggionnoremap as :NERDTreeToggle<CR>

" FuzzyFinder
Arpeggionnoremap <silent> fn :FuzzyFinderBuffer<CR>
Arpeggionnoremap <silent> fm :FuzzyFinderMruFile<CR>

" Reload brawser
if has('ruby')
    Arpeggionnoremap <silent> ru :<C-u>call ReloadFirefox()<CR>
endif
if has('mac')
    Arpeggionnoremap <silent> ri :<C-u>call ReloadSafari()<CR>
endif
