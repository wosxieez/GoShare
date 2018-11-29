package com.goshare.data
{
	
	import com.goshare.event.EventExchangeEvent;
	import com.goshare.manager.AppManager;
	
	import flash.events.EventDispatcher;
	
	/**
	 * <p>事件框架-数据交换对象</p> 
	 * @author Logos
	 * @langversion 1.0
	 */
	public class EventExchangeVO
	{
		//--------------------------------------------------------------------------
		//
		//  Variables
		//
		//--------------------------------------------------------------------------
		/**
		 * 组件唯一标示
		 */
		public  var componentKey:String ;
		/**
		 * 通知对象组件  - 事件
		 */
		public  var componentInst: EventDispatcher;
		/**
		 * 通知对象组件 
		 */
		public  var componentInst_: Object;		
		/**
		 * 接收组件事件key 
		 */
		public  var recvCompEventKey:String;
		/**
		 * 接收事件句柄 
		 */
		public  var recvEventHandler:Function = null;
		/**
		 * 通知组件事件key 
		 */
		public  var notifyCompEventKey:String;
		/**
		 * 通知事件句柄
		 */
		public  var notifyEventHandler:Function = null;
		/**
		 * 是否销毁对象 
		 */
		public  var isRequireDestroy:Boolean = false; 
		/**
		 * 消息派发失败数 
		 */
		private var dispatchErrCount:int = 0;
		/**
		 * 消息派发失败, 允许新的消息最大派发次数 
		 */
		private var maxFailRetryCount:int= 1;
		/**
		 * 派发消息数 
		 */
		private var notifyCount:int = 0;
		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------
		/**
		 * <p>构造函数</p> 
		 * @param compKey 组件唯一标识 - 事件空间
		 * @param instance 组件实例
		 * @param eventKey 事件key
		 * @param eventHandler 接收事件句柄 
		 * @param notifyKey 通知组件事件key
		 * @param notifyFunc 通知事件句柄
		 * @param maxFailRetry 最大重发次数
		 * 
		 */
		public function EventExchangeVO(compKey:String,instance:Object, 
										eventKey:String, eventHandler:Function, 
										notifyKey:String, notifyFunc:Function,maxFailRetry:int) 
		{ 
			this.componentKey = compKey==null?"":compKey.toLocaleUpperCase();
			this.componentInst_ = instance;
			this.componentInst = instance as EventDispatcher;
			
			this.recvCompEventKey = eventKey==null?"":eventKey.toLocaleUpperCase();
			this.recvEventHandler = eventHandler;
			this.notifyCompEventKey = notifyKey==null?"":notifyKey.toLocaleUpperCase();
			this.notifyEventHandler = notifyFunc;
			
			this.maxFailRetryCount = maxFailRetry;
			
			initComponent();
		}
		
		/**
		 * <p>初始化对象</p> 
		 * 
		 */
		public function initComponent():void 
		{
			if (recvCompEventKey!=null && recvCompEventKey.length>0 && componentInst !=null)
			{
				componentInst.addEventListener(recvCompEventKey, recvEventHandler, false,0,true);
			}
			if (notifyCompEventKey!=null && notifyCompEventKey.length>0 && componentInst !=null)
			{
				componentInst.addEventListener(notifyCompEventKey, notifyEventHandler, false,0,true);
			}
		}	
		
		/**
		 * <p>销毁组件实例</p> 
		 */
		public function disposeComponent():void 
		{
			if (recvCompEventKey!=null && recvCompEventKey.length>0 && componentInst !=null)
			{
				componentInst.removeEventListener(recvCompEventKey, recvEventHandler);
			}
			if (notifyCompEventKey!=null && notifyCompEventKey.length>0 && componentInst !=null)
			{
				componentInst.removeEventListener(notifyCompEventKey, notifyEventHandler);
			}
			recvEventHandler = null;
			notifyEventHandler = null;
			componentInst = null;
		}
		
		/**
		 * <p>派发消息</p> 
		 * @param notifyEvent 通知事件
		 * 
		 */
		public function dispatchMessage(notifyEvent:EventExchangeEvent):void 
		{
			try 
			{
				if (componentInst == null) 
				{
					var parameters:Array = new Array();
					parameters.push(notifyEvent);
					componentInst_.callLater(this.notifyEventHandler, parameters);	
					notifyCount++;
				}
				else if ( componentInst.hasEventListener(notifyEvent.eventKey)) 
				{
					componentInst.dispatchEvent(notifyEvent);
					notifyCount++;					
				} 
				else
				{
					isRequireDestroy = true;
				}
			}
			catch( e:Error) 
			{
				dispatchErrCount++;
				if (dispatchErrCount>= maxFailRetryCount )
				{
					isRequireDestroy = true;
				}
				AppManager.logError("Invalid notify Object [" + this.toString() + "] , Error : " + e.toString());
			}
			finally 
			{
			}
		}
		
		
		/**
		 * <p>是否当前组件 </p>
		 * @param compKey 组件key
		 * @param compInst 组件实例
		 * @return <code>true</code>-是, <code>false</code>-否
		 * 
		 */
		public function isEqualObject(compKey:String,compInst:Object):Boolean 
		{
			if (compKey)
			{
				compKey = compKey.toUpperCase();
			}
			return compKey==componentKey && compInst === componentInst
		}
		
		/**
		 * <p>是否当前组件Key </p>
		 * @param compKey 组件key
		 * @return <code>true</code>-是, <code>false</code>-否
		 * 
		 */
		public function isEqualCompKey(compKey:String):Boolean 
		{
			if (compKey)
			{
				compKey = compKey.toUpperCase();
			}
			return (compKey==componentKey)?true:false;
		}
		
		/**
		 * <p>输出对象</p> 
		 * @return 打印字符串
		 * 
		 */
		public function toString():String 
		{
			return   " ComponentKey =" + componentKey 
				   + ", RecvEventKey =" + recvCompEventKey 
				   + ", NotifyEventKey =" + notifyCompEventKey
			       + ", Notify Count =" + notifyCount;
		}
	}
}