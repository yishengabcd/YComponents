/**
 * date:2011-6-14
 * author:yisheng
 */
package ys.components.core
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	import ys.components.containers.YPanel;
	import ys.components.controls.YBaseButton;
	import ys.components.controls.YButton;
	import ys.components.events.CloseEvent;
	
	[Event(name="close", type="ys.components.events.CloseEvent")]
	[Style(name="closeButton", type="Class")]
	[Style(name="closeButtonTop", type="Class")]
	[Style(name="closeButtonRight", type="Class")]

	public class YWindow extends YPanel
	{
		
		private var _dragSprite : Sprite;
		protected var _draggable:Boolean = true;
		private var _dragRect : Rectangle;
		
		protected var _closeButton : YBaseButton;
		
		private var _titleTxt : TextField;
		private var _title : String;
		
		private var _titleCenterFlag : Boolean;
		private var _titlePosX : Number;
		private var _titlePosY : Number;
		
		public function YWindow(title : String = "")
		{
			_title = title;
			super();
		}
		
		private static var defaultStyles:Object = 
		{
			closeButton : null, 
			titleTextFormat : null,
			titleFilters : null,
			titleCenter : true,
			titlePosX : 3, 
			titlePosY : 3
		};
		
		public static function getStyleDefinition():Object { 
			return mergeStyles(YPanel.getStyleDefinition(), defaultStyles);
		}
		
		override protected function configUI():void
		{
			super.configUI();
			_dragSprite = new Sprite();
			_dragSprite.addEventListener(MouseEvent.MOUSE_DOWN, onDragSpriteMouseDown, false, 0, true);
			addChild(_dragSprite);
		}
		

		private function onDragSpriteMouseDown(event:MouseEvent):void
		{
			if(_draggable)
			{
				startDrag();
				stage.addEventListener(MouseEvent.MOUSE_UP, onStageMouseUp, false, 0, true);
			}
		}

		private function onStageMouseUp(event:MouseEvent):void
		{
			stopDrag();
			stage.removeEventListener(MouseEvent.MOUSE_UP, onStageMouseUp);
		}
		
		override protected function drawView():void
		{
			super.drawView();
			drawTitle();
			drawCloseButton();
		}
		private function drawTitle():void
		{
			if(!_title || _title == ""){
				return;
			}
			_titleTxt = new TextField();
			_titleTxt.mouseEnabled = _titleTxt.mouseWheelEnabled = false;
			
			var tf : TextFormat = getStyleValue("titleTextFormat") as TextFormat;
			if(tf){
				_titleTxt.defaultTextFormat = tf;
			}
			_titleTxt.text = _title;
			_titleTxt.filters = getStyleValue("titleFilters") as Array;
			
			_titleCenterFlag = getStyleValue("titleCenter") as Boolean;
			_titlePosX = Number(getStyleValue("titlePosX"));
			_titlePosY = Number(getStyleValue("titlePosY"));
			
			setTitlePosition();
			
			addChild(_titleTxt);
		}
		private function drawCloseButton():void
		{
			if(_closeButton){
				_closeButton.removeEventListener(MouseEvent.CLICK, onCloseBtnClick);
				removeChild(_closeButton);
			}
			_closeButton = getDisplayObjectInstance(getStyleValue("closeButton")) as YBaseButton;
			if(_closeButton){
				_closeButton.drawNow();
				
				_closeButton.addEventListener(MouseEvent.CLICK, onCloseBtnClick, false, 0, true);
				
				addChild(_closeButton);
			}
		}
		override protected function drawLayout():void
		{
			super.drawLayout();
			if(_dragRect == null){
				_dragRect = new Rectangle(0,0,width, 20);
			}
			_dragRect.width = width;
			_dragSprite.graphics.clear();
			_dragSprite.graphics.beginFill(0x0,0);
			_dragSprite.graphics.drawRect(_dragRect.x, _dragRect.y, _dragRect.width, _dragRect.height);
			_dragSprite.graphics.endFill();
			
			if(_closeButton){
				_closeButton.x = width - _closeButton.width - 5;
				_closeButton.y = 5;
			}
		}
		private function setTitlePosition():void
		{
			var txtW:Number = _titleTxt.textWidth+4;
			var txtH:Number = _titleTxt.textHeight+4;
			
			_titleTxt.width = txtW;
			_titleTxt.height = txtH;
			
			if(_titleCenterFlag){
				_titleTxt.x = Math.round((width-txtW)/2);
			}else{
				_titleTxt.x = _titlePosY;
			}
			_titleTxt.y = _titlePosY;
		}
		private function onCloseBtnClick(event : MouseEvent):void
		{
			dispatchEvent(new CloseEvent(CloseEvent.CLOSE));
		}
	}
}