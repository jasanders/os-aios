#!/bin/sh
mkdir -p /tmp/nfs
echo -n "*" >> /tmp/ir
#echo "FC03FF00" > /sys/devices/platform/VenusIR/fakekey


read OUTPUT < "/usr/local/etc/iCap/aios_scaploc.dat"
if [ ! -d "$OUTPUT" ]; then
OUTPUT="/tmp/"
echo "$OUTPUT" > /usr/local/etc/iCap/aios_scaploc.dat
fi
OUTPUT="$OUTPUT""scrcap/"
mkdir -p "$OUTPUT"

TIMEOUT=100
while [ $TIMEOUT -gt 0 ]; do
    if [ "$(ls -A /tmp/nfs/*.bmp)" ]; then   
            mv /tmp/nfs/*.bmp "$OUTPUT"
            TIMEOUT=0
     else
          TIMEOUT=$((TIMEOUT - 1))
     fi
done

echo "FC03FF00" > /sys/devices/platform/VenusIR/fakekey

#sleep 1
#mv /tmp/nfs/ScrCap*.bmp /tmp/scrcap/
#echo "FC03FF00" > /sys/devices/platform/VenusIR/fakekey
