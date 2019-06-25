package ys.components.tip
{
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	
	/**
	 * TIP基类.
	 * @author 黄亦生
	 * @date 2012-8-23
	 */
	public class BaseTip extends Sprite implements ITip
	{
		public function BaseTip()
		{
			super();
			mouseEnabled = mouseChildren = false;
		}
		
		public function asDisplayObject():DisplayObject
		{
			return this;
		}
	}
}