<?php

function test_actions()
{

}

function test_body()
{
	echo "<div id=\"container\">\n";
//	phpInfo();

echo "<pre>\n";

print_r( mb_get_info() );

//print_r( get_defined_functions() );
//$a = hash_algos();
//print_r( $a );

//global $nav_msg;
//global $nav_pages;
//global $nav_modules;
//global $nav_menu;


//echo "\nSERVER: ";print_r($_SERVER);
//echo "ENV: ";print_r($_ENV);

//echo "FILES: ";print_r ( $_FILES );
//echo "REQUEST: ";print_r ( $_REQUEST );
//echo "GET: ";print_r ( $_GET );

//echo "nav_msg: ";print_r ( $nav_msg );
//echo "nav_pages: ";print_r ( $nav_pages );
//echo "nav_modules: ";print_r ( $nav_modules );
//echo "nav_menu: ";print_r ( $nav_menu );
echo "</pre>\n";

	echo "</div>\n";

}
?>