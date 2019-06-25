/**
 * date:2011-7-17
 * author:yisheng
 */
package ys.components.geom
{
	public class LayoutRectangleType
	{
		/**
		 * x: 左边间距(x坐标)
		 * y: 顶部间距(y坐标)
		 * width: 宽度
		 * height: 高度
		 */		
		public static const NORMAL:int = 0;
		/**
		 * x: 左边间距(x坐标)
		 * y: 顶部间距(y坐标)
		 * width: 右边间距
		 * height: 高度
		 */	
		public static const RIGHT:int = 1;
		/**
		 * x: 左边间距(x坐标)
		 * y: 顶部间距(y坐标)
		 * width: 右边间距
		 * height: 底部间距
		 */	
		public static const RIGHT_BOTTOM:int = 2;
		
		
		/**
		 * x: 水平居中后的偏移值
		 * y: 顶部间距(y坐标)
		 * width: 宽度
		 * height: 高度
		 */	
		public static const CENTER_H:int = 10;
		/**
		 * x: 左边间距(x坐标)
		 * y: 垂直居中后的偏移值
		 * width: 宽度
		 * height: 高度
		 */	
		public static const CENTER_V:int = 11;
		/**
		 * x: 水平居中后的偏移值
		 * y: 垂直居中后的偏移值
		 * width: 宽度
		 * height: 高度
		 */	
		public static const CENTER_HV:int = 12;
		
	}
}