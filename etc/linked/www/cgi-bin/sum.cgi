#!/bin/sh
echo "Content-type: text/html"
echo
ST1=`echo $QUERY_STRING | cut '-d&' -f1`
ST2=`echo $QUERY_STRING | cut '-d&' -f2`
N1=`echo $ST1 | cut -d= -f2`
N2=`echo $ST2 | cut -d= -f2`
echo "<html><head><title>Shell Example #2</title></head>"
echo "<body>"
echo The sum of the two numbers is `expr $N1 + $N2`
echo "</body></html>"




