test -z "$PS1" && return

test -x /opt/local/bin/lv && alias less=/opt/local/bin/lv

alias ls="ls -GFv"

alias cot="open -a /Applications/CotEditor/CotEditor.app "

export PS1="\[\e[7m\]\u:\w\n\[\e[0m\]\$ "

shopt -s checkwinsize
