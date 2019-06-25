package ys.components.tip
{
	import flash.display.DisplayObject;
	import flash.display.IDisplayObject;
	import flash.geom.Point;

	/**
	 * 可以产生TIP的对象的接口.
	 * 实现该接口的类的对象可以通过TipManager来进行显示TIP.
	 * @author 黄亦生
	 * @date 2012-8-23
	 */
	public interface ITipTarget extends IDisplayObject
	{
		/**
		 * 获得要显示的TIP的视图对象 
		 * @return 
		 * 
		 */		
		function getTip():ITip;
		/**
		 * 设置TIP生成器(函数)
		 * 通过该方法,可以对需要显示TIP的对象动态生成TIP,从而避免继承方式改为 getTip()方法
		 * @param factory 该方法需要返回ITip实例
		 * 
		 */		
		function setTipFactory(factory : Function):void;
		
		/**
		 * 偏移坐标 
		 * @return 
		 * 
		 */		
		function getTipOffsetPos():Point;
		function setTipOffsetPos(pt : Point):void;
	}
}