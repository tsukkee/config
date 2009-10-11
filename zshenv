# Language
LANG=ja_JP.UTF-8; export LANG
__CF_USER_TEXT_ENCODING='0x1F5:0x08000100:14'; export __CF_USER_TEXT_ENCODING;

# Path
PATH=/usr/bin:/usr/sbin:/bin:/sbin
MANPATH=/usr/local/man:/usr/share/man
test -d /usr/X11   && PATH=$PATH:/usr/X11/bin &&
                      MANPATH=$MANPATH:/usr/X11/man:/usr/X11/share/man
test -d /opt       && PATH=/opt/local/bin:/opt/local/sbin:$PATH &&
                      MANPATH=/opt/local/share/man:/opt/local/man:$MANPATH
test -d /usr/local && PATH=/usr/local/bin:/usr/local/sbin:$PATH &&
                      MANPATH=/usr/local/share/man:$MANPATH
test -d /Developer/SDKs/Flex2 && PATH=/Developer/SDKs/Flex2/bin:$PATH
test -d $HOME/.cabal && PATH=$HOME/.cabal/bin:$PATH
export PATH MANPATH

# Library
C_INCLUDE_PATH=$C_INCLUDE_PATH
CPLUS_INCLUDE_PATH=$CPLUS_INCLUDE_PATH
OBJC_INCLUDE_PATH=$OBJC_INCLUDE_PATH
LIBRARY_PATH=$LIBRARY_PATH
LD_LIBRARY_PATH=$LD_LIBRARY_PATH
test -d /opt && C_INCLUDE_PATH=/opt/local/include:$C_INCLUDE_PATH &&
                CPLUS_INCLUDE_PATH=/opt/local/include:$CPLUS_INCLUDE_PATH &&
                OBJC_INCLUDE_PATH=/opt/local/include:$OBJC_INCLUDE_PATH &&
                LIBRARY_PATH=/opt/local/lib:$LIBRARY_PATH &&
                LD_LIBRARY_PATH=/opt/local/lib:$LD_LIBRARY_PATH
test -d $HOME/.cabal && LIBRARY_PATH=$HOME/.cabal/lib:$LIBRARY_PATH &&
                        LD_LIBRARY_PATH=$HOME/.cabal/lib:$LD_LIBRARY_PATH
export C_INCLUDE_PATH CPLUS_INCLUDE_PATH OBJC_INCLUDE_PATH
export LIBRARY_PATH LD_LIBRARY_PATH

# Editor
if test -x /opt/local/bin/vim; then
    EDITOR=/opt/local/bin/vim; export EDITOR
else
    EDITOR=/usr/bin/vim; export EDITOR
fi

# Pager
if test -x /opt/local/bin/lv; then
    PAGER=/opt/local/bin/lv; export PAGER
    LV="-E'$EDITOR +%d'"; export LV
else
    PAGER=/usr/bin/less; export PAGER
fi

# Others
BLOCKSIZE=k; export BLOCKSIZE
LESS='--tabs=4 --no-init --LONG-PROMPT --ignore-case'; export LESS
HREF_DATADIR=/usr/local/share/ref; export HREF_DATADIR
GISTY_DIR="$HOME/Desktop/gisty"; export GISTY_DIR

test -f $HOME/.zshenv.local && source $HOME/.zshenv.local
