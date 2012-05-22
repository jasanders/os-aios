#!/bin/sh
SAVEIFS=$IFS
IFS=$(echo -en "\n\b")

if [ -e /usr/local/etc/linked/samba/wrkgrp.new ]
then
	wrkgrp_old='workgroup='`cat /usr/local/etc/linked/samba/wrkgrp.old`
	#echo $wrkgrp_old
	wrkgrp_new='workgroup='`cat /usr/local/etc/linked/samba/wrkgrp.new`
	#echo $wrkgrp_new
	sed -i "s/$wrkgrp_old/$wrkgrp_new/g" /usr/local/etc/linked/samba/conf/smb_anonymous_head.conf
	sed -i "s/$wrkgrp_old/$wrkgrp_new/g" /usr/local/etc/linked/samba/conf/smb_user_head.conf
	rm /usr/local/etc/linked/samba/wrkgrp.old
	mv /usr/local/etc/linked/samba/wrkgrp.new /usr/local/etc/linked/samba/wrkgrp.old
fi

IFS=$SAVEIFS
