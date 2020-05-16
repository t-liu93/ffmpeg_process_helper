#!/bin/bash

OUT=$1

if [ -z "$OUT" ]; then
    echo "No output dir specified!"
    exit 1
fi
OUTPUT="$OUT"/录制
mkdir -p $OUTPUT

for file in $PWD/*.mkv; do
    filename=${file##*/}
    filename_noext=${filename%.*}

    # Extract video as mp4 using ffmpeg copy
    /home/tianyu/ffmpeg/bin/ffmpeg -i $PWD/$filename -c:v copy -an $OUTPUT/"$filename_noext"_0vid.mp4

    # Extract audio as wav using mkvextract
    # track 1, a.k.a. audio track 0 is background sound
    mkvextract $PWD/$filename tracks 1:$OUTPUT/"$filename_noext"_1bg.wav
    # track 2, a.k.a. audio track 1 is narrator track
    mkvextract $PWD/$filename tracks 2:$OUTPUT/"$filename_noext"_2nr.wav

    rm $file
done

chown -R tianyu:smb $OUT
chmod -R 0770 $OUT
