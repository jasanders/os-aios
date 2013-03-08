#!/usr/local/bin/php
<? $parts=file("/tmp/cached/movieDir.dat"); 
natcasesort($parts);
file_put_contents("/tmp/cached/movieDir.dat", $parts);
$parts=file("/tmp/cached/movieName.dat"); 
natcasesort($parts);
file_put_contents("/tmp/cached/movieName.dat", $parts);
?>
