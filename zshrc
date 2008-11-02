# Keybind
# bindkey -v # like vi
bindkey -e # like emacs

# history completion
autoload history-search-end
zle -N history-beginning-search-backward-end history-search-end
zle -N history-beginning-search-forward-end history-search-end
bindkey "^P" history-beginning-search-backward-end
bindkey "^N" history-beginning-search-forward-end

# completion setting
autoload -U compinit
compinit

zstyle ':completion:*' list-colors ''
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'

# autoload predict-on
# predict-on

setopt auto_pushd  # cd history
# setopt correct     # correct command
setopt list_packed # compact list display
setopt nolistbeep  # no beep
setopt auto_list   # show completion list automatically
setopt brace_ccl   # expand brace such as {a-za-z}
setopt multios     # use muliple redirect and pipe

# history
HISTFILE=$HOME/.zsh_history
HISTSIZE=100000
SAVEHIST=100000
setopt hist_ignore_dups
setopt hist_ignore_all_dups
setopt hist_reduce_blanks
setopt share_history

# prompt
PROMPT='%S%n @ %m:%~ %s
%# '

# auto commands
typeset -ga chpwd_functions
typeset -ga precmd_functions
typeset -ga preexec_functions

# set directory name to screen
# need "shell zsh" in .screenrc
function _screen_dirname() {
    # if [ $TERM = "screen" ]; then
    if [ $SHELL = "zsh" ]; then
        echo -ne "\ek$(basename $(pwd))\e\\"
    fi
}

# set command name to screen
# need "shell zsh" in .screenrc
function _screen_cmdname() {
    # if [ $TERM = "screen" ]; then
    if [ $SHELL = "zsh" ]; then
        echo -ne "\ek# $1\e\\"
    fi
}

# display current SCM in RPROMPT
function _rprompt() {
    # git
    local -A git_res
    git_res=`git branch -a --no-color 2> /dev/null`
    if [ $? = "0" ]; then
        git_res=`echo $git_res | grep '^*' | tr -d '\* '`
        RPROMPT="%Sgit [$git_res]%s"
        return
    fi

    # hg
    local -A hg_res
    hg_res=`hg branch 2> /dev/null`
    if [ $? = "0" ]; then
        RPROMPT="%Shg [$hg_res]%s"
        return
    fi

    # svn
    if [ -d .svn ]; then
        RPROMPT="%Ssvn%s"
        return
    fi

    # none
    RPROMPT=""
}

# function chpwd() {
   # RPROMPT=`ruby -e "d=Dir.new('./');%w(.hg .git .svn).each{|i| puts i if d.include?(i)}"`
# }
# chpwd

precmd_functions+=_rprompt
precmd_functions+=_screen_dirname
preexec_functions+=_screen_cmdname

# aliases
test -x /opt/local/bin/lv && alias less=/opt/local/bin/lv
test -x /opt/local/bin/jexctags && alias ctags=jexctags
alias ls="ls -GF"
alias scr="screen -xR"
alias -g C="| iconv -f utf-8 -t sjis | pbcopy"
alias -g Csjis="| pbcopy"
alias -g Ceuc="| iconv -f euc-jp -t sjis | pbcopy"
alias -g EU="| iconv -f euc-jp -t utf-8"
alias -g SU="| iconv -f sjis -t utf-8"
alias cdf="cd \"\`fcd\`\""

# yet another rm
source ~/.zsh.d/yarm.sh
