#!/usr/local/bin/php
<? 
# <-1: reboot, -1: cancel, 0:shutdown now, n: shutodwn after n minutes 
#file_put_contents("/tmp/param.dat", $argv[1]);
$sleep_time = intval($argv[1]);
if ($sleep_time < -1)
{
exec('reboot');
}
if ($sleep_time < 0)
{
file_put_contents("/tmp/standby.dat", '0');
exit;
}
if ($sleep_time > 0)
{
$current_time=time();
file_put_contents("/tmp/standby.dat", $current_time);
sleep($sleep_time*60);
if (intval(file_get_contents("/tmp/standby.dat"))!=$current_time) exit;
}
exec('echo "FD02FF00" > /sys/devices/platform/VenusIR/fakekey');
exit;
?>
