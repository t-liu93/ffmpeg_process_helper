#!/bin/bash

OUTPUT=$1

if [ -z "$OUTPUT" ]; then
    "No output dir specified!"
    exit 1
fi

mkdir -p $OUTPUT

#Extract video as mp4 using ffmpeg copy
find . -name '*.mkv' -exec /home/tianyu/ffmpeg/bin/ffmpeg -i {} -c:v copy -an $OUTPUT/{}.mp4 \;

#Extract audio as wav using mkvextract
find . -name '*.mkv' -exec mkvextract {} tracks 1:$OUTPUT/{}_bg.wav \;
find . -name '*.mkv' -exec mkvextract {} tracks 2:$OUTPUT/{}_na.wav \;

chown -R tianyu:smb $OUTPUT
chmod -R 0770 $OUTPUT

find . -name '*.mkv' -exec rm {} \;
