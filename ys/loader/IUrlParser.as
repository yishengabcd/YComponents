package ys.loader
{
	/**
	 * 文件路径解析器接口
	 * @author 黄亦生
	 * @date 2013-4-12
	 */
	public interface IUrlParser
	{
		/**
		 * 解码,将url解码成实际的文件路径
		 * @param url
		 * @return 
		 * 
		 */		
		function decode(url : String):String;
	}
}