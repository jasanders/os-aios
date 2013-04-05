#!/usr/local/bin/php
<? 
print(substr( $_GET['file_path'],0,strrpos( $_GET['file_path'], '/',-2 ) ));
?>
