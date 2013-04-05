#!/usr/local/bin/php
<? 
print(substr( $_GET['date_time'],strrpos( $_GET['date_time'], ' ' )+1 ));
?>
