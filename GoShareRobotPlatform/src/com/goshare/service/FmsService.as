package com.goshare.service
{
	import com.goshare.connlib.event.ConnectLibLogEvent;
	import com.goshare.connlib.event.FmsServerEvent;
	import com.goshare.connlib.service.FmsConnectService;
	import com.goshare.event.FmsManagerEvent;
	import com.goshare.manager.AppManager;
	
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.events.TimerEvent;
	import flash.media.Camera;
	import flash.media.Microphone;
	import flash.media.VideoStreamSettings;
	import flash.net.NetStream;
	import flash.utils.Timer;
	import flash.utils.clearTimeout;
	import flash.utils.setTimeout;
	
	
	/**
	 *
	 * FMS服务器通信类
	 *
	 * @author wulingbiao
	 */
	public class FmsService extends EventDispatcher
	{
		/** 与Fms服务器连接管理对象 **/
		private var fmsConnectService:FmsConnectService = new FmsConnectService();
		
		public function FmsService(target:IEventDispatcher=null)
		{
			super(target);
			
			fmsConnectService = new FmsConnectService();
			fmsConnectService.addEventListener(FmsServerEvent.CONNECT, fms_connectHandler);
			fmsConnectService.addEventListener(FmsServerEvent.DISCONNECT, fms_disconnectHandler);
			fmsConnectService.addEventListener(FmsServerEvent.ERROR, fms_errorHandler);
			fmsConnectService.addEventListener(FmsServerEvent.DATA, fms_dataHandler);
			fmsConnectService.addEventListener(ConnectLibLogEvent.LOG_MESSAGE, connectLibLog_Handler);
		}
		
		//--------------------------------------------------------------------------
		//
		//  Get Instance
		//
		//--------------------------------------------------------------------------
		private static var inRightWay:Boolean = false;
		private static var instance:FmsService;
		
		public static function getInstance():FmsService
		{
			inRightWay = true;
			
			if (!instance) {
				instance = new FmsService();
			}
			
			return instance;
		}
		
		
		//--------------------------------------------------------------------------
		//
		//  Variables
		//
		//--------------------------------------------------------------------------
		/** fms服务地址 **/
		private var _fmsServerUrl:String;
		/** 正在连接中 **/
		public var isConnectIng:Boolean = false;
		/** 是否需要断线重连 **/
		private var needReConnectFlag:Boolean = false;
		
		private var _setTimeNum:uint = 0;
		/** 视频流传输数据为空时，延时计算器 **/
		private var fmsInitTimer:Timer = new Timer(4000,1);
		
		//--------------------------------------------------------------------------
		//
		//  Methods
		//  FMS Server
		//  FMS 服务器代码处理部分
		//--------------------------------------------------------------------------
		/**
		 * fms服务器连接状态
		 * @return
		 */
		public function get fmsConnected():Boolean
		{
			return fmsConnectService.connected;
		}
		
		/**
		 * 连接FMS服务器
		 * @param url
		 */
		public function connectFMS(url:String):void
		{
			log("主动连接FMS服务器", url);
			if (!fmsConnected && !isConnectIng) {
				isConnectIng = true;
				_fmsServerUrl = url;
				fmsConnectService.connect(url);
			} else {
				log("FMS服务已经连接，请先断开连接再尝试");
			}
		}
		
		/**
		 * 断开FMS服务器
		 */
		public function disconnectFMS(needReConnect:Boolean = false):void
		{
			if (fmsConnected)
			{
				log("断开FMS服务器连接");
				isConnectIng = false;
				needReConnectFlag = needReConnect;
				fmsConnectService.disconnect();
			}
		}
		
		/**
		 * 发布fms数据流
		 *
		 * @param name 流名称
		 * @param camera  发送的摄像头
		 * @param microphone 发送的麦克风
		 * @param type 流类型
		 * @param rePublishFlag 是否使用原有NetStream对象
		 * @param oldStream 原有的NetStream对象
		 */
		public function publish(name:String,
								camera:Camera = null,
								microphone:Microphone = null,
								videoStreamSettings:VideoStreamSettings = null,
								type:String = "live", 
								rePublishFlag:Boolean = false,  oldStream:NetStream=null):NetStream
		{
			log("发布FMS视频流", name);
			return fmsConnectService.send(name, camera, microphone, videoStreamSettings, type, rePublishFlag, oldStream);
		}
		
		/**
		 * 订阅fms视频流
		 *
		 * @param name 要接收的流名称
		 */
		public function subscribe(name:String):NetStream
		{
			log("主动订阅FMS视频流", name);
			return fmsConnectService.receive(name);
		}
		
		/**
		 * 连接FMS服务器成功的时候派发
		 */
		private function fms_connectHandler(event:FmsServerEvent):void
		{
			log("FMS服务已经连接");
			
			isConnectIng = false;
			if(needReConnectFlag){
				// 派发事件 - FMS已恢复连接
				var ame:FmsManagerEvent = new FmsManagerEvent(FmsManagerEvent.FMS_RECONNECT_EVENT);
				dispatchEvent(ame);
			}else{
				// 派发事件 - FMS正常建立连接
				var ameNormal:FmsManagerEvent = new FmsManagerEvent(FmsManagerEvent.FMS_CONNECT_EVENT);
				dispatchEvent(ameNormal);
			}
			needReConnectFlag = true;
		}
		
		/**
		 * 与FMS服务器连接断开的时候派发
		 */
		private function fms_disconnectHandler(event:FmsServerEvent):void
		{
			isConnectIng = false;
			if(needReConnectFlag){
				log("FMS连接异常断开，2s后开始自动重连")
				// 派发事件 - FMS异常断开
				var ame:FmsManagerEvent = new FmsManagerEvent(FmsManagerEvent.FMS_DISCONNECT_UNNORMALEVENT);
				dispatchEvent(ame);
				// 2秒后重新登录FMS
				if(_setTimeNum > 0){
					clearTimeout(_setTimeNum);
				}
				_setTimeNum = setTimeout(connectFMS, 2000, _fmsServerUrl);
			}else{
				log("FMS连接正常断开，不再启动重连")
				// 派发事件 - FMS正常断开
				var ameUn:FmsManagerEvent = new FmsManagerEvent(FmsManagerEvent.FMS_DISCONNECT_NORMAL_EVENT);
				dispatchEvent(ameUn);
			}
		}
		
		/**
		 * 与FMS服务器连接错误的时候派发
		 * 
		 * 异常原因清单：
		 * 		1. 发送失败，FMS服务器未连接
		 * 		2. 接收失败，FMS服务器未连接
		 * 		3. 连接失败
		 * 		4. 指定的应用程序没有找到
		 * 		5. 拒绝连接
		 * 		6. 服务器应用程序已经关闭（由于资源耗用过大等原因）或者服务器已经关闭
		 * 		7. other
		 */
		private function fms_errorHandler(event:FmsServerEvent):void
		{
			isConnectIng = false;
			
			if(needReConnectFlag){
				log("FMS连接失败(断线重连情况)，继续重连！" + event.descript);
			}else{
				log("FMS连接失败(正常情况)，继续重连！" + event.descript);
			}
			
			var de:FmsManagerEvent = new FmsManagerEvent(FmsManagerEvent.FMS_ERROR);
			de.descript = event.descript;
			dispatchEvent(de);
			
			disconnectFMS(true);
		}
		
		/**
		 * 收到FMS服务器数据的时候派发
		 */
		private function fms_dataHandler(event:FmsServerEvent):void
		{
			isConnectIng = false;
			
			var msg:String = event.descript;
			log("收到FMS服务消息：" + msg);
			
//			var de:AgentManagerEvent = new AgentManagerEvent(AgentManagerEvent.FMS_MESSAGE);
//			de.descript = msg;
//			dispatchEvent(de);
			
			if (!fmsInitTimer.hasEventListener(TimerEvent.TIMER_COMPLETE)) {
				fmsInitTimer.addEventListener(TimerEvent.TIMER_COMPLETE, closeFMSTime);
			}
			if (msg == "视频流为空") {
				// 当FMS连接未断开，但通讯数据为空时，则重新建立连接
				fmsInitTimer.reset();
				disconnectFMS(true);
			}else if(msg == "流已暂停"){
				fmsInitTimer.reset();
				fmsInitTimer.start();
			}else if(msg == "流已恢复"){
				fmsInitTimer.reset();
			}
		}
		
		/** 
		 * 视频流传输停顿超时处理 (断线重连)
		 **/
		protected function closeFMSTime(e:TimerEvent):void
		{
			fmsInitTimer.reset();
			disconnectFMS(true);
		}
		
		
		private function connectLibLog_Handler(event:ConnectLibLogEvent):void
		{
			log(event.logText);
		}
		
		/**
		 * 输出日志
		 *
		 * @param args
		 */
		protected function log(...args):void
		{
			var arg:Array = args as Array;
			if (arg.length > 0)
			{
				AppManager.log("[FmsService] " + args.join(" "));
			}
		}
		
	}
}