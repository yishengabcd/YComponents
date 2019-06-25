/**
 * date:2012-1-14
 * author:yisheng
 */
package ys.loader
{
	import flash.utils.Dictionary;

	/**
	 * 加载管理类。
	 * 该类提供了创建LoaderBase的方法。
	 * 当同时创建多个相同的url的加载时，该方法返回相同的一个加载实例。
	 */
	public class LoaderManager
	{
		private static var _queue : LoaderQueue;
		private static var _urlList : Dictionary = new Dictionary();
		
		/**
		 * 创建LoaderBase实例。
		 * @param url
		 * @param type
		 * @return 
		 * 
		 */		
		public static function createLoader(url : String, type : int):LoaderBase
		{
			if(_urlList[url]){
				return _urlList[url] as LoaderBase;
			}
			var loader : LoaderBase;
			switch(type){
				case LoaderType.TEXT:
					loader = new TextLoader(url);
					break;
				case LoaderType.BITMAP:
					loader = new BitmapLoader(url);
					break;
				case LoaderType.DISPLAY:
					loader = new DisplayObjectLoader(url);
					break;
				case LoaderType.MODULE:
					loader = new ModuleLoader(url);
					break;
				default : 
					loader = new LoaderBase(url);
					break;
			}
			addLoader(loader);
			return loader;
		}
		/**
		 * 开始启动加载。
		 * @param loader
		 * 
		 */		
		public static function load(loader : LoaderBase):void
		{
			if(getQueue().getChildIndex(loader) == -1){
				getQueue().append(loader);
			}
		}
		
		private static function addLoader(loader : LoaderBase):void
		{
			_urlList[loader.url] = loader;
			loader.addEventListener(LoaderEvent.COMPLETE, onLoadResult);
			loader.addEventListener(LoaderEvent.ERROR, onLoadResult);
		}

		private static function onLoadResult(event:LoaderEvent):void
		{
			removeLoader(event.target as LoaderBase);
		}
		private static function removeLoader(loader : LoaderBase):Boolean
		{
			if(_urlList[loader.url]){
				delete _urlList[loader.url]
				loader.removeEventListener(LoaderEvent.COMPLETE, onLoadResult);
				loader.removeEventListener(LoaderEvent.ERROR, onLoadResult);
				return true;
			}
			return false;
		}
		public static function destroyLoader(loader : LoaderBase):void
		{
			if(removeLoader(loader)){
				getQueue().remove(loader);
				loader.destroy();
			}
		}
		/**
		 * 获得加载队列实例。
		 * 可通过此方法获得更多的加载队列的操作，
		 * 如将LoaderBase实例添加到队列的最前面等。 
		 * @return 
		 * 
		 */		
		public static function getQueue():LoaderQueue
		{
			if(_queue == null){
				_queue = new LoaderQueue();
				_queue.start();
			}
			return _queue;
		}
	}
}