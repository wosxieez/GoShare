package com.goshare.event
{
	import flash.events.Event;
	
	/**
	 * <p>事件框架-数据交换事件</p>
	 */
	public class EventExchangeEvent extends Event
	{
		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------
		/**
		 * <p>构造函数</p> 
		 * @param key 事件key
		 * @param compKey 组件key
		 * @param notifySelf 是否通知组件本身
		 * @param bubbles 事件是否为冒泡事件
		 * @param cancelable 是否可以阻止与事件相关联的行为
		 * 
		 */
		public function EventExchangeEvent(key:String, compKey:String, notifySelf:Boolean=false,
										  bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(key, bubbles, cancelable);
			
			if (key==null || key.length<=0)
			{
				throw new Error("Invalid dataExchangeEvent parameters !");
			}
			this.eventKey = key.toLocaleUpperCase();
			this.eventFromKey = compKey;
			this.isNotifySelf = notifySelf;
		}
		
		//--------------------------------------------------------------------------
		//
		//  Override methods
		//
		//--------------------------------------------------------------------------		
		override public  function clone():Event 
		{
			var notifyEvent:EventExchangeEvent = new EventExchangeEvent(eventKey, eventFromKey,bubbles, cancelable);
			notifyEvent.exchangeData = this._exchangeData;
			return notifyEvent;
		}		
		//--------------------------------------------------------------------------
		//
		//  Properties
		//
		//--------------------------------------------------------------------------		
		/** 事件key */
		public var eventKey:String = "ON_EXCHANGE_EVENT";
		/** 事件源key */
		public var eventFromKey:String = "";
		/** 是否通知组件本身 */
		public var isNotifySelf:Boolean = false;
		
		//----------------------------------
		//  exchangeData
		//----------------------------------	
		/**
		 * @private
		 * 交换数据 
		 */
		private var _exchangeData :Object = null;	
		/**
		 * 交换数据 
		 * @return 
		 * 
		 */
		public function get exchangeData():Object
		{
			return _exchangeData;
		}
		/**
		 * @private 
		 * @param value
		 * 
		 */
		public function set exchangeData(value:Object):void
		{
			_exchangeData = value;
		}
	}
}

