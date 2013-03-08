#!/bin/sh
SAVEIFS=$IFS
IFS=$(echo -en "\n\b")

rm /usr/local/etc/dvdplayer/*.png
rm /usr/local/etc/dvdplayer/*.gif
rm /usr/local/etc/dvdplayer/*.rss
rm /usr/local/etc/dvdplayer/*.jpg

IFS=$SAVEIFS
