/**
 * date:2011-6-26
 * author:yisheng
 */
package ys.components.controls
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.events.MouseEvent;
	
	import ys.components.controls.member.IStateStrategy;
	import ys.components.core.InvalidationType;
	import ys.components.core.YComponent;
	import ys.components.interfaces.ISelectable;
	
	[Event(name="select",type="flash.events.Event")]
	
	/**
	 * 可选择的按钮.
	 * 该组件包含两个外观,选择和未选择,
	 * 可通过设置selectedSkin和unselectedSkin样式来实现.
	 */
	public class YSelectableButton extends YBaseButton implements ISelectable
	{
		protected var _unselectedView : DisplayObject;
		protected var _selectedView : DisplayObject;
		protected var _autoSelect : Boolean = true;
		
		private static var defaultStyles:Object = {selectedSkin : null,
													unselectedSkin : null};
		
		public static function getStyleDefinition():Object {
			return mergeStyles(defaultStyles,YBaseButton.getStyleDefinition()); 
		}
		
		public function YSelectableButton()
		{
			super();
		}
		
		public function setAutoSelect(value : Boolean):void
		{
			_autoSelect = value;
		}
		override protected function setupMouseEvents():void
		{
			super.setupMouseEvents();
			addEventListener(MouseEvent.CLICK,onMouseClickHandler,false,0,true);
		}
		override protected function draw():void
		{
			if(isInvalid(InvalidationType.STYLES)){
				drawView();
			}
			if(isInvalid(InvalidationType.STATE)){
				drawState();
			}
			validate();
		}
		override protected function drawView():void
		{
			if(_selectedView && _selectedView.parent){
				_selectedView.parent.removeChild(_selectedView);
			}
			_selectedView = getDisplayObjectInstance(getStyleValue("selectedSkin"));
			
			if(_unselectedView && _unselectedView.parent){
				_unselectedView.parent.removeChild(_unselectedView);
			}
			_unselectedView = getDisplayObjectInstance(getStyleValue("unselectedSkin"))
				
			super.drawView();
			if(_unselectedView){
				addChild(_unselectedView);
				if(_unselectedView is YComponent){
					YComponent(_unselectedView).drawNow()
				}
			}
			if(_selectedView){
				addChild(_selectedView);
				if(_selectedView is YComponent){
					YComponent(_selectedView).drawNow()
				}
			}
			invalidate(InvalidationType.STATE, false);
		}
		override protected function drawBackground():void
		{
			//do nothing
		}
		override protected function drawState():void
		{
			addStateStratege(this);
			
			if(_unselectedView){
				_unselectedView.visible = !_selected
			}
			if(_selectedView){
				_selectedView.visible = _selected;
			}
			super.drawState();
			
			drawHitArea();
		}
		override protected function getBitmap():Bitmap
		{
			var target : DisplayObject;
			target =  _selected?_selectedView:_unselectedView;
			if (target is Bitmap){
				return target as Bitmap;
			}else{
				var bmd:BitmapData = new BitmapData(target.width, target.height);
				bmd.draw(target);
				return new Bitmap(bmd);
			}
			return null;
		}
		override protected function adaptHitArea():void
		{
			_hitArea.alpha = 0;
			_hitArea.x = _selected?_selectedView.x : _unselectedView.x;
			_hitArea.y = _selected?_selectedView.y : _unselectedView.y;
		}
		protected function onMouseClickHandler(event:MouseEvent):void
		{
			if(_autoSelect)
			{
				selected = !_selected;
			}
		}
	}
}