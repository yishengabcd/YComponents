package ys.components.tip
{
	import flash.display.DisplayObject;
	import flash.geom.Point;
	import flash.text.TextField;
	
	/**
	 * 支持TIP的文本目标对象
	 * @author 黄亦生
	 * @date 2012-8-24
	 */
	public class TextTipTarget extends TextField implements ITipTarget
	{
		protected var _tipFactory : Function;
		protected var _tipPosOffset : Point = new Point();
		public function TextTipTarget()
		{
			super();
		}
		
		public function asDisplayObject():DisplayObject
		{
			return this;
		}
		public function getTip():ITip
		{
			if(_tipFactory != null)
			{
				return _tipFactory();
			}
			return null;
		}
		public function setTipFactory(factory : Function):void
		{
			_tipFactory = factory
		}
		public function getTipOffsetPos():Point
		{
			return _tipPosOffset;
		}
		public function setTipOffsetPos(pt : Point):void
		{
			_tipPosOffset = pt;
		}
	}
}