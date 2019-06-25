/**
 * date:2012-1-5
 * author:yisheng
 **/
package ys.components.containers
{
	import flash.display.DisplayObject;
	
	/**
	 * 按水平方向排列组件的容器类.
	 **/
	public class YHBox extends YBaseBox
	{
		public function YHBox()
		{
			super();
		}
		override protected function drawLayout():void
		{
			var tempW : Number = 0;
			var tempH : Number = 0;
			var offset:Number = 0;
			for(var i:int = 0; i < numChildren; i++)
			{
				var child:DisplayObject = getChildAt(i);
				child.x = offset;
				offset += child.width;
				offset += gap;
				tempW += child.width;
				tempH = Math.max(tempH, child.height);
			}
			tempW += gap * (numChildren - 1);
			setSize(tempW, tempH);
			
			super.drawLayout();
		}
	}
}