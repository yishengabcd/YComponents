/**
 * date:2011-6-19
 * author:yisheng
 */
package ys.loader
{
	import flash.display.Loader;
	import flash.events.Event;
	import flash.events.IEventDispatcher;
	import flash.net.URLRequest;
	import flash.system.ApplicationDomain;
	import flash.system.LoaderContext;
	import flash.utils.ByteArray;
	/**
	 * 显示对象加载类.
 	 * 可通过此类对SWF及图片进行加载.
 	 * 该类提供setApplicationDomain()方法,可设置将文件加载到指定的域.
	 */	
	public class DisplayObjectLoader extends LoaderBase
	{
		protected var _loader : Loader;
		private var _domain : ApplicationDomain;
		public function DisplayObjectLoader(url : String)
		{
			super(url);
		}
		override protected function onDataLoadComplete(event:Event):void
		{
			if(_urlLoader.data.length == 0){
				dispatchEvent(new LoaderEvent(LoaderEvent.ERROR, this));
				return;
			}
			loadFromBytes(_urlLoader.data);
		}
		override public function loadFromBytes(data:ByteArray):void
		{
			if(!_loader){
				_loader = new Loader();
			}
			_loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onLoaderComplete);
			if(_domain){
				_loader.loadBytes(data,new LoaderContext(false, _domain));
			}else{
				_loader.loadBytes(data);
			}
		}
		
		protected function onLoaderComplete(event:Event):void
		{
			_loader.contentLoaderInfo.removeEventListener(Event.COMPLETE,onLoaderComplete);
			dispatchEvent(new LoaderEvent(LoaderEvent.COMPLETE, this));
		}
		
		override public function get content():*
		{
			return _loader.content;
		}
		
		public function setApplicationDomain(domain : ApplicationDomain):void
		{
			_domain = domain;
		}
		public function getApplicationDomain():ApplicationDomain
		{
			return _loader.contentLoaderInfo.applicationDomain;
		}
		
		override public function destroy():void
		{
			if(_loader){
				if(_loader.contentLoaderInfo){
					_loader.contentLoaderInfo.removeEventListener(Event.COMPLETE,onLoaderComplete);
				}
				_loader.unload();
				_loader = null;
			}
			super.destroy();
		}
	}
}