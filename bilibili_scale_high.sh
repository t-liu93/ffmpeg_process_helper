#!/bin/bash

FFMPEG=/home/tianyu/ffmpeg/bin
TMP=/home/tianyu/NAS/TempVideo
WD=$TMP/toBilibiliHigh
OUTPUT=$TMP/output
OUTFILE=$(date +"%Y-%m-%d_%H-%M-%S").mp4
TMPFILE=/home/tianyu/$OUTFILE

mkdir -p $OUTPUT

inotifywait -m $WD -e create -e close_write -e moved_to -e modify |
    while read dir action file; do
        $FFMPEG/ffmpeg -y -i $WD/$file -i $WD/../bilibiliwatermark.png  -filter_complex "overlay=0:0,format=yuv420p,scale=w=1920:h=1080:sws_flags=sinc" -c:v libx264 -preset slow -x264-params "bitrate=24000" -profile:v high -x264opts colorprim=bt709:transfer=bt709:colormatrix=bt709 -pass 1 -passlogfile /home/tianyu/ffmpeg/ffmpeglog -an -f mp4 /dev/null
        $FFMPEG/ffmpeg -y -i $WD/$file -i $WD/../bilibiliwatermark.png  -filter_complex "overlay=0:0,format=yuv420p,scale=w=1920:h=1080:sws_flags=sinc" -c:v libx264 -preset slow -x264-params "bitrate=24000" -profile:v high -x264opts colorprim=bt709:transfer=bt709:colormatrix=bt709 -pass 2 -passlogfile /home/tianyu/ffmpeg/ffmpeglog -c:a libfdk_aac -b:a 320k -ar 48000 $TMPFILE
        OUTNAME=${file%.*}
        rm $WD/$file
        mv --backup=numbered $TMPFILE $OUTPUT/"$OUTNAME".mp4
        chown -R tianyu:smb $OUTPUT
        chmod -R 0770 $OUTPUT
    done


