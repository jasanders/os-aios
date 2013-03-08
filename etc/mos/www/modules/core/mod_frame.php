<?php
function frame_session()
{
global $nav_modules;
global $nav_title;

	if ( isset( $_GET['mod'] ) )
	{
		$mod = $_GET['mod'];
		$nav_title = $nav_modules[ $mod ]['navy_title'];
	}
}

function frame_body()
{
global $nav_modules;

	if ( isset( $_GET['mod'] ) )
	{
		$mod = $_GET['mod'];
		if( isset( $nav_modules[$mod]['navy_frame'] ))
		{
			$src = $nav_modules[$mod]['navy_frame'];
			$src = str_replace("%addr%", $_SERVER["SERVER_ADDR"], $src);
			$src = str_replace("%cgi%", 'http://'.$_SERVER["SERVER_HOST"].'/cgi-bin/', $src);

?>
<iframe class="cont_frame" src="<?php echo $src; ?>" width="100%" height="100%" scrolling="auto" frameborder="0">
</iframe>
<?php
		}
	}
}

?>