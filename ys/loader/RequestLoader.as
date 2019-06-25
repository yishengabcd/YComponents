package ys.loader
{
	import ys.loader.LoaderBase;
	import ys.loader.LoaderEvent;
	import ys.utils.TimerUtils;

	/**
	 * 用于请求后台数据,需调用load()方法才会真正发生请求
	 * @author 黄亦生
	 * @date 2013-2-28
	 */
	public class RequestLoader
	{
		private var _loader : LoaderBase;
		private var _result : Function;
		private var _fault : Function;
		/**
		 * 构造函数 
		 * @param url 请求的地址
		 * @param result 成功返回后的回调方法,需带String类型参数
		 * @param fault 失败时的回调方法,需带String类型参数
		 * 
		 */		
		public function RequestLoader(url : String, 
									 result : Function, 
									 fault : Function)
		{
			_loader = new LoaderBase(url);
			_loader.setNoVersion(true);
			addParam("random",(new Date()).getTime()+Math.random());
			_result = result;
			_fault = fault;
		}
		/**
		 * 添加参数 
		 * @param key
		 * @param value
		 * 
		 */		
		public function addParam(key : String, value : *):void
		{
			_loader.addParam(key, value);
		}
		/**
		 * 发送请求 
		 */		
		public function load():void
		{
			_loader.addEventListener(LoaderEvent.COMPLETE, onComplete);
			_loader.addEventListener(LoaderEvent.ERROR, onError);
			_loader.load();
		}
		private function onComplete(event:LoaderEvent):void
		{
			removeHandler();
			if(_result != null)
			{
				_result(_loader.content);
			}
		}
		private function onError(event:LoaderEvent):void
		{
			removeHandler();
			if(_fault != null)
			{
				_fault("请求出错:"+_loader.url);
			}
		}
		private function removeHandler():void
		{
			if(_loader)
			{
				_loader.removeEventListener(LoaderEvent.COMPLETE, onComplete);
				_loader.removeEventListener(LoaderEvent.ERROR, onError);
			}
		}
	}
}