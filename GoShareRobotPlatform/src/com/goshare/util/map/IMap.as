package com.goshare.util.map
{
	/**
	 * @private
	 * <p>类似于java中的Map接口</p> 
	 * @author CYJ
	 */
	public interface IMap
	{
		/**
		 * 移除Map中的所有元素
		 * 
		 */
		function clear():void;   
		/**
		 * 查找指定的key是否存在
		 * @param 
		 * @return 
		 * 
		 */
		function containsKey(key:Object):Boolean;   
		/**
		 * 查找指定的value是否存在
		 * @param value 
		 * @return 
		 * 
		 */
		function containsValue(value:Object):Boolean;   
		/**
		 * 根据key取value 
		 * @param key
		 * @return 
		 * 
		 */
		function get(key:Object):Object;   
		/**
		 * 增加元素 
		 * @param key
		 * @param value
		 * @return 
		 * 
		 */
		function put(key:Object,value:Object):Object;   
		/**
		 * 根据key删除元素 
		 * @param key
		 * @return 
		 * 
		 */
		function remove(key:Object):Object;    
		/**
		 * 增加一组元素 
		 * @param map
		 * 
		 */
		function putAll(map:IMap):void;   
		/**
		 * Map中的元素个数 
		 * @return 
		 * 
		 */
		function size():Number;     
		/**
		 * 检测Map是否为空 
		 * @return 
		 * 
		 */
		function isEmpty():Boolean;   
		/**
		 * 返回value数组 
		 * @return 
		 * 
		 */
		function values():Array;   
		/**
		 * 返回key数组 
		 * @return 
		 * 
		 */
		function keys():Array;			
	}
}