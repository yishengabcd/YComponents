/**
 * date:2012-2-12
 * author:yisheng;
 */
package ys.components.controls
{
	import flash.display.DisplayObject;
	import flash.geom.Rectangle;
	
	import ys.components.core.InvalidationType;
	import ys.components.core.YComponent;
	
	public class YMultiFrameImage extends YComponent
	{
		/**
		 * 成员为显示对象. 
		 */		
		private var _images : Array;
		private var _currentImage : DisplayObject;
		private var _currentIndex : int;
		
		public function YMultiFrameImage()
		{
			_images = new Array();
			super();
		}
		/**
		 * images 为数组对象,成员可以是链接名或显示对象. 
		 */		
		private static var defaultStyles:Object = {
			images : null,
			scale9Grid:null
		};
		
		public static function getStyleDefinition():Object { 
			return defaultStyles;
		}
		
		
		public function setFrame(index : int):void
		{
			if(_currentIndex != index){
				_currentIndex = index;
				invalidate(InvalidationType.STATE);
			}
		}
		override protected function draw():void
		{
			if(isInvalid(InvalidationType.STYLES)){
				drawView()
				invalidate(InvalidationType.SIZE, false);
				invalidate(InvalidationType.STATE, false);
			}
			if(isInvalid(InvalidationType.STATE)){
				drawState();
				invalidate(InvalidationType.SIZE, false);
			}
			if(isInvalid(InvalidationType.SIZE)){
				drawLayout();
			}
			super.draw();
		}
		protected function drawView():void
		{
			var arr : Array = getStyleValue("images") as Array;
			var member : DisplayObject;
			var rect : Rectangle = getStyleValue("scale9Grid") as Rectangle;
			for(var i : int = 0; i < arr.length; i++){
				member = getDisplayObjectInstance(arr[i]);
				_images.push(member);
				if(rect){
					member.scale9Grid = rect;
				}
			}
		}
		private function drawState():void
		{
			var oldImg : DisplayObject = _currentImage;
			if(oldImg && oldImg.parent){
				oldImg.parent.removeChild(oldImg);
			}
			_currentImage = _images[_currentIndex];
			addChild(_currentImage);
			if(!oldImg){
				if(isNaN(width)){
					width = _currentImage.width;
				}
				if(isNaN(height)){
					height = _currentImage.height;
				}
			}
		}
		protected function drawLayout():void
		{
			if(!isNaN(width) && _currentImage){
				_currentImage.width = width;
			};
			if(!isNaN(height) && _currentImage){
				_currentImage.height = height;
			};
			
		}
	}
}