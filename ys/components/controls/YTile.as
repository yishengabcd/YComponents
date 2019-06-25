/**
 * date:2012-2-26
 * author:yisheng;
 */
package ys.components.controls
{
	import flash.display.DisplayObject;
	
	import ys.components.core.InvalidationType;
	import ys.components.core.YComponent;
	
	public class YTile extends YComponent
	{
		private var _col : int;
		private var _itemWidth : Number;
		private var _itemHeight : Number;
		
		private var _items : Array;
		public function YTile(col : int,
							  itemWidth : Number = 40, 
							  itemHeight : Number = 40)
		{
			_col = col;
			_itemWidth = itemWidth;
			_itemHeight = itemHeight;
			_items = [];
			super();
		}
		
		override public function addChild(child:DisplayObject):DisplayObject
		{
			super.addChild(child);
			_items.push(child);
			invalidate(InvalidationType.SIZE);
			return child;
		}
		
		
		public function set itemWidth(value : Number):void
		{
			_itemWidth = value;
			invalidate(InvalidationType.SIZE);
		}
		public function set itemHeight(value : Number):void
		{
			_itemHeight = value;
			invalidate(InvalidationType.SIZE);
		}
		override protected function draw():void
		{
			if(isInvalid(InvalidationType.SIZE)){
				drawLayout();
			}
			super.draw();
		}
		private function drawLayout():void
		{
			var item : DisplayObject
			for(var i : int = 0; i < _items.length; i++){
				item = _items[i];
				item.x = i%_col*_itemWidth;
				item.y = Math.floor(i/_col)*_itemHeight;
			}
		}
	}
}