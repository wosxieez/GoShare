package com.goshare.connlib.service
{
	import com.goshare.connlib.event.ConnectLibLogEvent;
	import com.goshare.connlib.event.LocalSocketConnectEvent;
	import com.goshare.connlib.service.base.SocketDataProcesser;
	
	import flash.events.Event;
	import flash.events.IEventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.events.ServerSocketConnectEvent;
	import flash.events.TimerEvent;
	import flash.net.ServerSocket;
	import flash.net.Socket;
	import flash.utils.Timer;
	
	[Event(name="connect", type="com.goshare.connlib.event.LocalSocketConnectEvent")]
	
	[Event(name="disconnect", type="com.goshare.connlib.event.LocalSocketConnectEvent")]
	
	[Event(name="error", type="com.goshare.connlib.event.LocalSocketConnectEvent")]
	
	[Event(name="receiveMessage", type="com.goshare.connlib.event.LocalSocketConnectEvent")]
	
	[Event(name="connectLibLog", type="com.goshare.connlib.event.ConnectLibLogEvent")]
	
	/**
	 * 本地Socket服务器 - 被动等待远程端socket链接 (仅保留一个客户端链接)
	 * 
	 * 例：机器人远程控制器 - 等待机器人前端应用的主动连接
	 * 
	 * @author wulingbiao
	 */	
	public class LocalSocketServerService extends SocketDataProcesser
	{
		public function LocalSocketServerService(target:IEventDispatcher=null)
		{
			super(target);
		}
		
		
		//--------------------------------------------------------------------------
		//
		//  Get Instance
		//
		//--------------------------------------------------------------------------
		
		//--------------------------------------------------------------------------
		//
		//  Variables
		//
		//--------------------------------------------------------------------------
		/** Socket服务器类型: 0-报文头长度8；1-报文头长度16 **/
		public var serviceType:String = "0";
		/** 安全策略监听端口 **/
		public var policePort:int = 12015;
		/** 服务监听端口 **/
		public var serverPort:int = 12016;
		
		//--------------------------------------------------------------------------
		//
		//  Methods
		//
		//--------------------------------------------------------------------------
		private var checkTimer:Timer;
		
		/**
		 * 启动本地Socket相关服务
		 */
		public function init():void
		{
			initListenPolicySocket();
			initListenSocket();
			
			// 30s检查一次服务情况
			checkTimer = new Timer(30000);
			checkTimer.addEventListener(TimerEvent.TIMER, checkTimer_timerHandler);
			checkTimer.start();
		}
		
		/**
		 * 销毁本地Socket相关服务
		 */
		public function dispose():void
		{
			if (checkTimer) {
				checkTimer.removeEventListener(TimerEvent.TIMER, checkTimer_timerHandler);
				checkTimer.stop();
				checkTimer = null;
			}
			
			disposeListenPolicySocket();
			disposeListenSocket();
			disposeClientSocket();
		}
		
		protected function checkTimer_timerHandler(event:TimerEvent):void
		{
			if (!listenPolicySocket || !listenPolicySocket.listening)
			{
				log("策略服务异常,开始重启");
				initListenPolicySocket();
			}
			
			if (!listenSocket || !listenSocket.listening)
			{
				log("服务异常,开始重启");
				initListenSocket();
			}
		}
		
		//--------------------------------------------------------------------------
		//
		//  本地Socket策略服务相关
		//
		//--------------------------------------------------------------------------
		private var policyFile:String =
			'<cross-domain-policy>' +
			'<site-control permitted-cross-domain-policies="master-only"/>' +
			'<allow-access-from domain="*" to-ports="' + serverPort + '"/>'
			'</cross-domain-policy> ';
		
		private var listenPolicySocket:ServerSocket; // 本地Socket策略服务
		private var policySocket:Socket;
		
		private function initListenPolicySocket():void
		{
			try
			{
				// 开启策略服务
				listenPolicySocket = new ServerSocket();
				listenPolicySocket.addEventListener(ServerSocketConnectEvent.CONNECT, listenPolicySocket_connectHandler);
				listenPolicySocket.bind(policePort);
				listenPolicySocket.listen();
				log("启动策略服务成功");
			} 
			catch(error:Error) 
			{
				log("启动策略服务失败," + error.message);
			}
		}
		
		
		private function disposeListenPolicySocket():void
		{
			if (listenPolicySocket)
			{
				try
				{
					listenPolicySocket.removeEventListener(ServerSocketConnectEvent.CONNECT, listenPolicySocket_connectHandler);
					listenPolicySocket.close();
					listenPolicySocket = null;
					log("关闭策略服务成功");
				} 
				catch(error:Error) 
				{
					log("关闭策略服务失败," + error.message);
				}
			}
		}
		
		
		protected function listenPolicySocket_connectHandler(event:ServerSocketConnectEvent):void
		{
			log("收到策略请求");
			policySocket = event.socket;
			policySocket.addEventListener(ProgressEvent.SOCKET_DATA, policySocket_dataHandler);
		}
		
		protected function policySocket_dataHandler(event:ProgressEvent):void
		{
			var data:String;
			while (policySocket.bytesAvailable)
			{
				data= policySocket.readUTFBytes(policySocket.bytesAvailable);
			}
			
			if (data == "<policy-file-request/>")
			{
				log("回发策略数据")
				policySocket.writeUTFBytes(policyFile);
				policySocket.flush();
				policySocket.close();
			}
		}
		
		//--------------------------------------------------------------------------
		//
		//  本地Socket服务相关
		//
		//--------------------------------------------------------------------------
		private var listenSocket:ServerSocket; // 本地Socket服务
		
		private function initListenSocket():void
		{
			try
			{
				listenSocket = new ServerSocket();
				listenSocket.addEventListener(ServerSocketConnectEvent.CONNECT, listenSocket_connectHandler);
				listenSocket.addEventListener(Event.CLOSE, listenSocket_closeHandler);
				listenSocket.bind(serverPort);
				listenSocket.listen();
				log("启动Socket服务成功");
			} 
			catch(error:Error) 
			{
				log("启动Socket服务失败," + error.message);
			}
		}
		
		private function disposeListenSocket():void
		{
			if (listenSocket)
			{
				try
				{
					listenSocket.removeEventListener(ServerSocketConnectEvent.CONNECT, listenSocket_connectHandler);
					listenSocket.removeEventListener(Event.CLOSE, listenSocket_closeHandler);
					listenSocket.close();
					listenSocket = null;
					log("关闭Socket服务成功");
				} 
				catch(error:Error) 
				{
					log("关闭Socket服务失败," + error.message);
				}
			}
		}
		
		
		protected function listenSocket_connectHandler(event:ServerSocketConnectEvent):void
		{
			log("发现新的ClientSocket对象连入, 销毁当前ClientSockett对象！")
			disposeClientSocket();
			clientSocket = event.socket;
			initClientSocket();
			
			var ce:LocalSocketConnectEvent = new LocalSocketConnectEvent(LocalSocketConnectEvent.CONNECT);
			dispatchEvent(ce);
		}
		
		
		protected function listenSocket_closeHandler(event:Event):void
		{
			disposeListenSocket();
		}
		
		//--------------------------------------------------------------------------
		//
		//  远程Socket对象相关
		//
		//--------------------------------------------------------------------------
		private var clientSocket:Socket; // 远程socket对象
		
		private function initClientSocket():void
		{
			if (clientSocket) {
				clientSocket.addEventListener(Event.CLOSE, clientSocket_closeHandler);
				clientSocket.addEventListener(ProgressEvent.SOCKET_DATA, clientSocket_dataHandler);
				clientSocket.addEventListener(IOErrorEvent.IO_ERROR, clientSocket_ioErrorHandler);
				clientSocket.addEventListener(SecurityErrorEvent.SECURITY_ERROR, clientSocket_securityErrorHandler);
			}
		}
		
		private function disposeClientSocket():void
		{
			if (clientSocket)
			{
				try
				{
					clientSocket.removeEventListener(Event.CLOSE, clientSocket_closeHandler);
					clientSocket.removeEventListener(ProgressEvent.SOCKET_DATA, clientSocket_dataHandler);
					clientSocket.removeEventListener(IOErrorEvent.IO_ERROR, clientSocket_ioErrorHandler);
					clientSocket.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, clientSocket_securityErrorHandler);
					clientSocket.close();
					clientSocket = null;
					log("释放ClientSocket成功");
				} 
				catch(error:Error) 
				{
					log("释放ClientSocket失败: " + error.message);
				}
			}
		}
		
		protected function clientSocket_securityErrorHandler(event:SecurityErrorEvent):void
		{
			log("ClientSocket 通信安全策略异常！" + event.text);
			var ce:LocalSocketConnectEvent = new LocalSocketConnectEvent(LocalSocketConnectEvent.ERROR);
			ce.descript = event.text;
			dispatchEvent(ce);
		}
		
		protected function clientSocket_ioErrorHandler(event:IOErrorEvent):void
		{
			log("ClientSocket IO错误：" + event.text);
			
			var ce:LocalSocketConnectEvent = new LocalSocketConnectEvent(LocalSocketConnectEvent.ERROR);
			ce.descript = event.text;
			dispatchEvent(ce);
		}
		
		protected function clientSocket_closeHandler(event:Event):void
		{
			log("ClientSocket 关闭！");
			
			var ce:LocalSocketConnectEvent = new LocalSocketConnectEvent(LocalSocketConnectEvent.DISCONNECT);
			dispatchEvent(ce);
			log("当前ClientSocket已断开");
			
			disposeClientSocket();
		}
		
		protected function clientSocket_dataHandler(event:ProgressEvent):void
		{
			while (clientSocket.bytesAvailable)
			{
				clientSocket.readBytes(bufferBytes, bufferBytes.length);
			}
			// 开始进行socket消息包解析处理 -- 解析完毕，触发receiveMessage方法
			if (serviceType == "0") {
				processSocketPacket8();
			} else if (serviceType == "1") {
				processSocketPacket16();
			}
		}
		
		//--------------------------------------------------------------------------
		//
		//   远程Socket对象相关 ---- Socket消息包处理部分
		//
		//--------------------------------------------------------------------------
		/**
		 * 收到远程 clientSocket 发来的信息
		 */
		override protected function receiveMessage(messageString:String):void
		{
			try
			{
				log("收到 Socket客户端对象发来消息: " + messageString);
				
				var ce:LocalSocketConnectEvent = new LocalSocketConnectEvent(LocalSocketConnectEvent.RECEIVE_MESSAGE);
				ce.data = messageString;
				ce.descript = "接收消息";
				dispatchEvent(ce);
			} 
			catch(error:Error)
			{
				log("ClientSocket信息数据解析异常：" + messageString);
			}
		}
		
		/**
		 * 向远程 clientSocket 发消息
		 * @param message 发送的消息
		 * 
		 * @return Boolean true-发送完毕；false-发送失败(ClientSocket 对象已断开)
		 */		
		public function sendMessage(message:String):Boolean
		{
			if (!clientSocket || !clientSocket.connected)
			{
				log("当前 ClientSocket 对象已断开, 无法发送消息！");
				return false;
			}
			
			log("向当前 ClientSocket 客户端对象发发送消息: " + message);
			
			if (serviceType == "0") {
				sendSocketMsgByPacket8(message, clientSocket);
			} else if (serviceType == "1"){
				sendSocketMsgByPacket16(message, clientSocket);
			}
			return true;
		}
		
		//--------------------------------------------------------------------------
		//
		//  日志输出
		//
		//--------------------------------------------------------------------------
		
		private function log(...args):void
		{
			var arg:Array = args as Array;
			if (arg.length > 0)
			{
				arg[0] = "[LocalSocketServerService]  " + arg[0];
				var ce:ConnectLibLogEvent = new ConnectLibLogEvent(ConnectLibLogEvent.LOG_MESSAGE);
				ce.logText = args.join(" ");
				dispatchEvent(ce);
			}
		}
		
	}
}