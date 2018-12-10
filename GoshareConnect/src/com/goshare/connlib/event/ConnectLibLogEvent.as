package com.goshare.connlib.event
{
	import flash.events.Event;
	
	/**
	 * 通信核心库工程对外日志通告事件
	 * @author wulingbiao
	 */	
	public class ConnectLibLogEvent extends Event
	{
		
		public static const LOG_MESSAGE:String = "connectLibLog";
		
		public function ConnectLibLogEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
		
		/**  日志内容 **/
		public var logText:String = "";
		
	}
}