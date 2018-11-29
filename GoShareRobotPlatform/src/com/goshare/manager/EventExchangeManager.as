package com.goshare.manager
{
	import com.goshare.data.EventExchangeVO;
	import com.goshare.event.EventExchangeEvent;
	import com.goshare.util.map.HashMap;
	
	import flash.events.EventDispatcher;
	
	/**
	 * <p>事件框架-数据交换运行时类（事件派发方式: 全局广播  ）</p>
	 * @author WLB 
	 * @langversion 1.0
	 * @see flash.events.EventDispatcher EventDispatcher
	 * @example
	 * <listing>
	 * //引用实例
	 * public var dataExchanger :AppEventExchangeManager = AppEventExchangeManager.getInstance();
	 * 
	 * //注册事件
	 * dataExchanger.registerGlobalAction("EventKey","ComponentKey",component,dataExchangeFunc);
	 * 
	 * //派发事件
	 * var dataEvent:DataExchangeEvent = new DataExchangeEvent("EVENT_KEY",dataExchanger.EVENT_TYPE_BROADCAST,"ComponentKey");
	 * dataEvent.exchangeData = "exchangeData";
	 * dataExchanger.triggerGlobalAction(dataEvent);
	 * 
	 * //消息处理
	 * private function dataExchangeFunc(event:DataExchangeEvent):void {
	 *   trace(event.eventKey + "  " + event.eventFromKey + "  " + event.exchangeData);
	 * }	
	 * 
	 * //删除事件
	 * dataExchanger.unregisterGlobalAction("EventKey","ComponentKey");
	 * </listing>
	 */
	public class EventExchangeManager extends EventDispatcher
	{
		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------
		/**
		 * <p>构造函数 </p>
		 */
		public function EventExchangeManager() 
		{ 
			super();
			if ( instance != null )
			{
				throw new Error( "Only one instance should be instantiated !" );	
			}
		}
		
		//--------------------------------------------------------------------------
		//
		//  Variables
		//
		//--------------------------------------------------------------------------
		/**
		 * @private
		 * 数据交换实例
		 */
		private static var instance:EventExchangeManager = null;
		/**
		 * @private
		 * 全局组件KEY 
		 */
		private static var GLOBAL_COMP_KEY:String = "_GLOBAL_COMP_";
		/**
		 * 事件派发方式: 广播  
		 */
		public static var EVENT_TYPE_BROADCAST:String = "EventBroadCast";
		/**
		 * @private
		 * 事件哈希表: key是 eventKey, value是component list (compKey ,object)
		 */
		public var eventMap:HashMap = null;
		
		//--------------------------------------------------------------------------
		//
		//  Public methods
		//
		//--------------------------------------------------------------------------		
		/**
		 * <p>获取数据交换运行时类实例</p> 
		 * @return 静态实例
		 * 
		 */
		public static function getInstance():EventExchangeManager
		{
			if (!instance) {
				instance = new EventExchangeManager();
				instance.eventMap = new HashMap();
			}
			return instance as EventExchangeManager; 
		}
		
		/**
		 * 注册全局动作 
		 * @param actKey 动作key
		 * @param compInst 组件实例
		 * @param notifyFunc 通知函数
		 * @param nameSpace 事件空间 
		 * 
		 */
		public function registerGlobalAction(actKey:String, compInst:Object, notifyFunc:Function, nameSpace:String="", maxFailRetry:int=1):void
		{
			if(nameSpace=="")
			{
				nameSpace = GLOBAL_COMP_KEY;
			}
			
			if(actKey!=null && nameSpace!=null  && compInst!=null && notifyFunc!=null) 
			{  
				actKey = actKey.toLocaleUpperCase();
				
				var exchangeInst:EventExchangeVO = null;
				var compList:Array = eventMap.get(actKey.toLocaleUpperCase()) as Array;;
				if (compList==null) 
				{
					compList = [];
					eventMap.put(actKey, compList);
				} 
				else 
				{
					//  检查是否重复注册
					for (var i:int = 0;   i< compList.length; i++) 
					{
						exchangeInst = compList[i] as EventExchangeVO;
						if (exchangeInst && exchangeInst.isEqualObject(nameSpace, compInst)) 
						{
							exchangeInst.disposeComponent();
							exchangeInst = null;
							compList.splice(i, 1);
							break;
						}	 
					}	
				}				
				var notifyKey:String = getCompEventKey(actKey);
				exchangeInst = new EventExchangeVO( nameSpace, compInst, actKey,messageListner,notifyKey, notifyFunc,maxFailRetry);
				compList.push(exchangeInst);
			} 
			else
			{
				throw new Error("Invalid event component parameters ! ");
			}
			
		}
		
		/**
		 * 取消全局动作注册 
		 * @param actKey 动作key
		 * 
		 */
		public function unregisterGlobalAction(actKey:String, nameSpace:String=""):void
		{
			if(nameSpace=="")
			{
				nameSpace = GLOBAL_COMP_KEY;
			}
			
			actKey = actKey.toLocaleUpperCase();
			
			var compList:Array = eventMap.get(actKey) as Array;
			if (compList==null)  
			{
				return;
			}
			
			var exchangeInst:EventExchangeVO = null;
			var len:int = compList.length;
			for (var i:int = 0;  i< len; ) 
			{
				exchangeInst = compList[i] as EventExchangeVO;
				if (exchangeInst==null) 
				{
					compList.splice(i, 1);
					len = compList.length;
					continue;					
				}
				else if (exchangeInst.isEqualCompKey(nameSpace))  
				{
					exchangeInst.disposeComponent();
					exchangeInst = null;
					compList.splice(i, 1);
					len = compList.length;
					continue;
				}  
				i++;
			}
		}
		
		/**
		 * 触发全局动作 
		 * @param actKey 动作key
		 * @param data 交互数据
		 * 
		 */
		public function triggerGlobalAction(actKey:String, data:Object=null, prefix:String=""):void
		{
			if(prefix=="")
			{
				prefix = GLOBAL_COMP_KEY;
			}
			var dataEvent:EventExchangeEvent = new EventExchangeEvent(actKey, prefix, true);
			dataEvent.exchangeData = data;
			messageListner(dataEvent);
		}
		
		//--------------------------------------------------------------------------
		//
		//  Private methods
		//
		//--------------------------------------------------------------------------		
		/**
		 * @private
		 * <p>事件监听处理</p> 
		 * @param recvEvent 数据交换事件
		 * 
		 */
		private function messageListner(recvEvent:EventExchangeEvent) :void 
		{
			if (recvEvent==null || recvEvent.eventKey=="") 
			{
				return;
			}
			var eventKey:String = recvEvent.eventKey.toLocaleUpperCase();
			var compList:Array = eventMap.get(eventKey.toLocaleUpperCase()) as Array;
			if (compList==null) 
			{
				return;
			}
			recvEvent.eventKey = getCompEventKey(eventKey);
			
			var exchangeInst:EventExchangeVO = null;
			var notifyEvent:EventExchangeEvent = recvEvent.clone() as EventExchangeEvent;				
			
			var i: int = 0;
			for (i = 0;   i< compList.length; i++) 
			{
				exchangeInst = compList[i] as EventExchangeVO;
				if ( recvEvent.isNotifySelf )
				{
					if( recvEvent.eventFromKey.toLocaleUpperCase() == exchangeInst.componentKey.toLocaleUpperCase() )
					{
						exchangeInst.dispatchMessage(notifyEvent);	
					}
				}
				else if (!exchangeInst.isEqualCompKey(recvEvent.eventFromKey) )
				{
					exchangeInst.dispatchMessage(notifyEvent);	
				}
			}
			
			recvEvent = null;
			removeInvalidExchangeObject(compList);
		}
		
		/**
		 * @private
		 * <p>生成组件key</p> 
		 * @param eventKey 事件key
		 * @return 组件key
		 * 
		 */
		private function getCompEventKey(eventKey:String):String 
		{
			return "_COMP_" + eventKey;
		}
		/**
		 * @ptivate
		 * <p>通知组件过滤</p> 
		 * @param compKey 组件key
		 * @param objectList 组件对象集合
		 * @return <code>true</code>-是, <code>false</code>-否
		 * 
		 */
		private function findNotifierByKeyInList (compKey:String, objectList:Array):Boolean  
		{
			var objectKey :String = "";
			
			for (var i:int = 0;   i< objectList.length; i++) 
			{
				objectKey = objectList[i] as String;
				objectKey.toLocaleUpperCase();
				if (objectKey == compKey )
					return true;
			}			
			return false;
		}
		
		/**
		 * @private
		 * <p>根据组件key查找数据交换实例</p> 
		 * @param compKey 组件key
		 * @param objectList 组件对象集合
		 * @return 数据交换实例
		 * 
		 */
		private function findExchangeInstByKey (compKey:String, objectList:Array):EventExchangeVO  
		{
			var exchangeInst:EventExchangeVO = null;
			
			for (var i:int = 0;   i< objectList.length; i++)  
			{
				exchangeInst = objectList[i] as EventExchangeVO;
				if (exchangeInst.isEqualCompKey(compKey))
					return exchangeInst;
			}			
			return null;
		}	
		/**
		 * @private
		 * <p>移除失效的组件对象</p> 
		 * @param compList 组件对象集合
		 * 
		 */
		private function removeInvalidExchangeObject(compList:Array) :void
		{
			if (compList==null) 
			{
				return;
			}
			
			var exchangeInst:EventExchangeVO = null;
			var len:int = compList.length;
			for (var i:int = 0;  i< len; ) 
			{
				exchangeInst = compList[i] as EventExchangeVO;
				if (exchangeInst==null) 
				{
					compList.splice(i, 1);
					len = compList.length;
					continue;					
				}
				else if (exchangeInst && exchangeInst.isRequireDestroy)  
				{
					exchangeInst.disposeComponent();
					exchangeInst = null;
					compList.splice(i, 1);
					len = compList.length;
					continue;
				} 
				i ++;
			}			
		}
		
	}
}