#!/bin/sh

userresources=$HOME/.Xresources
usermodmap=$HOME/.Xmodmap
sysresources=/opt/X11/lib/X11/xinit/.Xresources
sysmodmap=/opt/X11/lib/X11/xinit/.Xmodmap

# merge in defaults and keymaps

if [ -f $sysresources ]; then

    if [ -x /usr/bin/cpp ] ; then
        xrdb -merge $sysresources
    else
        xrdb -nocpp -merge $sysresources
    fi



fi

if [ -f $sysmodmap ]; then
    xmodmap $sysmodmap
fi

if [ -f "$userresources" ]; then

    if [ -x /usr/bin/cpp ] ; then
        xrdb -merge "$userresources"
    else
        xrdb -nocpp -merge "$userresources"
    fi



fi

if [ -f "$usermodmap" ]; then
    xmodmap "$usermodmap"
fi

# start some nice programs
/Library/Frameworks/UIM.framework/Versions/Current/bin/uim-xim --engine=anthy-utf8 &




if [ -d /opt/X11/lib/X11/xinit/xinitrc.d ] ; then
	for f in /opt/X11/lib/X11/xinit/xinitrc.d/*.sh ; do
		[ -x "$f" ] && . "$f"
	done
	unset f
fi



twm &
xclock -geometry 50x50-1+1 &
xterm -geometry 80x50+494+51 &
xterm -geometry 80x20+494-0 &
exec xterm -geometry 80x66+0+0 -name login
