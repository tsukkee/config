let b:caw_wrap_oneline_comment = ["<!--", "-->"]
let b:caw_wrap_multiline_comment = {'right': '-->', 'bottom': '', 'left': '<!--', 'top': ''}

let b:match_ignorecase = 1
let b:match_words = '<:>,' .
\ '<\@<=[ou]l\>[^>]*\%(>\|$\):<\@<=li\>:<\@<=/[ou]l>,' .
\ '<\@<=dl\>[^>]*\%(>\|$\):<\@<=d[td]\>:<\@<=/dl>,' .
\ '<\@<=\([^/][^ \t>]*\)[^>]*\%(>\|$\):<\@<=/\1>'

setlocal matchpairs+=<:>
