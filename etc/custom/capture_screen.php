#!/usr/local/bin/php
<? 
$command='/usr/local/etc/iCap/screencap.sh';
exec($command,$output,$return_var);
if ($return_var) {print('ERR: SCREEN CAPTURE'); exit();}
if($_GET['fetch']!='y')
{
print('SUCCESS. Screen saved under: '.file_get_contents('/usr/local/etc/iCap/aios_scaploc.dat')."scrcap/");
}
else{
$command="ls ".file_get_contents("/usr/local/etc/iCap/aios_scaploc.dat")."scrcap/*.bmp -t1 | head -n1"; 
exec($command,$output,$return_var);  
#print($output[0]);
$im = file_get_contents($output[0]); 
header('content-type: image/bmp'); 
echo $im; 
if($_GET['save']!='y') exec("rm ".$output[0]);
}
?>
