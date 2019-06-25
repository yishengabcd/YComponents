/**
 * date:2011-7-17
 * author:yisheng
 */
package ys.components.controls
{
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Rectangle;
	import flash.utils.setTimeout;
	
	import org.bytearray.display.ScaleBitmap;
	
	import ys.components.core.InvalidationType;
	import ys.components.core.YComponent;
	
	public class YBitmap extends YComponent
	{
		private var _bitmap : Bitmap;
		private static var defaultStyles:Object = {
													bitmapData : null,
													scale9Grid:null
													};
		
		public static function getStyleDefinition():Object { 
			return YComponent.mergeStyles(YComponent.getStyleDefinition(), defaultStyles);
		}
		
		public function YBitmap()
		{
			super();
		}
		
		
		override protected function draw():void
		{
			if(isInvalid(InvalidationType.STYLES)){
				drawView()
				invalidate(InvalidationType.SIZE, false);
			}
			if(isInvalid(InvalidationType.SIZE)){
				drawLayout();
			}
			super.draw();
		}
		protected function drawView():void
		{
			bitmap = getDisplayObjectInstance(getStyleValue("bitmapData")) as Bitmap;
			var rect : Rectangle = getStyleValue("scale9Grid") as Rectangle;
			if(rect){
				bitmap.scale9Grid = rect;
			}
		}
		protected function drawLayout():void
		{
			if(!isNaN(width) && _bitmap){
				_bitmap.width = width;
			}
			else if(_bitmap)
			{
				width = _bitmap.width;
			}
			if(!isNaN(height) && _bitmap){
				_bitmap.height = height;
			}
			else if(_bitmap)
			{
				height = _bitmap.height;
			}
			
		}
		public function set bitmap(value : Bitmap):void
		{
			if(_bitmap == value || !value){
				return;
			}
			if(_bitmap && _bitmap.parent){
				_bitmap.parent.removeChild(_bitmap);
			}
			_bitmap = value;
			addChild(_bitmap);
		}
		public function get bitmap():Bitmap
		{
			return _bitmap;
		}
		
	}
}