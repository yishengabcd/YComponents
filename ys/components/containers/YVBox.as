/**
 * date:2012-1-5
 * author:yisheng
 **/
package ys.components.containers
{
	import flash.display.DisplayObject;

	/**
	 * 按垂直方向排列组件的容器类.
	 **/
	public class YVBox extends YBaseBox
	{
		public function YVBox()
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
				child.y = offset;
				offset += child.height;
				offset += gap;
				tempH += child.height;
				tempW = Math.max(tempW, child.width);
			}
			tempH += gap * (numChildren - 1);
			setSize(tempW, tempH);
			
			super.drawLayout();
		}
	}
}