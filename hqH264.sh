#!/bin/bash

FFMPEG=/home/tianyu/ffmpeg/bin
TMP=/mnt/NAS/TempVideo
WD=$TMP/hqH264
OUTPUT=$TMP/output
OUTFILE=$(date +"%Y-%m-%d_%H-%M-%S").mov
TMPFILE=/home/tianyu/$OUTFILE

mkdir -p $OUTPUT

inotifywait -m $WD -e create -e close_write -e moved_to -e modify |
    while read dir action file; do
        FR=$($FFMPEG/ffprobe -v 0 -of csv=p=0 -select_streams v:0 -show_entries stream=r_frame_rate $WD/$file)
        HIGH=$(awk -F/ '{ print $1}' <<<"${FR}")
        LOW=$(awk -F/ '{ print $2}' <<<"${FR}")
        FPS=$(expr $HIGH / $LOW)
        MAXRATE=35000
        if [ "$FPS" -gt 31]; then
            MAXRATE=65000
        else
            MAXRATE=35000
        fi
        $FFMPEG/ffmpeg -y -i $WD/$file -c:v libx264 -preset slow -crf 14 -maxrate "$MAXRATE"k -bufsize "$MAXRATE"k -profile:v high -pix_fmt yuv420p -x264opts colorprim=bt709:transfer=bt709:colormatrix=bt709:keyint=30:min-keyint=15 -c:a libfdk_aac -b:a 576k -cutoff 18000 $TMPFILE
        OUTNAME=${file%.*}
        rm $WD/$file
        mv --backup=numbered $TMPFILE $OUTPUT/"$OUTNAME"_x264.mov
        chown -R tianyu:smb $OUTPUT
        chmod -R 0770 $OUTPUT
    done


