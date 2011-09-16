#!/bin/bash
# lots of code and ideas from https://launchpad.net/byobu
# and thus licenced under the GPLv3

sessionname=1
battery=1
cpucount=1
cpufreq=1
cputemp=1
disk=1
loadavg=0
logo=1
memusage=1
network=0
uname=1
MP="/"
#NETDEV=eth0

if [[ -r $HOME/.etc/screen/statusrc ]]; then
    . $HOME/.etc/screen/statusrc
fi

ismac() {
    [[ "$(uname -s)" == "Darwin" ]] && return 0
    return 1
}

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

print_sessionname() {
    FULLNAME=$(screen -ls | grep --color=no -o "${PPID}[^[:space:]]*")
    NAME=$(echo $FULLNAME | awk -F '.' '{ print $2 }')
    printf "$(color b k W)$NAME$(color -) "
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
            printf "$(color b k r)%s$(color -)$(color k y)%s$(color -)$(color b k Y)%s$(color -)" "\\" "o" "/"
        elif grep -i arch /etc/issue >/dev/null; then
            printf "$(color b w b) A $(color -)"
        else
            printf "$(color b d r)?$(color -)"
        fi
    elif uname -s | grep -i netbsd >/dev/null; then
        printf "$(color k K)\\$(color -)$(color k R)~$(color -)"
    elif ismac; then
        printf "$(color b k W)i$(color -)"
    fi
}

print_cpucount() {
    if ismac; then
        count=$(sysctl hw.ncpu | awk '{ print $2 }')
    elif command -v getconf >/dev/null 2>&1; then
        count=$(getconf _NPROCESSORS_ONLN 2>/dev/null || grep -ci "^processor" /proc/cpuinfo)
    fi
    [ "$count" = "1" ] || printf "%sx" "$count"
}

print_cpufreq() {
    if [ -r "/sys/devices/system/cpu/cpu0/cpufreq/scaling_cur_freq" ]; then
        freq=$(awk '{ printf "%.1f", $1 / 1000000 }' /sys/devices/system/cpu/cpu0/cpufreq/scaling_cur_freq)
    elif ismac; then
        freq=$(system_profiler SPHardwareDataType | awk '/Processor Speed/ { print $3 }')
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
    printf "$(color b c W)%s$(color -)$(color c W)%s$(color -) " "$freq" "GHz"
}

print_cputemp() {
    if [ -r "/sys/class/hwmon/hwmon0/device/temp2_input" ]; then
        temp=$(cat /sys/class/hwmon/hwmon0/device/temp2_input | awk '{ printf "%.1f", $1 / 1000 }')
        printf "$(color b k Y)%s$(color -)$(color k Y)\260C$(color -) " "$temp"
    fi
}

print_disk() {
    [[ -z "$MP" ]] && MP="/"
    disk=$(df -P -h "$MP" 2>/dev/null || df -h "$MP")
    disk=$(echo "$disk" | tail -n 1 | awk '{print $4 " " $5}' | sed "s/\([^0-9\. ]\)/ \1/g" | awk '{printf "%d%sB,%d%%", $1, $2, $3}')
    printf "$(color M W)%s$(color -) " "$disk" | sed "s/\([0-9]\+\)/$(color -)$(color b M W)\1$(color -)$(color M W)/g"
}

print_loadavg() {
    printf "$(color Y k)%s$(color -) " $(awk '{print $1}' /proc/loadavg)
}

print_totalmem() {
    if ismac; then
        mem=$(sysctl hw.physmem | awk '{ print $2 }')
    else
        mem=$(grep -m1 MemTotal /proc/meminfo  | awk '{print $2}')
    fi
    if [ $mem -ge 1048576 ]; then
        mem=$(echo "$mem" | awk '{ printf "%.1f", $1 / 1048576 }')
        unit="GB"
    elif [ $mem -ge 1024 ]; then
        mem=$(echo "$mem" | awk '{ printf "%.0f", $1 / 1024 }')
        unit="MB"
    else
        mem="$mem"
        unit="KB"
    fi
    printf "$(color b g W)%s$(color -)$(color g W)$unit$(color -)" "$mem"
}

print_memusage() {
    print_totalmem

    if command -v free >/dev/null 2>&1; then
        f=$(free | awk '/buffers\/cache:/ {printf "%.0f", 100*$3/($3 + $4)}')
    elif grep -q -s "Mem:" /proc/meminfo; then
        f=$(grep "Mem:" /proc/meminfo | awk '{printf "%.0f", $3/$2 * 100}')
    elif ismac; then
        mem=$(sysctl hw.physmem | awk '{ print $2 }')
        pagesize=$(vm_stat | awk '/page size/ { print $8 }')
        active=$(vm_stat | awk '/Pages active/ { print $3 }')
        wired=$(vm_stat | awk '/Pages wired/ { print $4 }')
        f=$(echo "100 * $pagesize * ($active + $wired) / $mem" | bc)
    fi

    if [ -n "$f" ]; then
        printf "$(color g W),$(color -)$(color b g W)%s$(color -)$(color g W)%%$(color -) " "$f"
    else
        printf " "
    fi
}

print_uname() {
    uname -srm
}

print_network() {
    [[ ! -d /proc/net ]] && exit 0

    if [[ -n "$NETDEV" ]]; then
        interface="$NETDEV"
    else
        interface=$(tail -n1 /proc/net/route  | awk '{print $1}')
    fi

    t2=$(date +%s)
    for i in down up; do
        cache="$HOME/.cache/screen/network_$i"
        t1=$(stat -c %Y "$cache" 2>/dev/null) || t1=0

        if [ $t2 -le $t1 ]; then
            rate=0
        else
            x1=$(cat "$cache" 2>/dev/null) || tx1=0

            if [ "$i" = "up" ]; then
                symbol="^"
                x2=$(grep -m1 "\b$interface:" /proc/net/dev | sed "s/^.*://" | awk '{print $9}')
            else
                symbol="v"
                x2=$(grep -m1 "\b$interface:" /proc/net/dev | sed "s/^.*://" | awk '{print $1}')
            fi

            echo "$x2" > "$cache"

            rate=$(echo "$t1" "$t2" "$x1" "$x2" | awk '{printf "%.0f", ($4 - $3) / ($2 - $1) / 1024 }')

            if [ "$rate" -lt 0 ]; then
                rate=0
            fi

            if [ "$rate" -gt 1048576 ]; then
                rate=$(echo "$rate" | awk '{printf "%.1f", $1/1048576}')
                unit="GB/s"
            elif [ "$rate" -gt 1024 ]; then
                rate=$(echo "$rate" | awk '{printf "%.1f", $1/1024}')
                unit="MB/s"
            else
                unit="kB/s"
            fi
        fi
        printf "$symbol$(color b m w)$rate$(color -)$(color m w)$unit$(color -) "
    done
}

eval x="\$$1" || exit 1
if [[ "$x" = "1" ]]; then
    print_${1}
fi
