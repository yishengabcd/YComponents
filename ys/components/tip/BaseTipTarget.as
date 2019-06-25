package ys.components.tip
{
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.geom.Point;
	
	/**
	 * TIP作用目标基类
	 * @author 黄亦生
	 * @date 2012-8-23
	 */
	public class BaseTipTarget extends Sprite implements ITipTarget
	{
		protected var _tipFactory : Function;
		protected var _tipPosOffset : Point = new Point();
		public function BaseTipTarget()
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