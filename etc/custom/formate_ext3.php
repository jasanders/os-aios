#!/usr/local/bin/php
<? 
#file_put_contents("/tmp/dev.dat", 'mkfs.ext3 /dev/'.$_GET['dev']);
#file_put_contents("/tmp/mloc.dat", 'umount /tmp/usbmounts/'.$_GET['dev'].' -l');
exec('umount /tmp/usbmounts/'.$_GET['dev'].' -l');
exec('mkfs.ext3 /dev/'.$_GET['dev']);
?>
