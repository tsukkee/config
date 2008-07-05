#!/bin/sh

userresources=$HOME/.Xresources
usermodmap=$HOME/.Xmodmap
sysresources=/etc/X11/xinit/.Xresources
sysmodmap=/etc/X11/xinit/.Xmodmap

# merge in defaults and keymaps

if [ -f "$sysresources" ]; then
    xrdb -merge "$sysresources"
fi

if [ -f "$sysmodmap" ]; then
    xmodmap "$sysmodmap"
fi

if [ -f "$userresources" ]; then
    xrdb -merge "$userresources"
fi

if [ -f "$usermodmap" ]; then
    xmodmap "$usermodmap"
fi

[-f "/opt/local/bin/kinput2"] && /opt/local/bin/kinput2 &

echo "hoge"

exec quartz-wm

# export KDEWM=kwin
# exec quartz-wm --only-proxy & /opt/local/bin/startkde > /tmp/kde.log 2>&1
