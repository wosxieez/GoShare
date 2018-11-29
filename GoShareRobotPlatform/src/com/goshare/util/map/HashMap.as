package com.goshare.util.map
{
	import flash.utils.Dictionary;

	/**
	 * <p>仿Java的HashMap对象</p> 
	 * @author CYJ
	 * @langversion 1.0
	 * @see com.hisun.ics.flex.utils.map.IMap IMap
	 */
	public class HashMap implements IMap
	{     
		/**
		 * @private
		 * 键值 
		 */
		private var _keys:Array = null;   
		/**
		 * @private
		 * 对象字典 
		 */
		private var props:Dictionary = null;   
		
		/**
		 * <p>构造函数</p> 
		 */
		public function HashMap()
		{   
			this.clear();   
		}   
		
		/**
		 * <p>移除Map中的所有元素</p> 
		 */
		public function clear():void
		{   
			this.props = new Dictionary();   
			this._keys = new Array();   
		}  
		
		/**
		 * <p>查找指定的key是否存在</p> 
		 * @param key 键值
		 * @return <code>true</code>-是, <code>false</code>-否
		 * 
		 */
		public function containsKey(key:Object):Boolean
		{   
			return this.props[key] != null;   
		}   
		
		/**
		 * <p>查找指定的value是否存在</p>
		 * @param value 对象
		 * @return <code>true</code>-是, <code>false</code>-否
		 * 
		 */
		public function containsValue(value:Object):Boolean
		{   
			var result:Boolean = false;   
			var len:uint = this.size();   
			if(len > 0)
			{   
				for(var i:uint = 0 ; i < len ; i++)
				{   
					if(this.props[this._keys[i]] == value)
					{
						result=true;   
					}
					else
					{
						result=false; 
					}
				}   
			}
			else
			{
				result= false;   
			}
			return result;     
		}  
		
		/**
		 * <p>根据key取value</p> 
		 * @param key 键值
		 * @return value对象
		 * 
		 */
		public function get(key:Object):Object
		{   
			return this.props[key];   
		}  
		
		/**
		 * 从指定的Key中获取 Value
		 * @param key
		 * @return 
		 * 
		 */		
		public function getValue(key:*):*
		{
			var value:* = this.props[key];
			return value === undefined ? null : value;
		}

		
		/**
		 * 从指定的Value中获取Key
		 * @param value
		 * @return 
		 * 
		 */		
		public function getKey(value:*):*
		{
			var i:*;
			for(i in this.props)
			{
				if(this.props[i] == value)
				{
					return i;
				}
			}
			return null;
		}

		
		/**
		 * <p>增加元素 </p> 
		 * @param key 键值
		 * @param value 对象
		 * @return 被覆盖的value对象
		 * 
		 */
		public function put(key:Object,value:Object):Object
		{   
			var result:Object = null;   
			if(this.containsKey(key))
			{   
				result = this.get(key);   
				this.props[key] = value;   
			}
			else
			{   
				this.props[key] = value;   
				this._keys.push(key);   
			}   
			return result;   
		}   
		
		/**
		 * <p>根据key删除元素</p> 
		 * @param key 键值
		 * @return 被删除的value对象
		 * 
		 */
		public function remove(key:Object):Object{   
			var result:Object = null;   
			if(this.containsKey(key)){   
				delete this.props[key];   
				var index:int = this._keys.indexOf(key);   
				if(index > -1){   
					this._keys.splice(index,1);   
				}   
			}   
			return result;   
		}   
		
		/**
		 * <p>增加一组元素</p> 
		 * @param map 待增加的元素组
		 * 
		 */
		public function putAll(map:IMap):void{         
			this.clear();      
			var len:uint = map.size();   
			if(len > 0){   
				var arr:Array = map.keys();     
				for(var i:uint=0;i<len;i++){   
					this.put(arr[i],map.get(arr[i]));   
				}   
			}   
		}   
		
		/**
		 * <p>Map中的元素个数 </p> 
		 * @return Map大小
		 * 
		 */
		public function size():Number{      
			return this._keys.length;   
		}   
		
		/**
		 * 检测Map是否为空  
		 * @return <code>true</code>-是, <code>false</code>-否
		 * 
		 */
		public function isEmpty():Boolean{
			return this.size()<1;       
		}   
		
		/**
		 * <p>返回value数组 </p> 
		 * @return value数组  
		 * 
		 */
		public function values():Array{   
			var result:Array = new Array();   
			var len:Number = this.size();   
			if(len > 0){   
				for(var i:Number = 0;i<len;i++){   
					result.push(this.props[this._keys[i]]);   
				}   
			}       
			return result;   
		}  
		
		/**
		 * <p>返回key数组 </p> 
		 * @return key数组
		 * 
		 */
		public function keys():Array{   
			return this._keys;   
		}  
		
		/**
		 * <p>输出Map</p> 
		 * @return Map字符串
		 * 
		 */
		public function toString():String{   
			var out:String = "";   
			for(var i:uint=0;i<this.size();i++){   
				out += this._keys[i] + ":"+this.get(this._keys[i]) + "\n";   
			}   
			return out;   
		}  
	}
}