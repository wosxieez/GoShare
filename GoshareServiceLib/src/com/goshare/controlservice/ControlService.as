package com.goshare.controlservice
{
	import com.goshare.connlib.data.SocketMessageVO;
	import com.goshare.connlib.event.ConnectLibLogEvent;
	import com.goshare.connlib.event.LocalSocketConnectEvent;
	import com.goshare.connlib.service.SocketClientService;
	import com.goshare.controlservice.event.ControlServiceEvent;
	
	import flash.events.EventDispatcher;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	public class ControlService extends EventDispatcher
	{
		private static var instance:ControlService=null;
		public static function getInstance():ControlService
		{
			if (!instance){
				instance = new ControlService();
			}
			return instance;
		}
		
		/** 本地C1控制器通信服务 **/
		private var socketClient:SocketClientService;
		/** 本地C1控制器host、端口号 **/
		private var _host:String = "127.0.0.1";
		private var _port:int = 17581;
		
		private static var runLoopTimer:Timer;
		
		public function ControlService()
		{
			socketClient = new SocketClientService();
			socketClient.serviceType = "0";
			socketClient.addEventListener(LocalSocketConnectEvent.CONNECT,  controller_connectHandler);
			socketClient.addEventListener(LocalSocketConnectEvent.DISCONNECT, controller_disconnectHandler);
			socketClient.addEventListener(LocalSocketConnectEvent.ERROR, controller_errorHandler);
			socketClient.addEventListener(LocalSocketConnectEvent.RECEIVE_MESSAGE, controller_dataHandler);
		}
		
		/**
		 * 初始化连接
		 */
		public function connect(host:String, port:int):void
		{
			// 30s检查一次本地C1的连接情况
			if (!runLoopTimer)
			{
				runLoopTimer = new Timer(30000); // 30 一次循环
				runLoopTimer.addEventListener(TimerEvent.TIMER, runLoopTimer_timerHandler);
				runLoopTimer.start();
			} else {
				runLoopTimer.reset();
				runLoopTimer.start();
			}
			
			// 当前立刻建立连接
			_host = host;
			_port = port;
			connectControlerService();
		}
		
		/**
		 * 主动断开连接
		 */
		public function disconnect():void
		{
			if (connected)
			{
				log("主动断开控制器C1的Socket服务！ ");
				if (runLoopTimer)
				{
					runLoopTimer.removeEventListener(TimerEvent.TIMER, runLoopTimer_timerHandler);
					runLoopTimer.stop();
					runLoopTimer = null;
				}
				// 断开连接
				socketClient.disconnect();
			}
		}
		
		protected function runLoopTimer_timerHandler(event:TimerEvent):void
		{
			connectControlerService();
		}
		
		/**
		 * 连接C1进程服务
		 */
		private function connectControlerService():void
		{
			if (connected) {
				return;
			}
			
			log("连接控制器C1的Socket服务: ", _host, _port);
			if (connected) {
				log("控制器C1已经连接，无需重连");
			} else {
				socketClient.connect(_host, _port);
			}
		}
		
		/**
		 * 与控制器C1SocketService连接状态
		 */
		public function get connected():Boolean
		{
			return socketClient.connected;
		}
		
		// ------------------------------------------------ 控制器C1连接成功后处理 --------------------------------------
		/**
		 * 连接控制器C1成功
		 */
		private function controller_connectHandler(event:LocalSocketConnectEvent):void
		{
			log("控制器C1连接成功!!!");
		}
		
		/**
		 * 断开控制器C1
		 */
		private function controller_disconnectHandler(event:LocalSocketConnectEvent):void
		{
			log("控制器C1断开连接!!!");
		}
		
		/**
		 * 与控制器C1通信异常
		 */
		private function controller_errorHandler(event:LocalSocketConnectEvent):void
		{
			log("控制器C1连接异常：" + event.descript);
			
			// 断开连接 - 等待下次主动重连
			socketClient.disconnect();
		}
		
		// ------------------------------------------------ Controller消息处理 --------------------------------------
		/**
		 * 收到控制器C1的信息
		 */
		private function controller_dataHandler(event:LocalSocketConnectEvent):void
		{
			log("收到控制器C1消息： " + event.data);
			
			var receiveJson:Object = JSON.parse(event.data);
			// 发来的信息缺少必须条件 - 过滤处理
			if (!receiveJson.hasOwnProperty("type") || !receiveJson.hasOwnProperty("content")) {
				log("Socket 消息缺少必须条件，忽略处理！");
				return;
			}
			
			var message:SocketMessageVO = new SocketMessageVO();
			message.from = receiveJson.from;
			message.to = receiveJson.to;
			message.type = receiveJson.type;
			message.content = receiveJson.content;
			
			var evt:ControlServiceEvent = new ControlServiceEvent(ControlServiceEvent.CONTROLLER_MESSAGE);
			evt.controllerMsg = message;
			this.dispatchEvent(evt);
		}
		
		/**
		 * 向控制器C1发送消息
		 */		
		public function sendMessage(msg:SocketMessageVO):void 
		{
			var msgStr:String = JSON.stringify(msg);
			
			if (connected) {
				log("向控制器C1发送消息： " + msgStr);
				socketClient.sendMessage(msgStr);
			} else {
				log("控制器C1未连接，消息不能发送： " + msgStr);
			}
		}
		
		/**
		 * 输出日志
		 */
		protected function log(...args):void
		{
			var arg:Array = args as Array;
			if (arg.length > 0)
			{
				var evt:ControlServiceEvent = new ControlServiceEvent(ControlServiceEvent.CONTROLLER_SERVICE_LOG);
				evt.logText = "[ControlService]  " + args.join(" ");
				this.dispatchEvent(evt);
			}
		}
		
	}
}