package ys.components.controls.listClasses {
	
	import ys.components.core.YComponent;
	
	/**
     * ListData is a messenger class that holds information relevant to a specific 
     * cell in a list-based component. This information includes the label and icon that are
	 * associated with the cell; whether or not the cell is selected; and the position of 
	 * the cell in the list by row and column. 
	 *
	 * <p>A new ListData component is created for a cell renderer 
	 * each time it is invalidated.</p>
	 */
	public class ListData {

		protected var _icon:Object = null;

		protected var _label:String;

		protected var _owner:YComponent;

		protected var _index:uint;

		protected var _row:uint;

		protected var _column:uint;
	
		/**
		 * Creates a new instance of the ListData class as specified by its parameters. 
         *
         * @param label The label to be displayed in this cell.
         *
         * @param icon The icon to be displayed in this cell.
         *
         * @param owner The component that owns this cell.
         *
         * @param index The index of the item in the data provider.
         *
         * @param row The row in which this item is being displayed. In a List or 
         *        DataGrid, this value corresponds to the index. In a TileList, this
		 *        value may be different than the index.
         *
         * @param col The column in which this item is being displayed. In a List, 
         *        this value is always 0.
		 */
		public function ListData(label:String,icon:Object,owner:YComponent,index:uint,row:uint,col:uint=0) {
			_label = label;
			_icon = icon;
			_owner = owner;
			_index = index;
			_row = row;
			_column = col;
		}		
		
		/**
         * The label to be displayed in the cell.
		 */
		public function get label():String {
			return _label;
		}
		
		/**
		 * A class that represents the icon for the item in the List component, 
         * computed from the List class method.
		 */
		public function get icon():Object {
			return _icon;
		}
		
		/**
         * A reference to the List object that owns this item.
		 */
		public function get owner():YComponent {
			return _owner;
		}
		
		/**
         * The index of the item in the data provider.
		 */
		public function get index():uint {
			return _index;
		}
		
		/**
         * The row in which the data item is displayed.
		 */
		public function get row():uint {
			return _row;
		}
		
		/**
		 * The column in which the data item is displayed. In a list, 
         * this value is always 0.
		 */
		public function get column():uint {
			return _column;
		}		
	}
}

