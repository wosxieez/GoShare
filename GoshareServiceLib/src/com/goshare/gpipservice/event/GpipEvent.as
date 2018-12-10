package com.goshare.gpipservice.event
{
	import flash.events.Event;
	
	public class GpipEvent extends Event
	{
		/**
		 * Gpip事件转发
		 */		
		public static const GPIP_SERVICE_EVENT:String = "GpipServiceEvent";
		
		/**
		 * 日志输出事件
		 */		
		public static const GPIP_SERVICE_LOG_EVENT:String = "GpipServiceLogEvent";
		
		public function GpipEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
		
		/**  事件名 **/
		public var eventName:String = "";
		/**  事件携带参数 **/
		public var eventParam:Object;
		
		/** 日志内容 **/
		public var logInfo:String;
		
	}
}