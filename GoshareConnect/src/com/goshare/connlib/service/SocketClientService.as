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
	import flash.net.Socket;
	
	[Event(name="connect", type="com.goshare.connlib.event.LocalSocketConnectEvent")]
	
	[Event(name="disconnect", type="com.goshare.connlib.event.LocalSocketConnectEvent")]
	
	[Event(name="error", type="com.goshare.connlib.event.LocalSocketConnectEvent")]
	
	[Event(name="receiveMessage", type="com.goshare.connlib.event.LocalSocketConnectEvent")]
	
	[Event(name="connectLibLog", type="com.goshare.connlib.event.ConnectLibLogEvent")]
	
	/**
	 * Socket通信管理 - 主动连接远程socket服务
	 * 
	 * 例：  机器人前端应用主动连接 - 远程控制器C1
	 * 
	 * @author wulingbiao
	 */	
	public class SocketClientService extends SocketDataProcesser
	{
		public function SocketClientService(target:IEventDispatcher=null)
		{
			super(target);
		}
		
		//--------------------------------------------------------------------------
		//
		//  Variables
		//
		//--------------------------------------------------------------------------
		/** Socket服务器类型: 0-报文头长度8；1-报文头长度16 **/
		public var serviceType:String = "0";
		
		private var serverSocket:Socket;
		
		/**
		 * Socket服务器连接状态
		 * @return 
		 */		
		public function get connected():Boolean
		{
			return serverSocket && serverSocket.connected;
		}
		
		//--------------------------------------------------------------------------
		//
		//  Methods
		//
		//--------------------------------------------------------------------------
		
		/**
		 * 连接Socket服务器
		 *  
		 * @param host 服务器地址
		 * @param port 服务器端口
		 * 
		 */		
		public function connect(host:String, port:int):void
		{
			clearSocket(serverSocket); 
			serverSocket = new Socket();
			addSocketHandler(serverSocket);
			log("发起Socket连接请求：host - " + host + "    port - " + port);
			serverSocket.connect(host, port);
		}
		
		/**
		 *	断开与Socket服务器的连接 
		 */		
		public function disconnect():void
		{
			if (serverSocket && serverSocket.connected)
				log("断开Socket连接！");
				try {
					serverSocket.close();
				} catch (e:Error) {
					trace(e.message);
				}
		}
		
		/**
		 * 添加socket事件
		 *  
		 * @param socket
		 */		
		private function addSocketHandler(socket:Socket):void
		{
			if (socket)
			{
				socket.addEventListener(Event.CONNECT, serverSocket_connectHnalder);
				socket.addEventListener(Event.CLOSE, serverSocket_closeHandler);
				socket.addEventListener(IOErrorEvent.IO_ERROR, serverSocket_ioErrorHandler);
				socket.addEventListener(SecurityErrorEvent.SECURITY_ERROR, serverSocket_securityErrorHandler);
				socket.addEventListener(ProgressEvent.SOCKET_DATA, serverSocket_dataHandler);
			}
		}
		
		/**
		 * 
		 * 移除Socket
		 * 
		 * @param socket
		 */		
		private function clearSocket(socket:Socket):void
		{
			if (socket)
			{
				socket.removeEventListener(Event.CONNECT, serverSocket_connectHnalder);
				socket.removeEventListener(Event.CLOSE, serverSocket_closeHandler);
				socket.removeEventListener(IOErrorEvent.IO_ERROR, serverSocket_ioErrorHandler);
				socket.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, serverSocket_securityErrorHandler);
				socket.removeEventListener(ProgressEvent.SOCKET_DATA, serverSocket_dataHandler);
				
				if (socket.connected) {
					socket.close();
				}
				socket = null;
			}
		}
		
		protected function serverSocket_connectHnalder(event:Event):void
		{
			log("Socket 服务器建立连接成功！");
			var mse:LocalSocketConnectEvent = new LocalSocketConnectEvent(LocalSocketConnectEvent.CONNECT);
			mse.descript = "连接成功";
			dispatchEvent(mse);
		}
		
		protected function serverSocket_closeHandler(event:Event):void
		{
			log("Socket 服务器连接断开！");
			if (serverSocket) {
				serverSocket.close();
			}
			var mse:LocalSocketConnectEvent = new LocalSocketConnectEvent(LocalSocketConnectEvent.DISCONNECT);
			mse.descript = "断开连接";
			dispatchEvent(mse);
		}
		
		protected function serverSocket_ioErrorHandler(event:IOErrorEvent):void
		{
			log("Socket 服务器通讯IO异常！" + event.text);
			serverSocket.close();
			var mse:LocalSocketConnectEvent = new LocalSocketConnectEvent(LocalSocketConnectEvent.ERROR);
			mse.descript = event.text;
			dispatchEvent(mse);
		}
		
		protected function serverSocket_securityErrorHandler(event:SecurityErrorEvent):void
		{
			log("Socket 服务器通讯安全策略异常！" + event.text);
			serverSocket.close();
			var mse:LocalSocketConnectEvent = new LocalSocketConnectEvent(LocalSocketConnectEvent.ERROR);
			mse.descript = event.text;
			dispatchEvent(mse);
		}
		
		
		protected function serverSocket_dataHandler(event:ProgressEvent):void
		{
			while (serverSocket.bytesAvailable)
			{
				serverSocket.readBytes(bufferBytes, bufferBytes.length);
			}
			
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
		override protected function receiveMessage(receiveStr:String):void
		{
			try {
				log("收到 Socket服务器 消息: " + receiveStr);
				
				var mse:LocalSocketConnectEvent = new LocalSocketConnectEvent(LocalSocketConnectEvent.RECEIVE_MESSAGE);
				mse.descript = "数据处理成功";
				mse.data = receiveStr;
				dispatchEvent(mse);
			} catch (e:Error) {
				log("解析消息包失败," + receiveStr);
			}
		}
		
		/**
		 * 向远程 clientSocket 发消息
		 */		
		public function sendMessage(message:String):void
		{
			if (!serverSocket || !serverSocket.connected)
			{
				log("当前 Socket 服务未连接, 无法发送消息！");
				var mse:LocalSocketConnectEvent = new LocalSocketConnectEvent(LocalSocketConnectEvent.ERROR);
				mse.descript = "发送失败， Socket 服务未连接";
				return;
			}
			
			log("向 Socket 服务器发送消息：" + message);
			
			if (serviceType == "0") {
				sendSocketMsgByPacket8(message, serverSocket);
			} else if (serviceType == "1"){
				sendSocketMsgByPacket16(message, serverSocket);
			}
		}
		
		/**
		 *
		 * 输出日志
		 *
		 * @param args
		 */
		protected function log(...args):void
		{
			var arg:Array = args as Array;
			if (arg.length > 0)
			{
				var ase:ConnectLibLogEvent = new ConnectLibLogEvent(ConnectLibLogEvent.LOG_MESSAGE);
				ase.logText = "[LocalSocketClientService]  " +  args.join(" ");
				dispatchEvent(ase);
			}
		}
		
	}
}