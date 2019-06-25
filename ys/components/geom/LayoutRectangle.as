/**
 * date:2011-7-17
 * author:yisheng
 */
package ys.components.geom
{
	import flash.geom.Rectangle;

	public class LayoutRectangle
	{
		private var _x : int;
		private var _y : int;
		private var _width : int;
		private var _height : int;
		private var _type : int;
		
		public function LayoutRectangle(x : int, y : int, 
										width : int, height : int, 
										type : int)
		{
			_x = x;
			_y = y;
			_width = width;
			_height = height;
			_type = type;
		}
		public function getLayoutRect(containerW : int, containerH : int):Rectangle
		{
			return new Rectangle(_x, _y, _width, _height);
		}
	}
}