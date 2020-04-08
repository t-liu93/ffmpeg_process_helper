#!/bin/bash

FFMPEG=/home/tianyu/ffmpeg/bin
TMP=/home/tianyu/NAS/TempVideo
WD=$TMP/toBilibiliScale
OUTPUT=$TMP/output
OUTFILE=$(date +"%Y-%m-%d_%H-%M-%S").mp4
TMPFILE=/home/tianyu/$OUTFILE

mkdir -p $OUTPUT

inotifywait -m $WD -e create -e close_write -e moved_to -e modify | 
    while read dir action file; do
        FR=$($FFMPEG/ffprobe -v 0 -of csv=p=0 -select_streams v:0 -show_entries stream=r_frame_rate $WD/$file)
        HIGH=$(awk -F/ '{ print $1}' <<<"${FR}")
        LOW=$(awk -F/ '{ print $2}' <<<"${FR}")
        FPS=$(expr $HIGH / $LOW)
        GOP=$(expr $FPS \* 8)
        $FFMPEG/ffmpeg -y -i $WD/$file -i $WD/../bilibiliwatermark.png  -filter_complex "overlay=0:0,format=yuv420p,scale=w=1920:h=1080:sws_flags=lanczos" -c:v libx264 -preset slow -profile:v high -level 4.2 -x264-params "keyint=$GOP:min-keyint=1:bitrate=5850:vbv-maxrate=12000:vbv-bufsize=18000" -pass 1 -passlogfile /home/tianyu/ffmpeg/ffmpeglog -an -f mp4 /dev/null
        $FFMPEG/ffmpeg -y -i $WD/$file -i $WD/../bilibiliwatermark.png  -filter_complex "overlay=0:0,format=yuv420p,scale=w=1920:h=1080:sws_flags=lanczos" -c:v libx264 -preset slow -profile:v high -level 4.2 -x264-params "keyint=$GOP:min-keyint=1:bitrate=5850:vbv-maxrate=12000:vbv-bufsize=18000" -pass 2 -passlogfile /home/tianyu/ffmpeg/ffmpeglog -c:a libfdk_aac -b:a 320k -ar 48000 $TMPFILE
        OUTNAME=$(awk -F. '{ print $1}' <<<"${file}")
        rm $WD/$file
        mv --backup=numbered $TMPFILE $OUTPUT/$OUTNAME.mp4
        chown -R tianyu:smb $OUTPUT
        chmod -R 0770 $OUTPUT
    done


