#!/usr/local/bin/php
<? 
$test_com = ('php -f /usr/local/etc/linked/www/cgi-bin/custom/standby_int.php -- '.$_GET['time'].' > /dev/null &');
#file_put_contents("/tmp/command.dat", $test_com);
exec($test_com);
?>
