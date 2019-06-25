/**
 * date:2011-6-26
 * author:yisheng
 */
package ys.components.interfaces
{
	import flash.display.IDisplayObject;

	public interface ISelectable extends IDisplayObject
	{
		function set selected(value : Boolean):void;
		function get selected():Boolean;
	}
}