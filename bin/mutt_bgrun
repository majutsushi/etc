#!/bin/sh
# @(#) mutt_bgrun $Revision: 1.4 $

#   mutt_bgrun - run an attachment viewer from mutt in the background
#   Copyright (C) 1999-2002 Gary A. Johnson
#
#   This program is free software; you can redistribute it and/or modify
#   it under the terms of the GNU General Public License as published by
#   the Free Software Foundation; either version 2 of the License, or
#   (at your option) any later version.
#
#   This program is distributed in the hope that it will be useful,
#   but WITHOUT ANY WARRANTY; without even the implied warranty of
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#   GNU General Public License for more details.
#
#   You should have received a copy of the GNU General Public License
#   along with this program; if not, write to the Free Software
#   Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.

# SYNOPSIS
#	mutt_bgrun viewer [viewer options] file
#
# DESCRIPTION
#	Mutt invokes external attachment viewers by writing the
#	attachment to a temporary file, executing the pipeline specified
#	for that attachment type in the mailcap file, waiting for the
#	pipeline to terminate, writing nulls over the temporary file,
#	then deleting it.  This causes problems when using graphical
#	viewers such as qvpview and acroread to view attachments. 
#
#	If qvpview, for example, is executed in the foreground, the mutt
#	user interface is hung until qvpview exits, so the user can't do
#	anything else with mutt until he or she finishes reading the
#	attachment and exits qvpview.  This is especially annoying when
#	a message contains several MS Office attachments--one would like
#	to have them all open at once. 
#
#	If qvpview is executed in the background, it must be given
#	enough time to completely read the file before returning control
#	to mutt, since mutt will then obliterate the file.  Qvpview is
#	so slow that this time can exceed 20 seconds, and the bound is
#	unknown.  So this is again annoying. 
#
#	The solution provided here is to invoke the specified viewer
#	from this script after first copying mutt's temporary file to
#	another temporary file.  This script can then quickly return
#	control to mutt while the viewer can take as much time as it
#	needs to read and render the attachment. 
#
# EXAMPLE
#	To use qvpview to view MS Office attachments from mutt, add the
#	following lines to mutt's mailcap file.
#
#	application/msword;             mutt_bgrun qvpview %s
#	application/vnd.ms-excel;       mutt_bgrun qvpview %s
#	application/vnd.ms-powerpoint;  mutt_bgrun qvpview %s
#
# AUTHOR
#	Gary A. Johnson
#	<garyjohn@spk.agilent.com>
#
# ACKNOWLEDGEMENTS
#	My thanks to the people who have commented on this script and
#	offered solutions to shortcomings and bugs, especially Edmund
#	GRIMLEY EVANS <edmundo@rano.org> and Andreas Somogyi
#	<aso@somogyi.nu>.

prog=${0##*/}

# Check the arguments first.

if [ "$#" -lt "2" ]
then
    echo "usage: $prog viewer [viewer options] file" >&2
    exit 1
fi

# Separate the arguments.  Assume the first is the viewer, the last is
# the file, and all in between are options to the viewer.

viewer="$1"
shift

while [ "$#" -gt "1" ]
do
    options="$options $1"
    shift
done

file=$1

# Create a temporary directory for our copy of the temporary file.
#
# This is more secure than creating a temporary file in an existing
# directory.

tmpdir=/tmp/$LOGNAME$$
umask 077
mkdir "$tmpdir" || exit 1
tmpfile="$tmpdir/${file##*/}"

# Copy mutt's temporary file to our temporary directory so that we can
# let mutt overwrite and delete it when we exit.

cp "$file" "$tmpfile"

# Run the viewer in the background and delete the temporary files when done. 

(
    "$viewer" $options "$tmpfile"
    rm -f "$tmpfile"
    rmdir "$tmpdir"
) &
