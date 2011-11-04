/**
 * XDItemSlider, Version 0.03.
 *
 * @author: Josh Ulm
 */

class XDItemSlider extends MovieClip
{
	// public
	public var cItemNum:Number = 1;
	
	// private
	private var cItem:MovieClip;
	private var oItem:MovieClip;
	
	// user defined
	[Inspectable(defaultValue="")]
	public var itemGroup:Array;
	[Inspectable(defaultValue="")]
	public var actionType:Array;
	[Inspectable(defaultValue="")]
	public var actionString:Array;
	[Inspectable(defaultValue=120)]
	public var focusPoint:Number;
	
	function XDItemSlider()
	{
		//
	}
	public function activate() {
		// show current item
		setCurrentItem(false);
	}
	public function deactivate() {
		// hide current item
		cItem.gotoAndStop(1);
	}
	public function kpUp() {
		//
	}
	public function kpDown() {
		//
	}
	public function kpLeft() {
		slideClip(cItemNum - 1);
	}
	public function kpRight() {
		slideClip(cItemNum + 1);
	}
	public function kpEnter() {
		_parent._parent.action(this)
	}
	public function setCurrentItem(Start:Boolean) {
		cItem = eval(itemGroup[cItemNum-1]);
		if(Start==true){
			cItem.gotoAndStop(2);
			cItem.swapDepths(this.getNextHighestDepth());
		}
	}
	public function slideClip(n:Number):Void {
		var len:Number = itemGroup.length;
		
		var s_y:Number = 0;
		var s_w:Number = 39.9;
		var s_h:Number = 50;
		var L_y:Number = 3;
		var L_w:Number = 94;
		var L_h:Number = 94;
			
		if (1 <= n && n <= len) {
			// hide old item
			oItem = cItem;
			oItem.gotoAndStop(1);

			// set current item
			cItemNum = n;
			setCurrentItem(false);
			// get new destination
			var d:Number = -cItem._x + focusPoint;
			
			var totald:Number = cItem._x - oItem._x;
			if(totald <= 0)
				totald = 65;
			//trace("s_w:"+s_w+",s_h:"+s_h+",L_w:"+L_w+",L_h:"+L_h+", d:"+d+",_x:"+cItem._x+", d-x:"+(d - cItem._x)+", t:"+totald);				
			
			// run tween
			this.onEnterFrame = function() {
				var cp:Number = _x;
				
				var pen:Number = ((totald - Math.abs(d - _x)) / totald * 100 );
				//trace("cp:"+cp+", d-_x:"+(d - _x)+", totald:"+totald);
				
				_x += Math.round((d - _x) * .5);
				
				cItem._y		= s_y + (L_y-s_y) * pen / 100;
				cItem._width	= s_w + (L_w-s_w) * pen / 100;
				cItem._height	= s_h + (L_h-s_h) * pen / 100;
				
				oItem._y 		= s_y + (L_y-s_y) * (100-pen) / 100;
				oItem._width	= s_w + (L_w-s_w) * (100-pen) / 100;
				oItem._height	= s_h + (L_h-s_h) * (100-pen) / 100;
				
				//trace("cy:"+cItem._y+",cw:"+cItem._width+",ch:"+cItem._height+",oy:"+oItem._y+",ow:"+oItem._width+",oh:"+oItem._height);
				if (_x == cp) {
					// tween complete
					_x = d;
					cItem._y = s_y;
					cItem._width = s_w;
					cItem._height = s_h;
					
					//oItem.gotoAndStop(1);
					oItem._y = s_y;
					oItem._width = s_w;
					oItem._height = s_h;
					
					cItem.gotoAndStop(2);
					cItem.swapDepths(this.getNextHighestDepth());
					delete this.onEnterFrame;
				}
			}
		}
	}
}