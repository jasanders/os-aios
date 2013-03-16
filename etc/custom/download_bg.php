#!/usr/local/bin/php
<? 
$command='wget '.$_GET['url'].' -O /tmp/bg.zip';
exec($command,$output,$return_var);
if ($return_var) {print('ERR: DOWNLOAD FILE'); exit();}
$command='unzip -o /tmp/bg.zip -d /usr/local/bin/home_menu/image/';
exec($command,$output,$return_var );
if ($return_var) {print('ERR: UNZIP FILE'); exit();}
$command='rm /tmp/bg.zip';
exec($command,$output,$return_var );
if ($return_var) {print('ERR: REMOVE FILE'); exit();}
print('SUCCESS');
?>
