#!/bin/bash
# 
# Author       : Jan Larres <jan@majutsushi.net>
# Created      : 2010-12-04 17:48:23 +1300 NZDT
# Last changed : 2010-12-04 17:48:23 +1300 NZDT

FORTUNES="$HOME/.mutt/fortunes-en $HOME/.mutt/fortunes-de"
KEYID=00A0FD5F

ANSWER="y"

function get_fortune {
    FORTUNE="$(fortune $FORTUNES)"

    echo >&2
    echo "$FORTUNE" >&2

    echo >&2
    echo -n "OK? (Y/n)" >&2

    read ANSWER
}

get_fortune

while [[ "$ANSWER" == "n" ]]; do
    get_fortune
done

echo "-[ OpenPGP key ID: ${KEYID} ]-"
echo "$FORTUNE"
