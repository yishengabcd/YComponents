/**
 * date:2012-1-15
 * author:yisheng
 */
package ys.loader
{
	import flash.system.ApplicationDomain;

	public class ModuleLoader extends DisplayObjectLoader
	{
		public function ModuleLoader(url:String)
		{
			super(url);
			setApplicationDomain(ApplicationDomain.currentDomain);
		}
	}
}