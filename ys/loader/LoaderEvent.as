/**
 * date:2012-1-11
 * author:yisheng
 */
package ys.loader
{
	import flash.events.Event;
	
	/**
	 * 加载相关的事件类.
	 */
	public class LoaderEvent extends Event
	{
		public static const COMPLETE : String = "complete";
		public static const ERROR : String = "error";
		public static const PROGRESS : String = "progress";
		public static const DESTROY : String = "destroy"
		private var _loader : LoaderBase;
		public function LoaderEvent(type:String, loader: LoaderBase = null)
		{
			_loader = loader;
			super(type, false, false);
		}
		public function getLoader():LoaderBase
		{
			return _loader;
		}
	}
}