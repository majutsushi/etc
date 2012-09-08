#!/bin/bash

# Set up an array with outboxes
# sentboxes=( "~/Maildir/cur" "~/Maildir/.Archive" "~/Maildir/.sent" )
sentboxes=( "~/Maildir/.sent" )

# Run mu on each of them
for dir in "${sentboxes[@]}"; do
    mu index --maildir="${dir}" --muhome=~/.mu-sent-index --quiet
done
