# Language
export LANG=ja_JP.UTF-8
export __CF_USER_TEXT_ENCODING='0x1F5:0x08000100:14'

# Path
PATH=/usr/bin:/usr/sbin:/bin:/sbin
MANPATH=/usr/share/man
test -d /opt/X11   && PATH=$PATH:/opt/X11/bin &&
                      MANPATH=$MANPATH:/opt/X11/share/man
test -d /usr/X11   && PATH=$PATH:/usr/X11/bin &&
                      MANPATH=$MANPATH:/usr/X11/man:/usr/X11/share/man
test -d /opt       && PATH=/opt/local/bin:/opt/local/sbin:$PATH &&
                      MANPATH=/opt/local/share/man:/opt/local/man:$MANPATH
test -d /usr/local && PATH=/usr/local/bin:/usr/local/sbin:$PATH &&
                      MANPATH=/usr/local/share/man:/usr/local/man:$MANPATH
test -d $HOME/go && PATH=$HOME/go/bin:$PATH
test -d /Developer/SDKs/Flex2 && PATH=/Developer/SDKs/Flex2/bin:$PATH
export PATH MANPATH

# Library
if [ -d /opt ]; then
    export C_INCLUDE_PATH=/opt/local/include:$C_INCLUDE_PATH
    export CPLUS_INCLUDE_PATH=/opt/local/include:$CPLUS_INCLUDE_PATH
    export OBJC_INCLUDE_PATH=/opt/local/inclulde:$OBJC_INCLUDE_PATH
    export LIBRARY_PATH=/opt/local/lib:$LIBRARY_PATH
    export DYLD_FALLBACK_LIBRARY_PATH=.:/opt/local/lib:$DYLD_FALLBACK_LIBRARY_PATH
fi

test -d /Library/Haskell && LIBRARY_PATH=/Library/Haskell/current/lib:$LIBRARY_PATH &&
                            LD_LIBRARY_PATH=/Library/Haskell/current/lib:$LD_LIBRARY_PATH
test -d $HOME/.cabal     && LIBRARY_PATH=$HOME/.cabal/lib:$LIBRARY_PATH &&
                            LD_LIBRARY_PATH=$HOME/.cabal/lib:$LD_LIBRARY_PATH

# Editor
if test -x /opt/local/bin/vim; then
    export EDITOR=/opt/local/bin/vim
else
    export EDITOR=/usr/bin/vim
fi

# Pager
if test -x /opt/local/bin/lv; then
    export PAGER=/opt/local/bin/lv
    export LV="-E'$EDITOR +%d'"
else
    export PAGER=/usr/bin/less
fi

# Others
export BLOCKSIZE=k
export LESS='--tabs=4 --no-init --LONG-PROMPT --ignore-case'
export HREF_DATADIR=/usr/local/share/ref
export GISTY_DIR="$HOME/Desktop/gisty"
export PYTHONPATH=$HOME/.hgext:$PYTHONPATH

test -f $HOME/.zshenv.local && source $HOME/.zshenv.local
