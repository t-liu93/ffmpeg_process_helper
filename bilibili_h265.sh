#!/bin/bash

FFMPEG=/home/tianyu/ffmpeg/bin
TMP=/home/tianyu/NAS/TempVideo
WD=$TMP/toBilibili4K
OUTPUT=$TMP/output
OUTFILE=$(date +"%Y-%m-%d_%H-%M-%S").mp4
TMPFILE=/home/tianyu/$OUTFILE

mkdir -p $OUTPUT

inotifywait -m $WD -e create -e close_write -e moved_to -e modify |
    while read dir action file; do
        $FFMPEG/ffmpeg -y -i $WD/$file -i $WD/../bilibiliwatermark.png -filter_complex "overlay=0:0,format=yuv420p" -c:v libx265 -crf 28 -preset medium -profile:v main10 -x265-params "vbv-maxrate=10000:vbv-bufsize=15000" -c:a libfdk_aac -b:a 320k -ar 48000 $TMPFILE
        OUTNAME=${file%.*}
        rm $WD/$file
        mv --backup=numbered $TMPFILE "$OUTPUT"/"$OUTNAME"_bilibili_x265.mp4
        chown -R tianyu:smb $OUTPUT
        chmod -R 0770 $OUTPUT
    done


