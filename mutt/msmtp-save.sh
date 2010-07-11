#!/bin/sh
# /home/jan/bin/msmtp-save.sh
# Author       : Jan Larres <jan@majutsushi.net>
# Created      : 2010-07-08 01:25:31 +1200 NZST
# Last changed : 2010-07-08 04:12:03 +1200 NZST

MAIL=$(mktemp)

trap "rm -f $MAIL" INT TERM EXIT

cat > $MAIL

cat $MAIL | lbdb-fetchaddr -a -x 'to:cc:bcc:resent-to'
cat $MAIL | exec /usr/bin/msmtp $*
