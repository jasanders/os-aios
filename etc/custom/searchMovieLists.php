#!/usr/local/bin/php
<? $my_array = file("/tmp/cached/movieName.dat"); 
$search_term = $_GET['term'];

function search_array ( array $array, $term )
{
    foreach ( $array as $key => $value )
        if ( stripos( $value, $term ) !== false )
            return $key;

    return false;
}  

print(search_array($my_array, $search_term));
?>
