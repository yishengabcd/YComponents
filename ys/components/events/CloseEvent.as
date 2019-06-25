/**
 * date:2011-6-25
 * author:yisheng
 **/
package ys.components.events
{
	import flash.events.Event;
	
	public class CloseEvent extends Event
	{
		public static const CLOSE : String = "close";
		public function CloseEvent(type:String, detail : int = -1)
		{
			super(type, false, false);
			this.detail = detail;
		}
		
		public var detail : int;
	}
}