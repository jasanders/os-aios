#!/bin/sh
for i in /usr/local/etc/share_favs/f??* ;do
	$i &
done
