/**
 * date:2012-1-5
 * author:yisheng
 **/
package ys.components.containers
{
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.utils.Dictionary;
	import flash.utils.setTimeout;
	
	import ys.components.core.InvalidationType;
	import ys.components.core.YComponent;
	import ys.components.events.ComponentEvent;
	
	[Event(name="resize",type="flash.events.Event")]
	/**
	 * 按水平或垂直方向排列组件的容器类基类.
	 **/
	public class YBaseBox extends YComponent
	{
		private static const DATA_CHANGED : String = "dataChanged"
			
		private var _gap : Number = 0;
		
		public function YBaseBox()
		{
			super();
		}
		
		public function set gap(value : Number):void
		{
			_gap = value;
			invalidate(DATA_CHANGED);
		}
		public function get gap():Number{	return _gap;}
		
		
		override public function addChild(child:DisplayObject) : DisplayObject
		{
			super.addChild(child);
			child.addEventListener(ComponentEvent.RESIZE, onResize, false, 0, true);
			invalidate(DATA_CHANGED);
			return child;
		}
		override public function addChildAt(child:DisplayObject, index:int) : DisplayObject
		{
			super.addChildAt(child, index);
			child.addEventListener(ComponentEvent.RESIZE, onResize, false, 0, true);
			invalidate(DATA_CHANGED);
			return child;
		}
		override public function removeChild(child:DisplayObject):DisplayObject
		{
			super.removeChild(child);
			invalidate(DATA_CHANGED);
			return child;
		}
		override public function removeChildAt(index:int):DisplayObject
		{
			var child:DisplayObject = super.removeChildAt(index);
			invalidate(DATA_CHANGED);
			return child;
		}
		protected function onResize(event:ComponentEvent):void
		{
			addEventListener(Event.ENTER_FRAME, onResizeEnterFrame, false, 0, true);
		}
		
		public function removeAll():void
		{
			while(numChildren > 0)
			{
				removeChildAt(0);
			}
		}
		private function onResizeEnterFrame(event:Event):void
		{
			removeEventListener(Event.ENTER_FRAME, onResizeEnterFrame);
			invalidate(DATA_CHANGED, false);
			drawNow()
		}
		override protected function draw() : void
		{
			if (isInvalid(DATA_CHANGED)) {
				drawLayout();
			}
			validate();
		}
		protected function drawLayout():void
		{
			//dispatchEvent(new Event(Event.RESIZE));
		}
	}
}