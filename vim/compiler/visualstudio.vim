" Vim compiler file
" Compiler:         Visual Studio
" Maintainer:       Takayuki Tsukitani
" Latest Revision:  2008-8-5

if exists("current_compiler")
  finish
endif
let current_compiler = "visualstudio"

let s:cpo_save = &cpo
set cpo-=C

setlocal makeprg=\"C:\\Program\ Files\\Microsoft\ Visual\ Studio\ 8\\Common7\\IDE\\devenv.com\"\ $* 
setlocal errorformat=%*\\d>%f(%l)\ :\ %t%[A-z]%#\ %m

command! -complete=file -buffer -nargs=1 VSDebugBuild silent make /Build Debug <args>
command! -complete=file -buffer -nargs=1 VSDebugRebuild silent make /Rebuild Debug <args>

command! -complete=file -buffer -nargs=1 VSReleaseBuild silent make /Build Release <args>
command! -complete=file -buffer -nargs=1 VSReleaseRebuild silent make /Rebuild Release <args>

let &cpo = s:cpo_save
unlet s:cpo_save

