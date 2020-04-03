#!/bin/bash

FFMPEG=/home/tianyu/ffmpeg/bin
TMP=/home/tianyu/NAS/TempVideo
WD=$TMP/toArchive
OUTPUT=$TMP/output
OUTFILE=$(date +"%Y-%m-%d_%H-%M-%S").mp4
TMPFILE=/home/tianyu/$OUTFILE

mkdir -p $OUTPUT

inotifywait -m $WD -e create -e close_write -e moved_to -e modify | 
    while read dir action file; do
        $FFMPEG/ffmpeg -i $WD/$file -c:v libx265 -crf 22 -preset medium -profile:v main422-10 -c:a libfdk_aac -b:a 384k -ar 48000 $TMPFILE

        rm $WD/$file
        mv $TMPFILE $OUTPUT
        chown -R tianyu:smb $OUTPUT
        chmod -R 0770 $OUTPUT
    done


