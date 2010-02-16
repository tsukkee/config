# Keybind
# bindkey -v # like vi
bindkey -e # like emacs

# history completion
autoload history-search-end
zle -N history-beginning-search-backward-end history-search-end
zle -N history-beginning-search-forward-end history-search-end
bindkey "^P" history-beginning-search-backward-end
bindkey "^N" history-beginning-search-forward-end

# smart insert last word
autoload smart-insert-last-word
zle -N insert-last-word smart-insert-last-word
zstyle :insert-last-word match \
    '*([^[:space:]][:alpha:]/\\]|[[:alpha:]/\\][^[:space:]])*'
bindkey '^]' insert-last-word

# completion setting
autoload -U compinit
compinit

# zstyle ':completion:*:default' menu select=1

# quote previous word in single or double quote
autoload -U modify-current-argument
_quote-previous-word-in-single() {
    modify-current-argument '${(qq)${(Q)ARG}}'
    zle vi-forward-blank-word
}
zle -N _quote-previous-word-in-single
bindkey '^[s' _quote-previous-word-in-single

_quote-previous-word-in-double() {
    modify-current-argument '${(qqq)${(Q)ARG}}'
    zle vi-forward-blank-word
}
zle -N _quote-previous-word-in-double
bindkey '^[d' _quote-previous-word-in-double

# colorize
zstyle ':completion:*' list-colors ''
# ignore case
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'
# sudo
zstyle ':completion:*:sudo:*' command-path /opt/local/bin /opt/local/sbin \
    /usr/local/sbin /usr/local/bin /usr/sbin /usr/bin /sbin /bin

# autoload predict-on
# predict-on

setopt print_eight_bit
setopt auto_pushd  # cd history
setopt pushd_ignore_dups
# setopt correct     # correct command
setopt list_packed # compact list display
setopt nolistbeep  # no beep
setopt auto_list   # show completion list automatically
setopt auto_menu   # completion with Tab key
setopt brace_ccl   # expand brace such as {a-za-z}
setopt multios     # use muliple redirect and pipe
setopt ignore_eof  # ignore <C-d>

# history
HISTFILE=$HOME/.zsh_history
HISTSIZE=100000
SAVEHIST=100000
setopt hist_ignore_dups
setopt hist_ignore_all_dups
setopt hist_reduce_blanks
setopt share_history

# color
autoload -U colors
colors

# prompt
function _colorize_prompt {
    PROMPT="%{%(?.$fg[green].$fg[red])%}%n@%m $reset_color$fg[yellow]%~%{$reset_color%}
%# "
}
_colorize_prompt

# rprompt
autoload -Uz vcs_info
zstyle ':vcs_info:*' enable git svn hg bzr cvs
zstyle ':vcs_info:*' formats '(%s)-[%b]'
zstyle ':vcs_info:*' actionformats '(%s)-[%b|%a]'
zstyle ':vcs_info:(svn|bzr):*' branchformat '%b:r%r'
zstyle ':vcs_info:bzr:*' use-simple true
function _vsc_info() {
    psvar=()
    LANG=en_US.UTF-8 vcs_info
    RPROMPT="%{$fg[cyan]%}$vcs_info_msg_0_%{$reset_color%}"
}
_vsc_info

# set directory name to screen
function _screen_dirname() {
    if [ $WINDOW ]; then
        echo -ne "\ek$(basename $(pwd))\e\\"
    fi
}

# set command name to screen
function _screen_cmdname() {
    if [ $WINDOW ]; then
        echo -ne "\ek# $1\e\\"
    fi
}

# auto commands
typeset -ga chpwd_functions
typeset -ga precmd_functions
typeset -ga preexec_functions

precmd_functions+=_colorize_prompt
precmd_functions+=_vsc_info
precmd_functions+=_screen_dirname
preexec_functions+=_screen_cmdname

# aliases
set complete_aliases
# test -x /opt/local/bin/lv && alias less=/opt/local/bin/lv
# test -x /opt/local/bin/jexctags && alias ctags=jexctags
alias ls="ls -GF"
alias scr="screen -xR"
alias tm="tmux attach-session || tmux"
alias -g C="| iconv -f utf-8 -t sjis | pbcopy"
alias -g Csjis="| pbcopy"
alias -g Ceuc="| iconv -f euc-jp -t sjis | pbcopy"
alias -g EU="| iconv -f euc-jp -t utf-8"
alias -g SU="| iconv -f sjis -t utf-8"

function refe() {
    /opt/local/bin/refe $1 | iconv -f euc-jp -t utf-8 | cat
}

test -f $HOME/.zshrc.local && source $HOME/.zshrc.local
