#ulimit -c unlimited
#ulimit -d unlimited
#ulimit -s 65536
#ulimit -u 532
#ulimit -n 10240

export DISPLAY=localhost:0.0
export PATH="/usr/local/bin:/usr/local/sbin:\
/usr/bin:/usr/sbin:\
/bin:/sbin:\
/usr/X11R6/bin:\
/Developer/SDKs/Flex/bin"

export MANPATH="/usr/local/man:\
/usr/share/man:\
/usr/X11R6/man"

test -d /opt && export PATH=/opt/local/bin:/opt/local/sbin:$PATH &&
		export MANPATH=/opt/local/share/man:$MANPATH

export LANG=ja_JP.UTF-8
#export PERL_BADLANG=0

#export EDITOR=emacs
export EDITOR=vim
#export PAGER=lv
export BLOCKSIZE=k
#export LV="-E'emacs +%d'"
export QTDIR=/opt/local/lib/qt3

#alias less=lv
alias ls="ls -GFv"
alias cot="open -a /Applications/CotEditor/CotEditor.app "

#alias vim="/Applications/Vim.app/Contents/MacOS/Vim"
#alias gvim="open -a /Applications/Vim.app"

#export CVS_RSH=ssh

export PS1="\[\e[7m\]\u:\w\n\[\e[0m\]\$ "

umask 22

set -o posix

shopt -s checkwinsize
