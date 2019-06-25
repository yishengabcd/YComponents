package ys.components.controls { 
	
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.text.TextFieldType;
	import flash.text.TextFormat;
	import flash.ui.Keyboard;
	
	import ys.components.controls.YBaseButton;
	import ys.components.controls.YButtonLabelPlacement;
	import ys.components.core.InvalidationType;
	import ys.components.events.ComponentEvent;
	
	[Event(name="click", type="flash.events.MouseEvent")]	
	[Event(name="labelChange", type="ys.components.events.ComponentEvent")]
	
	public class YLabelButton extends YBaseButton{

		private var _textField:TextField;

		protected var _toggle:Boolean = false;
		protected var oldMouseState:String;
		protected var _label:String="";		

		private static var defaultStyles:Object = {
												  textFormat:null,
												  selectedTextFormat : null,
												  textPadding:5,
												  textFilters:null,
												  offsetX:0,
												  offsetY:0
												  };
		public static function getStyleDefinition():Object { 
			return mergeStyles(defaultStyles, YBaseButton.getStyleDefinition());
		}

		public function YLabelButton() {
			super();
		}
		
		public function get label():String {
			return _label;
		}		
		public function set label(value:String):void {
			_label = value;
			if (textField.text != _label) {
				textField.text = _label;
				dispatchEvent(new ComponentEvent(ComponentEvent.LABEL_CHANGE));
				invalidate(InvalidationType.SIZE);
			}
		}	
		
		public function get toggle():Boolean {
			return _toggle;
		}		
		public function set toggle(value:Boolean):void {
			if (!value && super.selected) { selected = false; }
			_toggle = value;
			if(_toggle){
				addEventListener(MouseEvent.CLICK,toggleSelected,false,0,true); 
			}else{
				removeEventListener(MouseEvent.CLICK,toggleSelected); 
			}
			invalidate(InvalidationType.STATE);
		}
		
		protected function toggleSelected(event:MouseEvent):void {
			selected = !selected;
			dispatchEvent(new Event(Event.CHANGE, true));
		}	
		
		override public function get selected():Boolean {
			return (_toggle) ? _selected : false;
		}		
		override public function set selected(value:Boolean):void {
			_selected = value;
			if (_toggle) {
				invalidate(InvalidationType.STATE);
			}
		}
		
		override protected function configUI():void {
			super.configUI();
			
			_textField = new TextField();
			_textField.type = TextFieldType.DYNAMIC;
			_textField.cacheAsBitmap = true;
			_textField.selectable = false;
			_textField.height = 22
			addChild(_textField);
		}
		
		public function get textField():TextField
		{
			return _textField;
		}
		
		override protected function drawBackground():void
		{
			super.drawBackground();
			addStateStratege(this);
			drawTextFormat();
			_textField.filters = getStyleValue("textFilters") as Array;
		}
		
		protected function drawTextFormat():void {
			var tf:TextFormat = getStyleValue("textFormat") as TextFormat;
			if(_selected && getStyleValue("selectedTextFormat")){
				tf = getStyleValue("selectedTextFormat") as TextFormat;
			}
			if (tf != null) {
				_textField.setTextFormat(tf);
			}
			_textField.defaultTextFormat = tf;
		}
		override protected function drawState():void
		{
			super.drawState();
			drawTextFormat()
		}
		
		override protected function drawLayout():void {
			var txtPad:Number = Number(getStyleValue("textPadding"));
			var placement:String = YButtonLabelPlacement.TOP;
			_textField.height =  _textField.textHeight+4;
			
			var txtW:Number = _textField.textWidth+4;
			var txtH:Number = _textField.textHeight+4;
			
			var paddedIconW:Number = 0;
			var paddedIconH:Number = 0;
			_textField.visible = (label.length > 0);
			
			var tmpWidth:Number;
			var tmpHeight:Number;
			var offsetX : Number
			
			if (_textField.visible == false) {
				_textField.width = 0;
				_textField.height = 0;
			} else if (placement == YButtonLabelPlacement.BOTTOM || placement == YButtonLabelPlacement.TOP) {
				tmpWidth = Math.max(0,Math.min(txtW,width-2*txtPad));
				if (height-2 > txtH) {
					tmpHeight = txtH;
				} else {
					tmpHeight = height-2;
				}
				offsetX = getStyleValue("offsetX") as Number;
				
				_textField.width = txtW = tmpWidth// - offsetX;;
				_textField.height = txtH = tmpHeight;
				
				_textField.x = Math.round((width-txtW)/2)+offsetX;;
				_textField.y = Math.round((height-_textField.height-paddedIconH)/2+((placement == YButtonLabelPlacement.BOTTOM) ? paddedIconH : 0))+getStyleValue("offsetY");;
			} else {
				tmpWidth =  Math.max(0,Math.min(txtW,width-paddedIconW-2*txtPad));
				offsetX = getStyleValue("offsetX") as Number;
				_textField.width = txtW = tmpWidth//-	offsetX;
				
				_textField.x = Math.round((width-txtW-paddedIconW)/2+((placement != YButtonLabelPlacement.LEFT) ? paddedIconW : 0))+offsetX;
				_textField.y = Math.round((height-_textField.height)/2)+getStyleValue("offsetY");
			}
			super.drawLayout();			
		}
	
		
		override protected function keyDownHandler(event:KeyboardEvent):void {
			if (!enabled) { return; }
			if (event.keyCode == Keyboard.SPACE) {
				if(oldMouseState == null) {
					oldMouseState = mouseState;
				}
				setMouseState("down");
				startPress();
			}
		}
		
		override protected function keyUpHandler(event:KeyboardEvent):void {
			if (!enabled) { return; }
			if (event.keyCode == Keyboard.SPACE) {
				setMouseState(oldMouseState);
				oldMouseState = null;
				endPress();
				dispatchEvent(new MouseEvent(MouseEvent.CLICK));
			}
		}
	}
}