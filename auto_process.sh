#!/bin/bash

TMPV=/home/tianyu/NAS/TempVideo
QUEUE=$TMPV/queue

line=$(head -n 1 $QUEUE)

DSTBILI=toBilibiliScale
DSTARCH=toArchive
DSTH264=hqH264
DSTBILI4K=toBilibili4K

if [ ! -z "$line" ]; then
    SRC=$(awk -F\-\-\>  '{ print $1}' <<<"${line}")
    DST=`echo $(awk -F\-\-\>  '{ print $2}' <<<"${line}") | sed 's/\\r//g'`
    if [ "$(ls -A $TMPV/$DSTBILI)" ] || [ "$(ls -A $TMPV/$DSTARCH)" ] || [ "$(ls -A $TMPV/$DSTH264)" ] || [ "$(ls -A $TMPV/$DSTBILI4K)" ]; then
        echo "" > /dev/null
        # Still running do nothing
    else
        echo "Output File $SRC to $DST"
        ln -s $TMPV/$SRC $TMPV/$DST
        tail -n +2 "$QUEUE" > "$QUEUE.tmp" && mv "$QUEUE.tmp" "$QUEUE"
        chown tianyu:smb "$QUEUE"
        chmod 0660 "$QUEUE"
    fi
fi
