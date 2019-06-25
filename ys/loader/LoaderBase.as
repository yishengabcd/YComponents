/**
 * date:2012-1-9
 * author:yisheng
 */
package ys.loader
{
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.HTTPStatusEvent;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.net.URLRequestMethod;
	import flash.net.URLVariables;
	import flash.utils.ByteArray;
	
	[Event(name="complete",type="ys.loader.LoaderEvent")]
	[Event(name="error",type="ys.loader.LoaderEvent")]
	[Event(name="progress",type="ys.loader.LoaderEvent")]
	[Event(name="destroy",type="ys.loader.LoaderEvent")]
	/**
	 * 加载类基类.
	 * 该类采用URLLoader作为文件的统一加载方式,默认加载的结果是二进制数据.
	 * 当需加载的是SWF或位图时,将在二进制数据加载完成后,再对二进制数据进行操作;
	 * 详见DisplayObjectLoader.
	 */
	public class LoaderBase extends EventDispatcher
	{
		protected var _urlLoader:URLLoader;
		private var _args:URLVariables;
		private var _request:URLRequest;
		private var _url:String;
		private var _isLoading:Boolean;
		private var _bytesLoaded : int;
		private var _bytesTotal : int;
		
		protected var _requestMethod:String = URLRequestMethod.GET;
		protected var _loaderDataFormat : String = URLLoaderDataFormat.BINARY;
		/**
		 * 版本,如果不为null时,_url将被组合成"_url?"+version的形式 
		 */		
		public static var version : String;
		/**
		 * 文件路径解析器,将传入的url解析成实际的url,为null时不进行解析 
		 */		
		public static var urlParser : IUrlParser;
		/**
		 * 为true,版本号失效 
		 */		
		private var _noVersion : Boolean;
		public function LoaderBase(url:String) 
		{
			_url = url;
		}
		/**
		 * 设置是否需要版本号 
		 * @param value
		 * 
		 */		
		public function setNoVersion(value : Boolean):void
		{
			_noVersion = value;
		}
		/**
		 * 启动加载. 
		 * 出于统一管理,建议通过LoaderManager的load()方法进行启动加载.
		 */		
		public function load():void
		{
			if(_isLoading){
				return;
			}
			_urlLoader = new URLLoader();
			_urlLoader.dataFormat = _loaderDataFormat;
			var verUrl : String = _url;
			if(urlParser)
			{
				if(!_noVersion)
				{
					verUrl = urlParser.decode(verUrl);
				}
			}
			else
			{
				if(verUrl.indexOf("?") == -1 && version && version.length > 0 && !_noVersion)
				{
					verUrl = verUrl+"?"+version;
				}
			}
			trace("[LOADING] "+verUrl);
			_request = new URLRequest(verUrl);
			_request.method = _requestMethod;
			if(_args){
				_request.data = _args;
			}
			addEvent();
			
			_isLoading = true;
			_urlLoader.load(_request);
		}
		
		/**
		 * 添加参数. 
		 * @param key
		 * @param value
		 * 
		 */		
		public function addParam(key : String, value : *):void
		{
			if(!_args){
				_args = new URLVariables();
			}
			_args[key] = value;
		}
		public function setRequestMethod(value : String):void
		{
			_requestMethod = value;
		}
		public function setLoaderDataFormat(format : String):void
		{
			_loaderDataFormat = format;
		}
		public function loadFromBytes(data:ByteArray):void
		{
			
		}
		
		protected function addEvent():void
		{
			_urlLoader.addEventListener(Event.COMPLETE,onDataLoadComplete);
			_urlLoader.addEventListener(ProgressEvent.PROGRESS,onProgress);
			_urlLoader.addEventListener(HTTPStatusEvent.HTTP_STATUS,onStatus);
			_urlLoader.addEventListener(IOErrorEvent.IO_ERROR,onIOError);
		}
		/**
		 * 数据加载完成的处理函数.
		 * 子类可通过覆盖此方法对数据作进一步处理. 
		 * @param event
		 * 
		 */		
		protected function onDataLoadComplete(event:Event):void
		{
			dispatchEvent(new LoaderEvent(LoaderEvent.COMPLETE, this));
		}
		protected function onIOError(event:IOErrorEvent):void
		{
			onLoadError();
		}
		
		protected function onProgress(event:ProgressEvent):void
		{
			_bytesLoaded = event.bytesLoaded;
			_bytesTotal = event.bytesTotal;
			dispatchEvent(new LoaderEvent(LoaderEvent.PROGRESS, this));
		}
		protected function onStatus(event:HTTPStatusEvent):void
		{
			if(event.status > 399)
			{
				onLoadError();
			}
		}
		protected function onLoadError():void
		{
			dispatchEvent(new LoaderEvent(LoaderEvent.ERROR, this));
		}
		
		protected function removeEvent():void
		{
			_urlLoader.removeEventListener(Event.COMPLETE,onDataLoadComplete);
			_urlLoader.removeEventListener(ProgressEvent.PROGRESS,onProgress);
			_urlLoader.removeEventListener(HTTPStatusEvent.HTTP_STATUS,onStatus);
			_urlLoader.removeEventListener(IOErrorEvent.IO_ERROR,onIOError);
		}
		
		public function get isLoading():Boolean
		{
			return _isLoading;
		}
		/**
		 * 获得加载的内容.
		 * 只有当加载完成后,该方法才返回真正的加载的内容.
		 * 子类可通过覆盖此方法来返回不同的值. 
		 * @return 
		 * 
		 */		
		public function get content():*
		{
			return _urlLoader.data;
		}
		public function get url():String
		{
			return _url;
		}
		public function get bytesLoaded():int
		{
			return _bytesLoaded;
		}
		public function get bytesTotal():int
		{
			return _bytesTotal;
		}
		
		public function destroy() : void
		{
			if(_urlLoader){
				if(_isLoading){
					_isLoading = false;
					try{
						_urlLoader.close();
					}
					catch(err :Error){}
				}
				removeEvent();
			}
			_urlLoader = null;
			dispatchEvent(new LoaderEvent(LoaderEvent.DESTROY, this));
		}
	}
}