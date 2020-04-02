#!/bin/bash

#tail -n +11

TMP_VID=/home/tianyu/NAS/TempVideo
OUTPUT=$TMP_VID/output
BILI=$TMP_VID/output

mkdir -p $OUTPUT

VID=$TMP_VID/$(ls $TMP_VID | grep "\.mxf$" | tail -n +1)

echo "Process video -->"$VID 

#NOW=$date(

/home/tianyu/ffmpeg/bin/ffmpeg -y -i $VID -c:v libx264 -b:v 5850k -maxrate 23850k -bufsize 48M -preset slow -vf format=yuv420p -an -f mp4 /dev/null
/home/tianyu/ffmpeg/bin/ffmpeg -i $VID -c:v libx264 -b:v 5850k -maxrate 23850k -bufsize 48M -preset slow -vf format=yuv420p -c:a libfdk_aac -b:a 320k -ar 44100 $OUTPUT/$(date +"%Y-%m-%d_%H-%M-%S").mp4

#%Y-%m-%d_%H-%M-%S.mp4

#if [ $1 == "archive" ]; then
#    echo "archive"
#else
#    echo "not archive"
#fi

chown -R tianyu:smb $OUTPUT
chmod -R 0770 $OUTPUT
#rm $VID
