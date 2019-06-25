// Copyright 2007. Adobe Systems Incorporated. All Rights Reserved.
package ys.components.controls {
	
	/**
     * Values for the <code>horizontalScrollPolicy</code> and <code>verticalScrollPolicy</code> 
	 * properties of the BaseScrollPane class. 
	 *
     * @see ys.components.containers.BaseScrollPane#horizontalScrollPolicy BaseScrollPane.horizontalScrollPolicy
     * @see ys.components.containers.BaseScrollPane#verticalScrollPolicy BaseScrollPane.verticalScrollPolicy
     *
     * @langversion 3.0
     * @playerversion Flash 9.0.28.0
	 *  
	 *  @playerversion AIR 1.0
	 *  @productversion Flash CS3
	 */
	public class YScrollPolicy {
		/**
         * Always show the scroll bar. The size of the scroll bar is automatically 
         * added to the size of the owner's contents to determine the size of the 
         * owner if explicit sizes are not specified.
         *
		 */
		public static const ON:String = "on";
		/**
		 * Show the scroll bar if the children exceed the owner's dimensions.
		 * The size of the owner is not adjusted to account for the scroll bars 
		 * when they appear, so this may cause the scroll bar to obscure the contents 
         * of the component or container.
         *
		 */
		public static const AUTO:String = "auto";


		/**
         * Never show the scroll bar.
         *
		 */
		public static const OFF:String = "off";
	}
}