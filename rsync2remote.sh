#!/bin/bash

SRC=$1

# remote dir
DST="root@127.0.0.1:/home/datadir"
NEWDIR="/home/datadir"

# create remote dir
ssh -o StrictHostKeyChecking=no root@127.0.0.1 "mkdir -p $NEWDIR"

# untar local file
echo "tar -zcf ${SRC}.tar.gz $SRC"
tar -zcf ${SRC}.tar.gz $SRC

# upload remote dir
echo "Upload ... ... ..."
i=0
while true; do
    rsync -rv -e ssh ${SRC}.tar.gz $DST
    fst=$?
    echo "Fist SCP: status="$fst
    if [ $fst -ne 0 ]; then
        let i=$i+1
        echo "Retry: "$i" times!"
        rsync -rv -e ssh ${SRC}.tar.gz $DST
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

echo "tar -zxf $NEWDIR/${SRC}.tar.gz"
ssh -o StrictHostKeyChecking=no root@127.0.0.1 "cd $NEWDIR && tar -zxf ${SRC}.tar.gz && rm -rf ${SRC}.tar.gz"

