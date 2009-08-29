#!/bin/sh

case $1 in
    -r) lsb_release -d -s
        ;;
    -c) grep -m 1 "^cpu MHz" /proc/cpuinfo | sed "s/^.*: //" | sed "s/\..*$/ MHz/"
        ;;
    -b) acpi -b | cut -d',' -f 2 | tr -d " "
#    -b) echo "bla, 50%, blubb" | cut -d',' -f 2 | tr -d " "
        ;;
esac
