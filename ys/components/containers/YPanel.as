/**
 * date:2011-6-16
 * author:yisheng
 **/
package ys.components.containers
{
	import flash.display.DisplayObject;
	import flash.geom.Rectangle;
	
	import ys.components.core.InvalidationType;
	import ys.components.core.YComponent;
	
	public class YPanel extends YComponent
	{
		protected var background:DisplayObject;
		private var _backgroundStyle : Object;
		
		public function YPanel()
		{
			super();
		}
		
		private static var defaultStyles:Object = {background:null, 
													scale9Grid : null};
		
		public static function getStyleDefinition():Object { 
			return defaultStyles;
		}
		override protected function draw():void {
			
			if (isInvalid(InvalidationType.STYLES)) {
				drawView();
			}

			if (isInvalid(InvalidationType.SIZE)) {
				drawLayout();
			}
			super.draw();
		}
		
		protected function drawView():void
		{
			drawBackground();
		}
		
		protected function drawBackground():void {
			var bgStyle : Object = getStyleValue("background")
			if(!bgStyle || bgStyle == _backgroundStyle){
				return;
			}
			var bg : DisplayObject = background
			if (bg != null) { removeChild(bg); }
			_backgroundStyle = getStyleValue("background");
			background = getDisplayObjectInstance(_backgroundStyle);
			addChildAt(background, 0);
			
			if(!bg){
				if(isNaN(width)){
					width = background.width;
				}
				if(isNaN(height)){
					height = background.height;
				}
			}
			
			var scale9Grid : Rectangle = getStyleValue("scale9Grid") as Rectangle
			if(scale9Grid){
				background.scale9Grid = scale9Grid;
			}
			
			invalidate(InvalidationType.SIZE,false); // invalidates size without calling draw next frame.
		}
		protected function drawLayout():void {
			if(background){
				background.width = width;
				background.height = height;
			}
			
		}
	}
}