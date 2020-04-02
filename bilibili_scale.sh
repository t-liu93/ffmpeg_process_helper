#!/bin/bash

TMP=/home/tianyu/NAS/TempVideo
WD=$TMP/toBilibili
OUTPUT=$TMP/output

midkr -p $OUTPUT

inotifywait -m $WD -e close_write | 
    while read file; do
        /home/tianyu/ffmpeg/bin/ffmpeg -y -i $WD/$file -c:v libx264 -b:v 5850k -maxrate 23850k -bufsize 48M -preset slow -vf "format=yuv420p,scale=w=1920:h=1080:sws_flags=lanczos" -an -f mp4 /dev/null
        /home/tianyu/ffmpeg/bin/ffmpeg -i $WD/$file -c:v libx264 -b:v 5850k -maxrate 23850k -bufsize 48M -preset slow -vf "format=yuv420p,scale=w=1920:h=1080:sws_flags=lanczos" -c:a libfdk_aac -b:a 320k -ar 44100 $OUTPUT/$(date +"%Y-%m-%d_%H-%M-%S").mp4

        rm $WD/$file
        chown -R tianyu:smb $OUTPUT
        chmod -R 0770 $OUTPUT
    done


