package ys.components.controls.dataGridClasses {
	
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import ys.components.controls.YLabelButton;
	import ys.components.core.YComponent;

    [Style(name="selectedDownSkin", type="Class")]
    [Style(name="selectedOverSkin", type="Class")]


	/**
	 * The HeaderRenderer class displays the column header for the current 
	 * DataGrid column. This class extends the YLabelButton class and adds a 
     * <code>column</code> property that associates the current header with its 
	 * DataGrid column.
     *
     * @see ys.components.controls.DataGrid DataGrid
	 */
	public class HeaderRenderer extends YLabelButton
	{
		public var _column:uint;

        /**
         * Creates a new HeaderRenderer instance.
         */
		public function HeaderRenderer():void {
			super();
			focusEnabled = false;
		}
		private static var defaultStyles:Object = {
			textFormat: null,
			disabledTextFormat: null,
			textPadding: 5
		};
		

		public static function getStyleDefinition():Object {
			return mergeStyles(defaultStyles, YLabelButton.getStyleDefinition());
		}
		
		/**
		 * The index of the column that belongs to this HeaderRenderer instance.
		 * 
		 * <p>You do not need to know how to get or set this property
		 * because it is internal. However, if you create your own  
		 * HeaderRenderer, be sure to expose it; the HeaderRenderer is used  
		 * by the DataGrid to maintain a reference between the header 
		 * and the related DataGridColumn.</p>
		 */
		public function get column():uint {
			return _column;
		}
		public function set column(value:uint):void {
			_column = value;
		}
		override protected function drawLayout():void {
			var txtPad:Number = Number(getStyleValue("textPadding"));
			textField.height =  textField.textHeight + 4;
			textField.visible = (label.length > 0);
			var txtW:Number = textField.textWidth + 4;
			var txtH:Number = textField.textHeight + 4;
			var paddedIconW:Number = 0;
			var tmpWidth:Number = Math.max(0, Math.min(txtW, width - 2 * txtPad - paddedIconW));
			textField.width = tmpWidth;
			textField.x = txtPad;
			textField.y = Math.round((height - textField.height) / 2);
			background.width = width;
			background.height = height;
		}
	}
}

