// Copyright 2007. Adobe Systems Incorporated. All Rights Reserved.
package ys.components.controls.dataGridClasses {
	
	import ys.components.controls.listClasses.ListData;
	import ys.components.controls.listClasses.ICellRenderer;
	import ys.components.controls.YTextInput;
	import ys.components.core.YComponent;
	import flash.events.Event;
	import flash.events.MouseEvent;
	



    //--------------------------------------
    //  Class description
    //--------------------------------------
	/**
	 * The DataGridCellEditor class defines the default item editor for a 
	 * DataGrid control. You can override the default item editor by subclassing 
	 * the DataGridCellEditor class, or by creating your own cell editor class.
     *
     * @see ys.components.controls.listClasses.ICellRenderer
	 */
	public class DataGridCellEditor extends YTextInput implements ICellRenderer
	{
		protected var _listData:ListData;
		protected var _data:Object;
		
        /**
         * Creates a new DataGridCellEditor instance.
         */
		public function DataGridCellEditor():void {
			super();
		}
		
		private static var defaultStyles:Object = {
			textPadding:1,
			textFormat:null,
			upSkin:"DataGridCellEditor_skin"
		};
		
		/**
         * @copy ys.components.core.YComponent#getStyleDefinition()
         *
		 * @includeExample ../../core/examples/YComponent.getStyleDefinition.1.as -noswf
		 */
		public static function getStyleDefinition():Object { 
			return defaultStyles;
		}
				
		/**
		 * @copy ys.components.controls.listClasses.ICellRenderer#listData
		 */
		public function get listData():ListData {
			return _listData;
		}	
		public function set listData(value:ListData):void {
			_listData = value;
			text = _listData.label;
		}
		
		public function get data():Object {
			return _data;
		}		
		public function set data(value:Object):void {
			_data = value;
		}
		
		/**
         * Indicates whether the cell is included in the
		 * indices that were selected by the owner. A value of <code>true</code> indicates
		 * that the cell is included in the specified indices; a value of <code>false</code>
		 * indicates that it is not. 
		 * 
		 * <p>Note that this value cannot be changed in the DataGrid. 
		 * The DataGridCellEditor class implements the ICellRenderer interface, which specifies 
		 * that this value must be defined.</p>
         * 
         * @default false
		 *
		 * @see ys.components.controls.listClasses.ICellRenderer ICellRenderer
         *
		 * @internal [kenos] If the getter always returns false, shouldn't we say so? I'd like to add such a sentence to the end
		 * of the first paragraph.
		 */
		public function get selected():Boolean {
			return false;
		}
		public function set selected(value:Boolean):void {}
		
		public function setMouseState(state:String):void {}
	}
}

