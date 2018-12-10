package com.goshare.gpipservice.event
{
	import flash.events.Event;
	
	public class GpipServerEvent extends Event
	{
		/**
		 * 连接建立成功时候派发 
		 */		
		public static const GPIP_CONNECT_SUC:String = "gpipConnectSuccess";
		
		/**
		 * 收到消息的时候派发 
		 */		
		public static const RECEIVE_MESSAGE_GPIP:String = "receiveMessageGpip";
		
		/**
		 * 通信日志 
		 */		
		public static const GPIP_SERVER_LOG:String = "gpipConnectLog";
		
		public function GpipServerEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
		
		public var gpipMessage:Object;
		
		public var logText:String;
		
	}
}