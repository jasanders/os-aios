<?php

function reboot_actions( $act, $log )
{
	if( $act == 'reboot' )
	{
		if( $log )
		{
?>
<script type="text/javascript">
	window.location.href='/';
</script>
<?php
		}
		doCommand( 'reboot', $log );
	}
}

// ------------------------------------
//
function reboot_body()
{

?>
<script type="text/javascript">
	isConfirmed = confirm('<?= getMsg( 'moreReboot' ) ?>');
	if(isConfirmed)
	{
		window.location.href = '?page=reboot&act=reboot';
	}
	else
	{
		window.location.href='/';
	}
</script>
<?php

}

?>