package com.goshare.controlservice.event
{
	import com.goshare.connlib.data.SocketMessageVO;
	
	import flash.events.Event;
	
	public class ControlServiceEvent extends Event
	{
		/**
		 * 连接控制器成功 
		 */		
		public static const CONTROLER_CONNECT_SUC:String = "c1ConnectSuccess";
		
		/**
		 * 收到控制器消息的时候派发 
		 */		
		public static const CONTROLLER_MESSAGE:String = "receiveMessageC1";
		
		/**
		 * 通信日志 
		 */		
		public static const CONTROLLER_SERVICE_LOG:String = "controlConnectLog";
		
		public function ControlServiceEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
		
		public var controllerMsg:SocketMessageVO;
		
		public var logText:String;
		
	}
}