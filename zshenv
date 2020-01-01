# ignore /etc/zprofile, /etc/zshrc to keep PATH settings as intended
setopt no_global_rcs

# Language
export LANG=ja_JP.UTF-8
export __CF_USER_TEXT_ENCODING='0x1F5:0x08000100:14'

# Path
typeset -U path
path=(/usr/local/bin(N-/) /opt/local/bin(N-/) /opt/local/sbin(N-/) /usr/X11/bin(N-/) $path)

# Editor
if test -x /opt/local/bin/vim; then
    export EDITOR=/opt/local/bin/vim
else
    export EDITOR=/usr/bin/vim
fi

# Local
test -f $HOME/.zshenv.local && source $HOME/.zshenv.local

