#!/bin/bash
#
# .xsession
#

#
# Some bash (1 and 2) settings to avoid trouble on a
# failed program call.
#
test -n "$BASH" && set +o posix
no_exit_on_failed_exec=1
type shopt > /dev/null 2>&1 && shopt -s execfail

#
# This should be the default
#
#export TERM=xterm

#
# Set default Windowmanager
#
if test -z "$WINDOWMANAGER"; then
    #WINDOWMANAGER=enlightenment
    #WINDOWMANAGER="deskmenu --quit"
    WINDOWMANAGER=dwm
    #WINDOWMANAGER=fluxbox
fi

. $HOME/.bashrc

# =--> Set Xft DPI to match my X settings
#      when set here, xsm seems to handle the dpi better
#
#echo "Xft.dpi: 84" | xrdb -merge -

# =--> Use nice Xcursor themes
#
#echo "Xcursor.theme: redglass" | xrdb -merge -
#echo "Xcursor.size: 20" | xrdb -merge -

#export JAVA_HOME=/opt/java
#export PATH=$PATH:$HOME/bin:$JAVA_HOME/bin
export LIBDIRPATH=$HOME/.lib
#export GTK_IM_MODULE="scim"

#
# start some stuff
#
#xmodmap -e "pointer = 1 2 6 3 7 4 5"
xmodmap -e "pointer = 1 2 6 4 5 8 9 3 7 10 11"
xmodmap ~/.Xmodmap
xset s off
xset -dpms
#kinput2 -canna &
#export XIM_PROGRAM="scim -d"
#export XMODIFIERS=@im=SCIM
xrdb -merge .Xresources
#imwheel -b 006700
#test -f /#avfs-on

if [ "$WINDOWMANAGER" = "deskmenu --quit" ] ; then
#    gnome-settings-daemon &
    xfce-mcs-manager
    xfwm4 --daemon
    xftaskbar4 &
    rox -p=Default -l=Default
    gkrellm &
    gdeskcal &
    xbindkeys
    scim -d &
    tomboy --tray-icon &
    devilspie &
    procmail_logger &
#    lineakd &
fi

if [ "$WINDOWMANAGER" = "dwm" ] ; then
#    /sbin/start-stop-daemon --start --exec /usr/bin/mpd
#    /sbin/start-stop-daemon --start --exec /usr/bin/mpdscribble --startas /home/olorin/bin/mpdscribble.sh
    gnome-settings-daemon &
    gnome-volume-manager
    scim -d &
#    $HOME/bin/mpd.sh
#    xbindkeys
fi

# xscreensaver -nosplash &

# galeon -s &

# day planer deamon
# pland &

#
# finally start the window manager
#
if [ "$WINDOWMANAGER" = "dwm" ]; then
    while true
    do
        if [ `mpc | wc -l` = 3 ]; then
            MPC="[`mpc | head -1`]"
        else
            MPC=
        fi
        echo $MPC `date` `uptime | sed 's/.*,//'`
        sleep 1
    done | while true; do dwm; done
else
    exec $WINDOWMANAGER
fi

# call failsafe
exit 0
