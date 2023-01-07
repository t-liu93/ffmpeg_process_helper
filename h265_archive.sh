#!/bin/bash

FFMPEG=/home/tianyu/ffmpeg/bin
TMP=/home/tianyu/NAS/TempVideo
WD=$TMP/toArchive
OUTPUT=$TMP/output
OUTFILE=$(date +"%Y-%m-%d_%H-%M-%S").mov
TMPFILE=/home/tianyu/$OUTFILE

mkdir -p $OUTPUT

inotifywait -m $WD -e create -e close_write -e moved_to -e modify |
    while read dir action file; do
        $FFMPEG/ffmpeg -y -i $WD/$file -c:v libx265 -crf 20 -preset medium -profile:v main10 -pix_fmt yuv420p -tag:v hvc1 -c:a pcm_s24le -c:s copy $TMPFILE
        OUTNAME=${file%.*}
        rm $WD/$file
        mv --backup=numbered $TMPFILE $OUTPUT/$OUTNAME.mov
        chown -R tianyu:smb $OUTPUT
        chmod -R 0770 $OUTPUT
    done


