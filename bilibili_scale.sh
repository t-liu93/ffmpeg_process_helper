#!/bin/bash

TMP=/home/tianyu/NAS/TempVideo
WD=$TMP/toBilibiliScale
OUTPUT=$TMP/output
OUTFILE=$(date +"%Y-%m-%d_%H-%M-%S").mp4
TMPFILE=/home/tianyu/$OUTFILE

mkdir -p $OUTPUT

inotifywait -m $WD -e create -e close_write -e moved_to -e modify | 
    while read dir action file; do
        /home/tianyu/ffmpeg/bin/ffmpeg -y -i $WD/$file -i $WD/../bilibiliwatermark.png  -c:v libx264 -b:v 5850k -maxrate 12M -bufsize 24M -preset slow -profile:v high -level 4.2 -filter_complex "overlay=0:0,format=yuv420p,scale=w=1920:h=1080:sws_flags=lanczos" -pass 1 -passlogfile /home/tianyu/ffmpeg/ffmpeglog -an -f mp4 /dev/null
        /home/tianyu/ffmpeg/bin/ffmpeg -i $WD/$file -i $WD/../bilibiliwatermark.png -c:v libx264 -b:v 5850k -maxrate 12M -bufsize 24M -preset slow -profile:v high -level 4.2 -filter_complex "overlay=0:0,format=yuv420p,scale=w=1920:h=1080:sws_flags=lanczos" -pass 2 -passlogfile /home/tianyu/ffmpeg/ffmpeglog -c:a libfdk_aac -b:a 320k -ar 48000 $TMPFILE

        rm $WD/$file
        mv $TMPFILE $OUTPUT
        chown -R tianyu:smb $OUTPUT
        chmod -R 0770 $OUTPUT
    done


