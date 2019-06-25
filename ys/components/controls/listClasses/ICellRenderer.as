package ys.components.controls.listClasses {
	import ys.components.controls.listClasses.ListData; 
	/**
     * The ICellRenderer interface provides the methods and properties that a cell renderer requires.
	 * All user defined cell renderers should implement this interface. All user defined cell renderers
	 * must extend either the UIComponent class or a subclass of the UIComponent class.
	 */	
	public interface ICellRenderer {		

		function set y(y:Number):void;
		function set x(x:Number):void;
		
		function setSize(width:Number,height:Number):void;
		
		/**
         * Gets or sets the list properties that are applied to the cell--for example,
		 * the <code>index</code> and <code>selected</code> values. These list properties
		 * are automatically updated after the cell is invalidated.
		 */
		function get listData():ListData;
		function set listData(value:ListData):void;		

		/**
         * Gets or sets an Object that represents the data that is 
		 * associated with a component. When this value is set, the 
		 * component data is stored and the containing component is 
		 * invalidated. The invalidated component is then automatically 
		 * redrawn.
		 *
		 * <p>The data property represents an object containing the item
		 * in the DataProvider that the cell represents.  Typically, the
		 * data property contains standard properties, depending on the
		 * component type. In CellRenderer in a List or ComboBox component
		 * the data contains a label, icon, and data properties; a TileList: a 
		 * label and a source property; a DataGrid cell contains values
		 * for each column.  The data property can also contain user-specified
		 * data relevant to the specific cell. Users can extend a CellRenderer
		 * for a component to utilize different properties of the data 
		 * in the rendering of the cell.</p>
		 *
		 * <p>Additionally, the <code>labelField</code>, <code>labelFunction</code>, 
		 * <code>iconField</code>, <code>iconFunction</code>, <code>sourceField</code>, 
		 * and <code>sourceFunction</code> elements can be used to specify which properties 
		 * are used to draw the label, icon, and source respectively.</p>
		 */
		function get data():Object;
		function set data(value:Object):void;
		
        function get selected():Boolean;
        function set selected(value:Boolean):void;
		
		/**
		 * Sets the current cell to a specific mouse state.  This method 
		 * is necessary for the DataGrid to set the mouse state on an entire
         * row when the user interacts with a single cell.
		 */
		function setMouseState(state:String):void;
	}
}
