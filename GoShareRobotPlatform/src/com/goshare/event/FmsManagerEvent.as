package com.goshare.event
{
	import flash.events.Event;
	
	/*******************************
	 * 
	 * 座席端(远程控制端)事件集合
	 * 
	 ****************************/
	public class FmsManagerEvent extends Event
	{
		/**
		 * FMS正常建立连接事件
		 */
		public static const FMS_CONNECT_EVENT : String= "fmsConnectEvent";
		
		/**
		 * FMS连接已恢复事件
		 */
		public static const FMS_RECONNECT_EVENT : String= "fmsReconnectEvent";
		
		/**
		 * FMS连接正常断开事件
		 */
		public static const FMS_DISCONNECT_NORMAL_EVENT : String= "fmsDisconnectNormalEvent";
		
		/**
		 * FMS连接异常断开事件
		 */
		public static const FMS_DISCONNECT_UNNORMALEVENT : String= "fmsDisconnectUnNormalEvent";
		
		/**
		 * 与FMS服务器连接错误的时候派发
		 */		
		public static const FMS_ERROR:String = "fmsServerError";
		
		/**
		 * 收到FMS服务器数据的时候派发 
		 */		
		public static const FMS_MESSAGE:String = "fmsServerMessage";
		
		
		public function FmsManagerEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
		
		/**
		 * 消息说明 
		 */		
		public var descript:String;
		
	}
}