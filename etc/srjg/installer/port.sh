#!/bin/sh
# SRJG -> Port detection simple script
# Author: mikka [mika.hellmann@gmail.com]
# Note: Newer version of netstat (in Busybox) supports -p argument, which lists currently running and listening processes. This makes detection easier, but not compatible with older Busybox binaries. This script should be compatible with all Busybox versions.

# Mostly used httpd ports on Realtek devices are: 1024 and 80. Please add more if you know them.
if [ -n "`netstat -at | grep "1024"`" ];
then 
  PORT="1024"
elif [ -n "`netstat -at | grep "http"`" ];
then
  PORT="80" 
else 
  PORT="Not found"
fi

echo "$PORT"



