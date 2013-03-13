#!/bin/sh
SAVEIFS=$IFS
IFS=$(echo -en "\n\b")

mv /usr/local/etc/dvdplayer/mybg.png /usr/local/etc/dvdplayer/mybg._png
rm /usr/local/etc/dvdplayer/*.png
mv /usr/local/etc/dvdplayer/mybg._png /usr/local/etc/dvdplayer/mybg.png
#rm 'ls /usr/local/etc/dvdplayer/*.png | grep -v 'mybg.png''
#rm 'ls *.png | grep -v 'mybg.png''
rm /usr/local/etc/dvdplayer/*.gif
rm /usr/local/etc/dvdplayer/*.rss
rm /usr/local/etc/dvdplayer/*.jpg

IFS=$SAVEIFS
