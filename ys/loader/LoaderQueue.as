/**
 * date:2012-1-14
 * author:yisheng
 */
package ys.loader
{
	import flash.events.Event;
	import flash.utils.Dictionary;

	/**
	 * 加载队列类.
	 * 该类主要按队列对加载进行管理,如限制同时进行加载的数量(maxConnections)
	 * 外部可通过append;prepend;insert等方法将LoaderBase添加到加载队列中。
	 * 需通过调用start()方法来启动加载。
	 */
	public class LoaderQueue
	{
		/**
		 * 加载队列中的LoaderBase数组.
		 */		
		private var _loaders : Array
		/**
		 * 激活了的LoaderBase的集合
		 */		
		private var _activeLoaders:Dictionary;
		private var _activeCount : int;
		/**
		 * 最大连接数.即同一时间进行加载的数量. 
		 */		
		public var maxConnections:uint;
		
		private var _started : Boolean;
		
		
		
		public function LoaderQueue()
		{
			_loaders = new Array();
			_activeLoaders = new Dictionary();
			maxConnections = 3
		}
		/**
		 * 将一个LoaderBase添加到队列最后面.
		 * @param loader
		 * @return 
		 */		
		public function append(loader : LoaderBase):LoaderBase
		{
			return insert(loader, _loaders.length);
		}
		/**
		 * 将一个LoaderBase添加到队列最前面.
		 * @param loader
		 * @return 
		 * 
		 */
		public function prepend(loader : LoaderBase):LoaderBase
		{
			return insert(loader, 0);
		}
		/**
		 * 将一个LoaderBase添加到队列中指定的索引位置.
		 * @param loader
		 * @param index
		 * @return 
		 * 
		 */		
		public function insert(loader : LoaderBase, index : int):LoaderBase
		{
			if (index > _loaders.length) {
				index = _loaders.length;
			}
			_loaders.splice(index, 0, loader);
			loader.addEventListener(LoaderEvent.DESTROY, onLoaderDestroy);
			loadNext(null);
			return loader;
		}

		/**
		 * 从队列中移除一个LoaderBase.
		 * @param loader
		 * @param loadNextBool
		 * 
		 */		
		public function remove(loader : LoaderBase, loadNextBool : Boolean = true):void
		{
			if (loader == null) {
				return;
			}
			removeLoaderListeners(loader);
			var index : int = getChildIndex(loader);
			if(index > -1){
				_loaders.splice(index, 1);
			}
			
			if (loader in _activeLoaders) {
				delete _activeLoaders[loader];
				_activeCount--;
				if (_started && loadNextBool) {
					loadNext(null);
				}
			}
		}
		
		/**
		 * 清空加载队列. 
		 */		
		public function clear():void
		{
			var i:int = _loaders.length;
			while (--i > -1) {
				remove(_loaders[i]);
			}
		}
		
		/**
		 * 开始加载. 
		 * 只有调用了此方法,加载才会真正进行.
		 */		
		public function start():void
		{
			_started = true;
			loadNext(null);
		}
		/**
		 * 停止加载. 
		 * 该操作不会停止当前正在进行的加载；
		 * 仅仅是标识了不需要进入后继的加载；
		 * 如需重新启动加载，需调用start()方法。
		 */		
		public function stop():void
		{
			_started = false;
		}
		protected function loadNext(event:Event=null):void {
			if (event != null) {
//				_activeCount--;
//				delete _activeLoaders[event.target];
//				removeLoaderListeners(LoaderBase(event.target));
				remove(event.target as LoaderBase, false);
			}
			if(!_started){
				return;
			}
			var loader:LoaderBase;
			var l:uint = _loaders.length;
			
			for (var i:int = 0; i < l; i++) {
				if (_activeCount == this.maxConnections) {
					break;
				}
				loader = _loaders[i];
				if (!(loader in _activeLoaders)) {
					_activeCount++;
					
					_activeLoaders[loader] = true;
					loader.addEventListener(LoaderEvent.COMPLETE, loadNext);
					loader.addEventListener(LoaderEvent.ERROR, loadNext);
					loader.load();
				}
			}
		}
		
		private function onLoaderDestroy(event:LoaderEvent):void
		{
			remove(event.target as LoaderBase);
		}
		protected function removeLoaderListeners(loader:LoaderBase):void {
			loader.removeEventListener(LoaderEvent.COMPLETE, loadNext);
			loader.removeEventListener(LoaderEvent.ERROR, loadNext);
			loader.removeEventListener(LoaderEvent.DESTROY, onLoaderDestroy);
		}
		public function getChildIndex(loader:LoaderBase):int
		{
			var i:int = _loaders.length;
			while (--i > -1) {
				if (_loaders[i] == loader) {
					return i;
				}
			}
			return -1;
		}
	}
}