# ==================== Modules ==================== "
# completion
autoload -U compinit
compinit

# colorize
zstyle ':completion:*' list-colors ''
# ignore case
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'
# sudo
zstyle ':completion:*:sudo:*' command-path /opt/local/bin /opt/local/sbin \
    /usr/local/sbin /usr/local/bin /usr/sbin /usr/bin /sbin /bin
# completer for auto-fu
zstyle ':completion:*' completer _oldlist _complete

# color
autoload -U colors
colors


# ==================== Events ==================== "
typeset -ga chpwd_functions
typeset -ga precmd_functions
typeset -ga preexec_functions


# ==================== Settings ==================== "
setopt print_eight_bit   #
setopt auto_pushd        # cd history
setopt pushd_ignore_dups #
setopt list_packed       # compact list display
setopt nolistbeep        # no beep
setopt auto_list         # show completion list automatically
setopt auto_menu         # completion with Tab key
setopt brace_ccl         # expand brace such as {a-za-z}
setopt multios           # use muliple redirect and pipe
setopt ignore_eof        # ignore <C-d>

# history
HISTFILE=$HOME/.zsh_history
HISTSIZE=100000
SAVEHIST=100000
setopt hist_ignore_dups
setopt hist_ignore_all_dups
setopt hist_reduce_blanks
setopt share_history


# ==================== Keybind ==================== "
# like vi
bindkey -v

# Normal mode
bindkey -a "q" push-line
bindkey -a "^H" run-help

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


# ==================== Prompt ==================== "
# PROMPT
function _colorize_prompt {
    PROMPT="%{%(?.$fg[green].$fg[red])%}%n@%m %D{%m/%d %H:%M:%S} $reset_color$fg[yellow]%~%{$reset_color%}
%# "
}
_colorize_prompt
precmd_functions+=_colorize_prompt

# RPROMPT
vi_mode_str="%{$fg[green]%}--INSERT--%{$reset_color%}"
function _set_rprompt {
    # RPROMPT="%{$fg[cyan]%}$vcs_info_msg_0_%{$reset_color%}[$vi_mode_str]"
    RPROMPT="%{$fg[cyan]%}$vcs_info_msg_0_%{$reset_color%}"
}

# vcs_info
autoload -Uz vcs_info
zstyle ':vcs_info:*' enable git svn hg bzr cvs
zstyle ':vcs_info:*' formats '(%s)-[%b]'
zstyle ':vcs_info:*' actionformats '(%s)-[%b|%a]'
zstyle ':vcs_info:(svn|bzr):*' branchformat '%b:r%r'
zstyle ':vcs_info:bzr:*' use-simple true

function _vsc_info {
    psvar=()
    LANG=en_US.UTF-8 vcs_info
    _set_rprompt
}
_vsc_info
precmd_functions+=_vsc_info

# show vi mode
function _vi_rprompt {
    case $KEYMAP in
        vicmd)
        vi_mode_str="%{$fg[red]%}--NORMAL--%{$reset_color%}"
        ;;
        main|viins)
        vi_mode_str="%{$fg[green]%}--INSERT--%{$reset_color%}"
        ;;
    esac
    _set_rprompt
    zle reset-prompt
}
function zle-line-init {
    auto-fu-init
    _vi_rprompt
}
function zle-keymap-select {
    _vi_rprompt
}
zle -N zle-line-init
zle -N zle-keymap-select


# ==================== screen/tmux ==================== "
function _screen_dirname() {
    if [ "$WINDOW" != '' -o "$TMUX" != '' ]; then
        echo -ne "\ek$(basename $(pwd))\e\\"
    fi
}
precmd_functions+=_screen_dirname

function _screen_cmdname() {
    if [ "$WINDOW" != '' -o "$TMUX" != '' ]; then
        echo -ne "\ek# $1\e\\"
    fi
}
preexec_functions+=_screen_cmdname


# ==================== Aliases ==================== "
set complete_aliases
alias ls="ls -GF"
alias scr="screen -xR"
alias tm="tmux attach-session || tmux"
alias refe="refe-1_8_7"
alias -g C="| iconv -f utf-8 -t sjis | pbcopy"
alias -g Csjis="| pbcopy"
alias -g Ceuc="| iconv -f euc-jp -t sjis | pbcopy"
alias -g EU="| iconv -f euc-jp -t utf-8"
alias -g SU="| iconv -f sjis -t utf-8"


# ==================== Ohters ==================== "
# auto-fu
# source $HOME/.zsh.d/auto-fu.zsh/auto-fu.zsh
{ . ~/.zsh.d/auto-fu; auto-fu-install; }
zstyle ':auto-fu:highlight' input bold
zstyle ':auto-fu:highlight' completion fg=black,bold
zstyle ':auto-fu:highlight' completion/one fg=white,bold,underline
zstyle ':auto-fu:var' postdisplay $'\n-azfu-'
bindkey -M afu "^P" history-beginning-search-backward-end
bindkey -M afu "^N" history-beginning-search-forward-end
bindkey -M afu "^]" insert-last-word
bindkey -M afu "^[s" _quote-previous-word-in-single
bindkey -M afu "^[d" _quote-previous-word-in-double

# cdd
# source $HOME/.zsh.d/cdd.sh
# export CDD_PWD_FILE=$HOME/.zsh.d/cdd_pwd_list
# chpwd_functions+=_reg_pwd_screennum
# function chpwd() {
    # _reg_pwd_screennum
# }

# visual mode
# source ~/.zsh.d/visualmode.sh

# load loadl settings
test -f $HOME/.zshrc.local && source $HOME/.zshrc.local
