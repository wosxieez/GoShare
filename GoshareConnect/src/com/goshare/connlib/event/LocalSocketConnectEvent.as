package com.goshare.connlib.event
{
	import flash.events.Event;
	
	public class LocalSocketConnectEvent extends Event
	{
		
		/**
		 * 连接成功的时候派发 
		 */		
		public static const CONNECT:String = "connect";
		/**
		 * 断开连接的时候派发 
		 */		
		public static const DISCONNECT:String = "disconnect";
		/**
		 * 连接异常的时候派发 
		 */		
		public static const ERROR:String = "error";
		/**
		 * 收到消息的时候派发 
		 */		
		public static const RECEIVE_MESSAGE:String = "receiveMessage";
		
		public function LocalSocketConnectEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
		
		/**  接收到的返回数据 **/
		public var data:String;
		
		public var descript:String;
		
//		/** Mina返回数据 **/
//		public var messageMina:SocketMessageVO;
//		
//		/** Gpip返回数据 **/
//		public var messageGpip:Object;
		
	}
}