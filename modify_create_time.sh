#!/bin/bash

IN=$1
OUT=$2
CREATE_TIME=$3 # create time in format of yyyy-mm-dd hh:mm:ss in one string"

if [ -z "$IN" ]; then
    echo "No input file specified!"
    exit 1
fi

if [ -z "$OUT" ]; then
    echo "No output file specified!"
    exit 1
fi

if [ -z "$CREATE_TIME" ]; then
    echo "No create time specified!"
    exit 1
fi
OUTPATH=${OUT%/*}

# echo $IN
# echo $OUT
# echo $CREATE_TIME
BASENAME=$(basename $IN)
EXT=${BASENAME##*.}
TEMPOUT=$OUTPATH/out.$EXT
/home/tianyu/ffmpeg/bin/ffmpeg -y -i $IN -c:v copy -c:a copy -c:s copy -metadata creation_time="$CREATE_TIME" $TEMPOUT

mv $TEMPOUT $OUT
chown -R tianyu:smb $OUT
chmod -R 0770 $OUT