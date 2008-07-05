" Vim color file
" Name:        midnight
" Maintainer:  Yeii
" Last Change: 2007-11-29
" Version:     0.0.3
" This should work in the GUI. It won't work in  terminals.

" Init
set background=dark
set cul
hi clear
if exists("syntax_on")
    syntax reset
endif
let g:colors_name = "midnight"

""""""""\ Highlighting groups for various occasions \""""""""
hi SpecialKey   gui=reverse	guifg=#00008B		guibg=bg
hi NonText      gui=NONE	guifg=#191970		guibg=bg
hi Directory    gui=NONE	guifg=#20B2AA		guibg=bg
hi ErrorMsg     gui=NONE	guifg=#FFFF00		guibg=#B22222
hi IncSearch    gui=bold	guifg=#FF0000		guibg=bg
hi Search       gui=NONE	guifg=#FF0000		guibg=white
hi MoreMsg      gui=NONE	guifg=#43CD80		guibg=bg
hi ModeMsg      gui=NONE	guifg=#90EE90		guibg=#00688B
hi LineNr       gui=underline	guifg=#607B8B		guibg=#121212
hi Question     gui=bold	guifg=#4EEE94		guibg=bg
hi StatusLine   gui=NONE	guifg=#FFFFFF		guibg=#122046
hi StatusLineNC gui=NONE	guifg=#CDB79E		guibg=#003248
hi VertSplit    gui=NONE	guifg=#CDB79E		guibg=#003248
hi Title        gui=bold	guifg=#8A2BE2		guibg=bg
hi Visual       gui=NONE	guifg=#FFD700		guibg=#191970
hi VisualNOS    gui=underline	guifg=#FFD700		guibg=#424242
hi WarningMsg   gui=NONE	guifg=#FFFF00		guibg=bg
hi WildMenu     gui=reverse	guifg=#7FFF00		guibg=bg
hi Folded       gui=bold	guibg=#E0EEEE		guibg=#104E8B
hi FoldColumn   gui=NONE	guifg=#E0FFFF		guibg=#104E8B
hi DiffAdd      gui=NONE	guifg=fg		guibg=#008B8B
hi DiffChange   gui=NONE	guifg=fg		guibg=#008B00
hi DiffDelete   gui=NONE	guifg=#8B3A62		guibg=bg
hi DiffText     gui=bold	guifg=#FF69B4		guibg=#00008B
hi Cursor       gui=NONE	guifg=#000000		guibg=#00FF00
hi CursorLine   gui=NONE	guifg=NONE		guibg=#002222
hi CursorColumn gui=NONE	guifg=NONE		guibg=#003333

""""""\ Syntax highlighting groups \""""""
hi Normal       gui=NONE	guifg=#E6E6FA		guibg=black
hi Comment      gui=NONE	guifg=#4A708B		guibg=bg
hi Constant     gui=NONE	guifg=#00CDCD		guibg=bg
"hi Character   gui=NONE	guifg=#00FFFF		guibg=bg
hi Special      gui=NONE	guifg=#ddb880		guibg=bg
"hi SpecialChar gui=bold	guifg=#FFFFFF		guibg=bg
"hi Tag         gui=bold	guifg=#FFFFFF		guibg=bg
"hi Delimiter   gui=bold	guifg=#FFFFFF		guibg=bg
"hi Debug       gui=bold	guifg=#FFFFFF		guibg=bg
hi Identifier   gui=NONE	guifg=#6495ED		guibg=bg
hi Statement    gui=NONE	guifg=#54FF9F		guibg=bg
hi PreProc      gui=NONE	guifg=#00BFFF		guibg=bg
hi Type         gui=NONE	guifg=#4169E1		guibg=bg
hi Underlined   gui=underline	guifg=#009ACD		guibg=bg
hi Ignore       gui=NONE	guifg=#BFBFBF		guibg=bg
hi Error        gui=reverse	guifg=#FF00FF		guibg=#F0E68C
hi Todo         gui=NONE	guifg=#EEEE33		guibg=#551A8B
hi String       gui=NONE	guifg=#A4D3EE		guibg=bg
hi Number       gui=NONE	guifg=#8470FF		guibg=bg
"hi Float       gui=NONE	guifg=#00FFFF		guibg=bg
hi Boolean      gui=NONE	guifg=#00FFFF		guibg=bg
hi Function     gui=NONE	guifg=#87CEEB		guibg=bg
hi Conditional  gui=NONE	guifg=#90EE90		guibg=bg
hi Repeat       gui=NONE	guifg=#7FFFD4		guibg=bg
hi Label        gui=NONE	guifg=#FFA500		guibg=bg
hi Operator     gui=NONE	guifg=#00FF7F		guibg=bg
hi Keyword      gui=NONE	guifg=#00FA9A		guibg=bg
hi Exception    gui=NONE	guifg=#D2691E		guibg=bg
hi Include      gui=NONE	guifg=#63B8FF		guibg=bg
hi Define       gui=NONE	guifg=#1E90FF		guibg=bg
hi Macro        gui=NONE	guifg=#B0E0E6		guibg=bg
hi PreCondit    gui=NONE	guifg=#8EE5EE		guibg=bg
hi StorageClass gui=NONE	guifg=#ADD8E6		guibg=bg
hi Structure    gui=NONE	guifg=#87CEFF		guibg=bg
hi Typedef      gui=NONE	guifg=#4682B4		guibg=bg
hi CursorIM     gui=NONE	guifg=#FFFFFF		guibg=#00FF00
