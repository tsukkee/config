# 基本の設定
umask 22

# キーバインド
# bindkey -v # vi風
bindkey -e # emacs風

# 履歴補完
autoload history-search-end
zle -N history-beginning-search-backward-end history-search-end
zle -N history-beginning-search-forward-end history-search-end
bindkey "^P" history-beginning-search-backward-end
bindkey "^N" history-beginning-search-forward-end

# 補完設定
autoload -U compinit
compinit

zstyle ':completion:*' list-colors ''
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'

# autoload predict-on
# predict-on

setopt auto_pushd  # cd履歴
# setopt correct     # コマンド修正
setopt list_packed # 表示をコンパクトに
setopt nolistbeep  # 音鳴らさない
setopt auto_list   # 自動で候補一覧表示
setopt brace_ccl   # {a-za-z}をブレース展開
setopt multios     # 複数のリダイレクトやパイプに対応

# 履歴
HISTFILE=$HOME/.zsh_history
HISTSIZE=100000
SAVEHIST=100000
setopt hist_ignore_dups
setopt hist_ignore_all_dups
setopt hist_reduce_blanks
setopt share_history

# 環境変数
export DISPLAY=localhost:0.0
export PATH=/usr/local/bin:/usr/local/sbin/:\
/usr/bin:/usr/sbin:\
/usr/X11R6/bin:\
/Developer/SDKs/Flex2/bin:$PATH

export MANPATH=/usr/local/man:\
/usr/share/man:\
/usr/X11R6/man:$MANPATH

test -d /opt && export PATH=/opt/local/bin:/opt/local/sbin:$PATH && export MANPATH=/opt/local/share/man:$MANPATH

export LANG=ja_JP.UTF-8

export EDITOR=vim
export PAGER=lv
export BLOCKSIZE=k
export QTDIR=/opt/local/lib/qt3
export C_INCLUDE_PATH=/opt/local/include:$C_INCLUDE_PATH
export CPLUS_INCLUDE_PATH=/opt/local/include:$CPLUS_INCLUDE_PATH
export OBJC_INCLUDE_PATH=/opt/local/include:$OBJC_INCLUDE_PATH
export HREF_DATADIR=/usr/local/share/ref

PROMPT='%S%n @ %m:%~ %s
%# '

function chpwd() {
    RPROMPT=`ruby -e "d=Dir.new('./');%w(.hg .git .svn).each{|i| puts i if d.include?(i)}"`
}
chpwd

# エイリアス
alias less=lv
alias ctags=jexctags
alias ls="ls -GF"
alias -g C="| iconv -f utf-8 -t sjis | pbcopy"
alias -g Csjis="| pbcopy"
alias -g Ceuc="| iconv -f euc-jp -t sjis | pbcopy"
alias -g EU="| iconv -f euc-jp -t utf-8"
alias -g SU="| iconv -f sjis -t utf-8"
alias cdf="cd \"\`fcd\`\""
