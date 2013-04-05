#!/bin/sh
#
# IMS by DMD skript pro cas
# Autor: derby00
# $1 - name of parameter
#
export TZ='CET-1CEST,M3.5.0/2,M10.5.0/3'
getParam () {
  echo $( echo $QUERY_STRING | sed -n "s/^.*$1=\([^&]*\).*$/\1/p" )
}
#
#===============================================
#
# Doing non-html jobs
#
doit=$( getParam do )

if [ ! -z "$doit" ] ; then
# ----------------------------------------------
  if [ "$doit" == "getstatus" ] ; then
#
# GetStatus
#
SendStatus
exit 0
# ----------------------------------------------
  elif [ "$doit" == "settim" ] ; then
#
# set time
#
hod=$( getParam hodina )
min=$( getParam minuta )
NOW=$(date +"%k")
if [ "$NOW" != "$hod" ] ; then
date -s $hod:$min
fi
echo $NOW

exit 0
# ----------------------------------------------
  elif [ "$doit" == "gettim" ] ; then
#
# Get time
#
NOWH=$(date +"%k")
NOWM=$(date +"%M")
echo "Content-type: text/xml

<?xml version=\"1.0\" encoding=\"UTF-8\" ?>
<lang>$NOWH:$NOWM</lang>"
exit 0
# ----------------------------------------------
  fi

fi
