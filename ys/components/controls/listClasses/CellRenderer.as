package ys.components.controls.listClasses {
	
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import ys.components.controls.YLabelButton;
	import ys.components.controls.listClasses.ICellRenderer;
	import ys.components.controls.listClasses.ListData;
	import ys.components.core.YComponent;
	
	public class CellRenderer extends YLabelButton implements ICellRenderer {
		
		protected var _listData:ListData;

		protected var _data:Object;
		

		public function CellRenderer():void {
			super();
			toggle = true;
			focusEnabled = false;
		}
		
		private static var defaultStyles:Object = {textFormat:null,
												  disabledTextFormat:null,
												  embedFonts:null,
												  textPadding:5};

		public static function getStyleDefinition():Object { 
			return mergeStyles(defaultStyles, YLabelButton.getStyleDefinition()); 
		}
		
		override public function setSize(width:Number,height:Number):void {
			super.setSize(width, height);
		}
		
		public function get listData():ListData {
			return _listData;
		}	
		public function set listData(value:ListData):void {
			_listData = value;
			label = _listData.label;
			setStyle("icon", _listData.icon);
		}
		
		public function get data():Object {
			return _data;
		}		
		public function set data(value:Object):void {
			_data = value;
		}
		
		override public function get selected():Boolean {
			return super.selected;
		}
		 
		override public function set selected(value:Boolean):void {
			super.selected = value;
		}
		
		override protected function toggleSelected(event:MouseEvent):void {
			// don't set selected or dispatch change event.
		}
		override protected function drawLayout():void {
			var textPadding:Number = Number(getStyleValue("textPadding"));
			var textFieldX:Number = 0;
			
			// Align text
			if (label.length > 0) {
				textField.visible = true;
				var textWidth:Number =  Math.max(0, width - textFieldX - textPadding*2);
				textField.width = textWidth;
				textField.height = textField.textHeight + 4;
				textField.x = textFieldX + textPadding
				textField.y = Math.round((height-textField.height)>>1);
			} else {
				textField.visible = false;
			}
			
			// Size background
//			background.width = width;
//			background.height = height;
		}
	}
}

