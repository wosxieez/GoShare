package com.goshare.connlib.data
{
	public class SocketMessageVO
	{
		public function SocketMessageVO()
		{
		}
		
		/**
		 * 消息类型
		 */
		public var  type:String = "";
		/**
		 * 消息数据
		 */
		public var  content:Object = "";
		/**
		 * 消息目标  (终端号/坐席号)
		 */
		public var  to:String = "";
		/**
		 * 消息来源 (终端号/坐席号)
		 */
		public var  from:String = "";
	}
}