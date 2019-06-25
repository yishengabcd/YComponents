/**
 * date:2011-7-3
 * author:yisheng
 */
package ys.components.collections
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.MouseEvent;
	
	import ys.components.interfaces.ISelectable;
	
	public class SelectItemGroup extends EventDispatcher
	{
		public function SelectItemGroup()
		{
			_items = new Vector.<ISelectable>();
		}
		
		private var _currentSelecetdIndex:int = -1;
		private var _items:Vector.<ISelectable>;
		private var _lastSelectedButton:ISelectable;
		
		/**
		 * 
		 * @param item 添加一个单元
		 * 
		 */		
		public function addItem(item:ISelectable):void
		{
			item.addEventListener(MouseEvent.CLICK,__onItemClicked);
			_items.push(item);
		}
		public function removeAllItem():void
		{
			for(var i:int = 0; i < _items.length; i ++)
			{
				_items[i].removeEventListener(MouseEvent.CLICK,__onItemClicked);	
			}
			_items.splice(0,_items.length);//splice(i,1);
			
			_currentSelecetdIndex = -1;
		}
		public function dispose():void
		{
			for(var i:int = 0;i<_items.length;)
			{
				removeItemByIndex(0);
			}
			_lastSelectedButton = null;
			_items = null;
		}
		
		/**
		 * 获取Item的Index
		 * @param item
		 * @return 
		 */
		public function getSelectIndexByItem(item:ISelectable):int
		{
			return _items.indexOf(item);
		}
		public function getSelectedItem():ISelectable
		{
			if(selectIndex == -1)return null;
			return _items[selectIndex];
		}
		/**
		 * 
		 * @param index 通过序号移除单元
		 * 
		 */		
		public function removeItemByIndex(index:int):void
		{
			if(index != -1)
			{
				_items[index].removeEventListener(MouseEvent.CLICK,__onItemClicked);
				_items.splice(index,1);
			}
		}
		/**
		 * 
		 * @param item 需要移除的单元
		 * 
		 */		
		public function removeItem(item:ISelectable):void
		{
			var index:int = _items.indexOf(item);
			removeItemByIndex(index);
		}
		public function setSelectItem(item:ISelectable):void
		{
			var index:int = _items.indexOf(item);
			selectIndex = index;
		}
		public function get selectIndex():int{
			return _items.indexOf(_lastSelectedButton);
		}
		
		public function set selectIndex(index:int):void
		{
			var changed:Boolean = _currentSelecetdIndex != index;
			if(index == -1)
			{
				if(_lastSelectedButton)
				{
					_lastSelectedButton.selected = false;
				}
				_currentSelecetdIndex = index;
				_lastSelectedButton = null;
			}
			else
			{
				var target:ISelectable = _items[index];
				if(!target.selected)
				{
					if(_lastSelectedButton)
					{
						_lastSelectedButton.selected = false;
					}
					target.selected = true;
					_currentSelecetdIndex = index;
					_lastSelectedButton = target;
				}
			}
			if(changed)dispatchEvent(new Event(Event.CHANGE));
		}
		/**
		 * 
		 * @return 选中的数量
		 * 
		 */		
		public function get selectedCount():int
		{
			var result:int = 0;
			for(var i:int = 0;i<_items.length;i++)
			{
				if(_items[i].selected)  result ++;
			}
			return result
		}
		
		private function __onItemClicked(event:Event):void
		{
			var target:ISelectable = event.currentTarget as ISelectable;
			selectIndex = _items.indexOf(target);
		}
		
		public function getItems():Vector.<ISelectable>
		{
			return _items;
		}
	}
}