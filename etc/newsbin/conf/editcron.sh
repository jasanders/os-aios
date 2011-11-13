#!/bin/sh

CRONTXT=/opt/etc/crontab.txt

# start with existing crontab
# /opt/etc/crontab -l > $CRONTXT

/bin/echo "*/30 * * * * /opt/bin/php /usr/local/etc/newsbin/web/nzbgetter/__exec__/run.php" >> $CRONTXT

# install the new crontab
/opt/etc/crontab $CRONTXT

# clean up
/bin/rm $CRONTXT
