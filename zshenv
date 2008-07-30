# Display
export DISPLAY=localhost:0.0

# Language
export LANG=ja_JP.UTF-8
export __CF_USER_TEXT_ENCODING='0x1F5:0x08000100:14'

# Path
PATH=/usr/bin:/usr/sbin:/bin:/sbin:$PATH
MANPATH=/usr/local/man:/usr/share/man:$MANPATH
test -d /usr/local && PATH=/usr/local/bin:/usr/local/sbin:$PATH &&
                      MANPATH=/usr/local/share/man:$MANPATH
test -d /usr/X11   && PATH=$PATH:/usr/X11/bin &&
                      MANPATH=$MANPATH:/usr/X11/man:/usr/X11/share/man
test -d /opt       && PATH=/opt/local/bin:/opt/local/sbin:$PATH &&
                      MANPATH=/opt/local/share/man:/opt/local/man:$MANPATH
test -d /Developer/SDKs/Flex2 && PATH=/Developer/SDKs/Flex2/bin:$PATH
export PATH MANPATH

# Editor
if test -x /opt/local/bin/vim; then
    EDITOR=/opt/local/bin/vim
else
    EDITOR=/usr/bin/vim 
fi
export EDITOR

# Pager
# if test -x /usr/local/bin/vimpager; then 
    # export PAGER=/usr/local/bin/vimpager
# fi

# Others
export BLOCKSIZE=k
export C_INCLUDE_PATH=/opt/local/include:$C_INCLUDE_PATH
export CPLUS_INCLUDE_PATH=/opt/local/include:$CPLUS_INCLUDE_PATH
export LIBRARY_PATH=/opt/local/lib:$LIBRARY_PATH
export LD_LIBRARY_PATH=/opt/local/lib:$LD_LIBRARY_PATH
export OBJC_INCLUDE_PATH=/opt/local/include:$OBJC_INCLUDE_PATH
export HREF_DATADIR=/usr/local/share/ref
