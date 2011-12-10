#!/bin/sh
for i in /opt/etc/init.d/K??* ;do
	$i &
done
