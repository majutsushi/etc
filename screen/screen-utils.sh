#!/bin/bash

ESC="\005"
color() {
    case "$1" in
        "") return 0 ;;
        -)   printf "$ESC{-}" ;;
        esc)    printf "$ESC" ;;
        bold1)  printf "$ESC{=b }" ;;
        bold2)  printf "$ESC{+b }" ;;
        none)   printf "$ESC{= }" ;;
        invert) printf "$ESC{=r }" ;;
        *)
            if [ "$#" = "2" ]; then
                printf "$ESC{= $1$2}"
            else
                printf "$ESC{=$1 $2$3}"
            fi
        ;;
    esac
}

print_battery() {
    if command -v acpi >/dev/null 2>&1; then
        while true; do
            ACPI=$(acpi -b)
            if [ -n "$ACPI" ]; then
                percent=$(echo $ACPI | cut -d',' -f 2 | tr -d " %")

                if [ "$percent" -lt 20 ]; then
                    color="$(color R w)"
                    bcolor="$(color b R w)"
                elif [ "$percent" -lt 50 ]; then
                    color="$(color Y k)"
                    bcolor="$(color b Y K)"
                else
                    color="$(color G w)"
                    bcolor="$(color b G w)"
                fi

                printf "$bcolor%s$(color -)$color%%$(color -) \n" "$percent"
                sleep 20
            fi
        done
    fi
}

print_logo() {
    if [ -r /etc/issue ]; then
        if grep -i debian /etc/issue >/dev/null; then
            printf "$(color k R)@$(color -)"
        elif grep -i ubuntu /etc/issue >/dev/null; then
            printf "$(color b k r)%s$(color -)$(color k y)%s$(color -)$(color b k Y)%s$(color -)" "\\" "o" "/" || printf "\\o/"
        fi
    elif uname -s | grep -i netbsd >/dev/null; then
        printf "$(color k K)\\$(color -)$(color k R)~$(color -)"
    fi
}

print_cpucount() {
    count=$(getconf _NPROCESSORS_ONLN 2>/dev/null || grep -ci "^processor" /proc/cpuinfo)
    [ "$count" = "1" ] || printf "%sx" "$count"
}

print_cpufreq() {
    if [ -r "/sys/devices/system/cpu/cpu0/cpufreq/scaling_cur_freq" ]; then
        freq=$(awk '{ printf "%.1f", $1 / 1000000 }' /sys/devices/system/cpu/cpu0/cpufreq/scaling_cur_freq)
    else
        if egrep -q -s -i -m 1 "^cpu MHz|^clock" /proc/cpuinfo; then
            freq=$(egrep -i -m 1 "^cpu MHz|^clock" /proc/cpuinfo | awk -F"[:.]" '{ printf "%.1f", $2 / 1000 }')
        else
            # Must scale frequency by number of processors, if counting bogomips
            count=$(getconf _NPROCESSORS_ONLN 2>/dev/null || grep -ci "^processor" /proc/cpuinfo)
            freq=$(egrep -i -m 1 "^bogomips" /proc/cpuinfo | awk -F"[:.]" '{ print $2 }')
            freq=$(echo "$freq" "$count" | awk '{printf "%.1f\n", $1/$2/1000}')
        fi
    fi
    printf "$(color b y K)%s$(color -)$(color y k)%s$(color -) " "$freq" "GHz"
}

case $1 in
    -r) uname -srm
        ;;
    -c) grep -m 1 "^cpu MHz" /proc/cpuinfo | sed "s/^.*: //" | sed "s/\..*$/ MHz/"
        ;;
    -cc) print_cpucount
        ;;
    -cf) print_cpufreq
        ;;
    -b) print_battery
        ;;
    -l) print_logo
        ;;
esac
