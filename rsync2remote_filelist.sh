#!/bin/bash

SRC=$1

DST="root@127.0.0.1:/home/datadir"
NEWDIR="/home/datadir"

ssh -o StrictHostKeyChecking=no root@127.0.0.1 "mkdir -p $NEWDIR"

echo "Upload ... ... ..."
i=0
while true; do
    rsync -Pav --delete --size-only -e ssh ${SRC} $DST
    fst=$?
    echo "Fist SCP: status="$fst
    if [ $fst -ne 0 ]; then
        let i=$i+1
        echo "Retry: "$i" times!"
        rsync -Pav --delete --size-only -e ssh ${SRC} $DST
        snd=$?
        echo "Second SCP: status="$snd
        if [ $snd -eq 0 ]; then
            echo "Upload successful"
            break
        fi

        if [ $i -ge 20 ]; then
            echo "Upload failed"
            exit 1
        fi
    fi

    if [ $fst -eq 0 ]; then
       echo "Upload successful"
       break
    fi
done

