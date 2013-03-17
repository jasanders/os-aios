#!/usr/local/bin/php
<? 
$command='wget '.$_GET['url'].' -O /tmp/tmp.zip';
exec($command,$output,$return_var);
if ($return_var) {print('ERR: DOWNLOAD FILE'); exit();}
$command='unzip -o /tmp/tmp.zip -d '.$_GET['dest'];
exec($command,$output,$return_var );
if ($return_var) {print('ERR: UNZIP FILE'); exit();}
$command='rm /tmp/tmp.zip';
exec($command,$output,$return_var );
if ($return_var) {print('ERR: REMOVE FILE'); exit();}
print('SUCCESS');
?>
