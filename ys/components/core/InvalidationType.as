// Copyright 2007. Adobe Systems Incorporated. All Rights Reserved.
package ys.components.core {
	
	/**
	 * The InvalidationType class defines <code>InvalidationType</code> constants 
	 * that are used by the <code>type</code> property of an event object that is 
	 * dispatched after a component is invalidated. These constants are used 
	 * by component developers to specify the portion of the component that is to be redrawn 
	 * after the component is invalidated.
	 */
	public class InvalidationType {
		/**
         * The <code>InvalidationType.ALL</code> constant defines the value of the <code>type</code> 
         * property of the event object that is dispatched to indicate that the component should
		 * redraw itself entirely. 
		 */
		public static const ALL:String = "all";
		
		/**
         * The <code>InvalidationType.SIZE</code> constant defines the value of the <code>type</code> 
         * property of the event object that is dispatched to indicate that the screen dimensions of
		 * the component are invalid. 
		 */
		public static const SIZE:String = "size";
		
		/**
         * The <code>InvalidationType.STYLES</code> constant defines the value of the <code>type</code> 
         * property of the event object that is dispatched to indicate that the styles of the component 
		 * are invalid.
		 */
		public static const STYLES:String = "styles";
		
		/**
         * The <code>InvalidationType.RENDERER_STYLES</code> constant defines the value of
		 * the <code>type</code> property of the event object that is dispatched to indicate that
		 * the renderer styles of the component are invalid.
		 */
		public static const RENDERER_STYLES:String = "rendererStyles";		
		
		/**
         * The <code>InvalidationType.STATE</code> constant defines the value of the <code>type</code> 
         * property of the event object that is dispatched to indicate that the state of the component
		 * is invalid. For example, this constant is used when the <code>enabled</code> state of a component
		 * is no longer valid.
		 */
		public static const STATE:String = "state";
		
		/**
         * The <code>InvalidationType.DATA</code> constant defines the value of the <code>type</code> 
         * property of the event object that is dispatched to indicate that the data that belongs to
		 * a component is invalid. 
		 */
		public static const DATA:String = "data";
		
		/**
         * The <code>InvalidationType.SCROLL</code> constant defines the value of the <code>type</code> 
         * property of the event object that is dispatched to indicate that the scroll position of the
		 * component is invalid. 
		 */
		public static const SCROLL:String = "scroll";
		
		/**
         * The <code>InvalidationType.SELECTED</code> constant defines the value of the <code>type</code> 
         * property of the event object that is dispatched to indicate that the <code>selected</code> 
		 * property of the component is invalid.
		 */
		public static const SELECTED:String = "selected";
	}
}