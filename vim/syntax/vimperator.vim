" Vim syntax file
" Language:	    VIMperator configuration file
" Maintainer:	    Doug Kearns <dougkearns@gmail.com>
" Latest Revision:  2008 June 13

if exists("b:current_syntax")
  finish
endif

let s:cpo_save = &cpo
set cpo&vim

syn include @javascriptTop syntax/javascript.vim
unlet b:current_syntax

syn keyword vimperatorTodo    FIXME NOTE TODO XXX contained
syn match   vimperatorComment +".*$+ contains=vimperatorTodo,@Spell

syn keyword vimperatorCommand addo[ns] b[uffer] ba[ck] bd[elete] beep bma[rk] bmarks buffers bun[load] bw[ipeout] delbm[arks]
	\ delm[arks] delqm[arks] dl downl[oads] e[dit] ec[ho] echoe[rr] exe[cute] exu[sage] files fo[rward] fw h[elp] ha[rdcopy]
	\ hist[ory] hs javas[cript] js ls ma[rk] map mapc[lear] marks no[remap] noh[lsearch] norm[al] o[pen] pc[lose]
	\ let pref[erences] prefs q[uit] qa[ll] qma[rk] qmarks quita[ll] re[load] reloada[ll] res[tart] sav[eas] sideb[ar] sb[ar]
	\ sbcl[ose] sb[open] se[t] so[urce] st[op] time tN[ext] t[open] tab tabN[ext] tabc[lose] tabe[dit] tabfir[st] tabl[ast]
	\ tabm[ove] tabn[ext] tabnew tabo[nly] tabopen tabp[revious] tabr[ewind] tabs tn[ext] tp[revious] u[ndo] unl[et] unm[ap]
	\ ve[rsion] viu[sage] w[rite] win[open] wine[dit] wo[pen] wq wqa[ll] xa[ll] zo[om] run
	\ contained

syn match vimperatorCommand "!" contained

" FIXME
syn match vimperatorCommandWrapper "\%(!\|\<\h\w*\>\)" contains=vimperatorCommand

syn region vimperatorSet matchgroup=vimperatorCommand start="\<set\=\>" end="$" keepend oneline contains=vimperatorOption
syn keyword vimperatorOption activate act activelinkfgcolor alfc activelinkbgcolor albc complete cpt defsearch ds editor extendedhinttags eht
        \ focuscontent fc nofocuscontent nofc fullscreen fs nofullscreen nofs guioptions go hintmatching hm hintstyle hs hinttags ht hinttimeout hto history hi
        \ hlsearch hls nohlsearch nohls hlsearchstyle hlss incsearch is noincsearch nois ignorecase ic
        \ noignorecase noic insertmode im noinsertmode noim laststatus ls linkbgcolor lbc linkfgcolor lfc linksearch lks
        \ nolinksearch nolks more nomore nextpattern newtab online noonline pageinfo pa popups pps preload nopreload
        \ previewheight pvh previouspattern scroll scr showmode smd noshowmode nosmd showstatuslinks ssli showtabline stal
        \ smartcase scs nosmartcase noscs suggestengines titlestring usermode um nousermode noum verbose vbs visualbell vb novisualbell novb
	\ visualbellstyle t_vb wildmode wim wildoptions wop wordseparators wsp
	\ contained

syn region vimperatorJavascript start="\%(^\s*\%(javascript\|js\)\s\+\)\@<=" end="$" contains=@javascriptTop keepend oneline
syn region vimperatorJavascript matchgroup=vimperatorJavascriptDelimiter
	\ start="\%(^\s*\%(javascript\|js\)\s\+\)\@<=<<\z(\h\w*\)"hs=s+2 end="^\z1$" contains=@javascriptTop fold

" Note: match vim.vim highlighting groups
hi def link vimperatorCommand			Statement
hi def link vimperatorTodo			Todo
hi def link vimperatorComment			Comment
hi def link vimperatorJavascriptDelimiter	Delimiter
hi def link vimperatorOption			PreProc

let b:current_syntax = "vimperator"

let &cpo = s:cpo_save
unlet s:cpo_save

" vim: tw=130:
