#!/bin/bash
#
# https://askubuntu.com/questions/218953/can-i-control-brightness-on-second-monitor
# See /usr/share/doc/xss-lock/dim-screen.sh
# Interferes with redshift :(

set -eEu -o pipefail
IFS=$'\n\t'

set_brightness() {
    for monitor in $(get_monitors); do
        xrandr --output "$monitor" --brightness "$1"
    done
}

get_monitors() {
    xrandr -q | sed -r -n -e 's/^([A-Z0-9-]+) connected .*/\1/p'
}

set_brightness "$1"
