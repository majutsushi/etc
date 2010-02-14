#!/bin/bash

#
# Set default Windowmanager
#
if test -z "$WINDOWMANAGER"; then
    #WINDOWMANAGER=enlightenment
    #WINDOWMANAGER="deskmenu --quit"
    WINDOWMANAGER=awesome
    #WINDOWMANAGER=fluxbox
fi

#. $HOME/.bashrc

# =--> Set Xft DPI to match my X settings
#      when set here, xsm seems to handle the dpi better
#
#echo "Xft.dpi: 84" | xrdb -merge -

# =--> Use nice Xcursor themes
#
#echo "Xcursor.theme: redglass" | xrdb -merge -
#echo "Xcursor.size: 20" | xrdb -merge -

# Pointer appearance
#   - xcb does not support Xcursor yet
/usr/bin/xsetroot -cursor_name left_ptr

#export JAVA_HOME=/opt/java
#export PATH=$PATH:$HOME/bin:$JAVA_HOME/bin
#export LIBDIRPATH=$HOME/.lib
#export GTK_IM_MODULE="scim"

#
# start some stuff
#
#xmodmap -e "pointer = 1 2 6 4 5 8 9 3 7 10 11"
#xmodmap ~/.Xmodmap
#xset s off
#xset -dpms
#kinput2 -canna &
#export XIM_PROGRAM="scim -d"
#export XMODIFIERS=@im=SCIM
#xrdb -merge .Xresources
#imwheel -b 006700
#test -f /#avfs-on
gnome-settings-daemon &
gnome-power-manager &
kupfer --no-splash &

#
# finally start the window manager
#
exec $WINDOWMANAGER

# call failsafe
exit 0
