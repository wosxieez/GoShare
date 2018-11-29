package com.goshare.event
{
	import flash.events.Event;
	
	public class TeachingScheduleEvent extends Event
	{
		/** 课程表控制事件 - 上课时间到 **/
		public static const TIME_TABLE_CLASS_BEGIN_EVENT:String = "timeTableClassBeginEvent";
		/** 课程表控制事件 - 下课时间到 **/
		public static const TIME_TABLE_CLASS_END_EVENT:String = "timeTableClassEndEvent";
		/** 课程表控制事件 - 课程表已完毕，进入睡眠 **/
		public static const TIME_TABLE_COMPLETE_EVENT:String = "timeTableCompleteEvent";
		
		public function TeachingScheduleEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
		
		/** 新切换的场景内信息 **/
		public var currSceneInfo:Object;
		
	}
}