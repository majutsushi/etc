#!/bin/bash
# /home/jan/bin/msmtp-save.sh
# Author       : Jan Larres <jan@majutsushi.net>
# Created      : 2010-07-08 01:25:31 +1200 NZST
# Last changed : 2012-02-22 14:30:48 +1300 NZDT

tee >(lbdb-fetchaddr -a -x 'to:cc:bcc:resent-to') | /usr/bin/msmtp "$@"
