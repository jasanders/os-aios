<?php

class rssSkinInfoListView extends rssSkinList
{
	const itemAreaX		= 820;
	const itemAreaY		= 108;
	const itemAreaWidth	= 480;
	const itemAreaHeight	= 620;

	const itemWidth		= 480;
	const itemHeight	= 80;

	const itemImageX	= 5;
	const itemImageY	= 5;
	const itemImageWidth	= 95;
	const itemImageHeight	= 70;

	const itemTextX		= 105;
	const itemTextY		= 5;
	const itemTextWidth	= 395;
	const itemTextHeight	= 70;

//	const itemTextBackgroundColor = '140:140:140';
	//
	// ------------------------------------
	public $infos = array();
	//
	// ------------------------------------
	function showMoreDisplay()
	{
		foreach( $this->infos as $info )
		{
			$px = round( $info['posX'] / static::viewAreaWidth * 100, 4);
			$py = round( $info['posY'] / static::viewAreaHeight * 100, 4);
			$pw = round( $info['width']  / static::viewAreaWidth  * 100, 4);
			$ph = round( $info['height'] / static::viewAreaHeight * 100, 4);

			if( $info['type'] == 'image' )
			{

?>
    <image offsetXPC="<?= $px ?>" offsetYPC="<?= $py ?>" widthPC="<?= $pw ?>" heightPC="<?= $ph ?>" >
      <?= $info['image'] ?> 
    </image>
<?php
			}
			else
			{
				$pa = isset( $info['align'] ) ? $info['align'] : static::itemTextAlign;
				$pl = isset( $info['lines'] ) ? $info['lines'] : static::itemTextLines;
				$ps = isset( $info['fontSize'] ) ? $info['fontSize'] : static::itemTextFontSize;
				$pb = isset( $info['bgColor'] ) ? $info['bgColor'] : static::itemBackgroundColor;
				$pf = isset( $info['fgColor'] ) ? $info['fgColor'] : static::unFocusFontColor;

?>
    <text align="<?= $pa ?>"<?php

				if( $pl > 0 ) echo " lines=\"$pl\"";

?> offsetXPC="<?= $px ?>" offsetYPC="<?= $py ?>" widthPC="<?= $pw ?>" heightPC="<?= $ph ?>"
     fontSize="<?= $ps ?>" backgroundColor="<?= $pb ?>" foregroundColor="<?= $pf ?>">
      <?= $info['text'] ?> 
    </text>
<?php
			}
		}
	}
	//
	// ------------------------------------
	function showOnUserInput()
	{
?>
    <onUserInput>
	ret = "false";
	userInput = currentUserInput();

	if (userInput == "<?= getRssCommand('enter') ?>")
	{
		idx = getFocusItemIndex();
		url = getItemInfo( idx, "link" );
		act = getItemInfo( idx, "action" );
		if( act == "get" )
		{
			showIdle();
			url = getUrl(url);
			if(( url != null )&amp;&amp;( url != "" ))
			{
				playItemURL(url, 0);
			}
			cancelIdle();
		}
		else if( act == "rss" )
		{
			url = doModalRss(url);
		}
		else
		{
			showIdle();
			playItemURL(url, 0);
			cancelIdle();
		}
		ret = "true";
	}
	else
	if (userInput == "<?= getRssCommand('left') ?>" || userInput == "<?= getRssCommand('right') ?>")
	{
		ret = "true";
	}
	ret;
    </onUserInput>
<?php
	}
	//
	// ------------------------------------
	function showDisplay()
	{

		$sw = static::screenWidth;
		$sh = static::screenHeight;

		$kw = static::skinWidth;
		$kh = static::skinHeight;

		$sx = ($sw - $kw)/2;
		$sy = ($sh - $kh)/2;

		$vx = static::viewAreaX;
		$vy = static::viewAreaY;
		$vw = static::viewAreaWidth;
		$vh = static::viewAreaHeight;


		$ax = static::itemAreaX;
		$ay = static::itemAreaY;
		$aw = static::itemAreaWidth;
		$ah = static::itemAreaHeight;

		$iw = static::itemWidth;
		$ih = static::itemHeight;

		$nr = floor( $ah / $ih );

?>
  <mediaDisplay name="threePartsView"
   viewAreaXPC="<?= round(( $sx + $vx )/$sw*100, 4) ?>"
   viewAreaYPC="<?= round(( $sy + $vy )/$sh*100, 4) ?>"
   viewAreaWidthPC="<?= round(( $vw )/$sw*100, 4) ?>"
   viewAreaHeightPC="<?= round(( $vh )/$sh*100, 4) ?>"

   backgroundColor="<?= static::backgroundColor ?>"

   sideLeftWidthPC="0"
   sideRightWidthPC="0"
   sideColorLeft="<?= static::sideColorLeft ?>"
   sideColorRight="<?= static::sideColorRight ?>"

   showHeader="no"
   showDefaultInfo="no"

   forceFocusOnItem="yes"

   itemPerPage="<?= $nr ?>"

   itemImageHeightPC="0"
   itemImageWidthPC="0"
   itemImageXPC="<?= round($ax/$sw*100, 4) ?>"
   itemImageYPC="<?= round($ay/$sh*100, 4) ?>"

   itemXPC="<?= round($ax/$sw*100, 4) ?>"
   itemYPC="<?= round($ay/$sh*100, 4) ?>"
   itemWidthPC="<?= round($iw/$vw*100, 4) ?>"
   itemHeightPC="<?= round($ih/$vh*100, 4) ?>"
   itemBackgroundColor="<?= static::itemBackgroundColor ?>"

   itemGap="0"

   focusBorderColor = "<?= static::focusBorderColor ?>"
   unFocusBorderColor = "<?= static::unFocusBorderColor ?>"

   imageFocus=""
   imageParentFocus=""
   imageUnFocus=""

   idleImageXPC="<?= round( static::idleImageX/$vw*100, 4) ?>"
   idleImageYPC="<?= round( static::idleImageY/$vh*100, 4) ?>"
   idleImageWidthPC="<?= round( static::idleImageWidth/$vw*100, 4) ?>"
   idleImageHeightPC="<?= round( static::idleImageHeight/$vh*100, 4) ?>"
  >
<?php
		$this->showIdleBg();
		$this->showTop();
		$this->showBottom();

		$this->showMoreDisplay();
		$this->showItemDisplay();
		$this->showOnUserInput();

?>
  </mediaDisplay>
<?php
	}
}

?>
