package ys.components.controls {	
	
	import flash.display.DisplayObject;
	import flash.display.Graphics;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.text.TextFieldAutoSize;
	
	import ys.components.core.InvalidationType;
	import ys.components.core.YComponent;


	public class YCheckBox extends YSelectableButton
	{

		private var _label : YLabel;
		private var _labelString : String;
		private  static var defaultStyles:Object = {labelPosX : 20, labelPosY:0, textFormat:null};
		
		public static function getStyleDefinition():Object {
			return mergeStyles(defaultStyles, YSelectableButton.getStyleDefinition());
		}
		
		public function YCheckBox() { 
			super();
		}
		
		public function get label():String
		{
			return _labelString;
		}
		public function set label(value : String):void
		{
			if(_labelString == value){
				return;
			}
			_labelString = value;
//			invalidate(InvalidationType.STYLES);
			invalidate(InvalidationType.SIZE);
		}
		override protected function drawView():void
		{
			super.drawView();
			if(_labelString){
				if(!_label){
					_label = new YLabel();
					_label.mouseChildren = _label.mouseEnabled = false;
					_label.autoSize = TextFieldAutoSize.LEFT;
					addChild(_label);
				}
				_label.text = _labelString;	
				_label.setStyle("textFormat",getStyleValue("textFormat"));
				_label.x = getStyleValue("labelPosX") as Number;
				_label.y = getStyleValue("labelPosY") as Number;
				
				_label.drawNow();
			}
		}
		override protected function drawLayout():void
		{
//			if(_label){
//				_label.x = getStyleValue("labelPosX") as Number;
//				_label.y = getStyleValue("labelPosY") as Number;
//			}
		}
		override protected function drawState():void
		{
			super.drawState();
			
			if(_unselectedView){
				if(_unselectedView.visible){
					hitArea = _unselectedView as Sprite;
				}
			}
			if(_selectedView){
				if(_selectedView.visible){
					hitArea = _selectedView as Sprite;
				}
			}
		}
		override public function get autoRepeat():Boolean { 
			return false;
		}
		override public function set autoRepeat(value:Boolean):void {
			return;	
		}	
	}
}