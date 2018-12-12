package com.goshare.manager
{
	import com.goshare.util.CloneUtil;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.Socket;
	import flash.utils.ByteArray;
	
	public class LeapMotionManager extends EventDispatcher
	{
		//--------------------------------------------------------------------------
		//
		//  Variables
		//
		//--------------------------------------------------------------------------
		private var serverSocket:Socket;
		protected var bufferBytes:ByteArray = new ByteArray();   // 缓冲区字节
		/** 当前正在发起连接中 **/
		private var connectIng:Boolean = false;
		
		public function get connected():Boolean
		{
			return  serverSocket && serverSocket.connected;
		}
		
		//--------------------------------------------------------------------------
		//
		//  Methods
		//
		//--------------------------------------------------------------------------
		private static var instance:LeapMotionManager=null;
		public static function getInstance():LeapMotionManager
		{
			if (!instance){
				instance = new LeapMotionManager();
			}
			return instance;
		}
		
		public function LeapMotionManager(target:IEventDispatcher=null)
		{
			super(target);
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
		
		
		/**
		 * 连接Leap进程
		 * @param host Leap服务器主机
		 * @param port Leap服务器端口
		 */
		public function connectLeap(host:String, port:int):void
		{
			if (connectIng) {
				log("已在尝试连接Leap平台，不处理本次连接请求！ ");
			} else {
				if (connected) {
					log("Leap平台已经连接，无需重连");
				} else {
					log("连接Leap平台Socket服务: ", host, port);
					connectIng = true;
					
					clearSocket(serverSocket); 
					serverSocket = new Socket();
					addSocketHandler(serverSocket);
					serverSocket.connect(host, port);
				}
			}
		}
		
		/**
		 * 断开Leap进程连接
		 */
		public function disconnectLeap():void
		{
			if (connected)
			{
				log("主动断开Leap平台Socket服务！ ");
				connectIng = false;
				closeHandAction();
				if (serverSocket && serverSocket.connected) {
					log("断开Socket连接！");
					try {
						serverSocket.close();
					} catch (e:Error) {
						trace(e.message);
					}
				}
			}
		}
		
		// ------------------------------------------------ Leap连接成功后处理 --------------------------------------
		/**
		 * 连接Leap服务器成功
		 */
		protected function serverSocket_connectHnalder(event:Event):void
		{
			log("Leap Socket 服务器建立连接成功！");
			
			// 开启手势检测
			openHandAction();
		}
		
		/**
		 * Leap进程断开
		 */
		protected function serverSocket_closeHandler(event:Event):void
		{
			log("Leap Socket 服务器连接断开！");
			if (serverSocket) {
				serverSocket.close();
			}
			connectIng = false;
		}
		
		protected function serverSocket_ioErrorHandler(event:IOErrorEvent):void
		{
			log("Leap Socket 服务器通讯IO异常！" + event.text);
			connectIng = false;
			disconnectLeap();
		}
		
		protected function serverSocket_securityErrorHandler(event:SecurityErrorEvent):void
		{
			log("Leap Socket 服务器通讯安全策略异常！" + event.text);
			connectIng = false;
			disconnectLeap();
		}
		
		
		protected function serverSocket_dataHandler(event:ProgressEvent):void
		{
			while (serverSocket.bytesAvailable)
			{
				serverSocket.readBytes(bufferBytes, bufferBytes.length);
			}
			
			var packetBytes:ByteArray = new ByteArray();
			bufferBytes.readBytes(packetBytes, 0);
			var message:String = packetBytes.readUTFBytes(packetBytes.bytesAvailable);
			receiveMessage(message);
		}
		
		/**
		 * 收到Leap进程发送信息
		 */
		private function receiveMessage(message:String):void
		{
			var tempObj:Object = JSON.parse(message);
			 var leapData:Array =tempObj as Array;
//			 log("收到Leap进程消息： " + leapData);
			 if (leapData.length > 0) {
				 for each(var item:Object in leapData) {
					 if (item["hand"] == "left") {
						 // 这是左手
						 Scratch.app.runtime.leftHandInfo = CloneUtil.clone(item);
						 if (leapData.length == 1) {
							 // 无右手
							 Scratch.app.runtime.rightHandInfo = null;
						 }
						 trace("----------------------左手动作：" + item["grab"] + "，当前位置：x-" + item["X"] + "  y-" + item["Z"] + "   z-" + item["Y"]);
					 }
					 if (item["hand"] == "right") {
						 // 这是右手
						 Scratch.app.runtime.rightHandInfo = CloneUtil.clone(item);
						 if (leapData.length == 1) {
							 // 无左手
							 Scratch.app.runtime.leftHandInfo = null;
						 }
						 trace("++++++++++++++右手动作：" + item["grab"] + "，当前位置：x-" + item["X"] + "  y-" + item["Z"] + "   z-" + item["Y"]);
					 }
				 }
			 } else {
				  trace("没手了~！~~~");
				   Scratch.app.runtime.leftHandInfo = null;
				   Scratch.app.runtime.rightHandInfo = null;
			 }
		}
		
		/**
		 * 向Leap进程发送消息
		 * @param message 要发送的消息
		 */
		public function sendMessage(message:String):void
		{
			if (!connected)
			{
				log("向Leap Socket进程发送消息时，Leap未连接，发送消息失败！");
				return;
			}
			log("向Leap Socket进程发送消息： " + message);
			
			var messageBytes:ByteArray = new ByteArray();
			messageBytes.writeUTFBytes(message);
			serverSocket.writeBytes(messageBytes);
			serverSocket.flush();
		}
		
		// ----------------------------------- 具体的服务接口 --------------------------------
		/**
		 * 打开手势监测
		 */
		public function openHandAction():void
		{
			sendMessage("HandInfo On");
		}
		
		/**
		 * 关闭手势监测
		 */
		public function closeHandAction():void
		{
			sendMessage("HandInfo Off");
		}
		
		/**
		 * 输出日志
		 */
		protected function log(...args):void
		{
			var arg:Array = args as Array;
			if (arg.length > 0)
			{
//				var evt:GpipServerEvent = new GpipServerEvent(GpipServerEvent.GPIP_SERVER_LOG);
//				evt.logText = "[GpipServer] " + args.join(" ");
//				this.dispatchEvent(evt);
				trace("[LeapMotionManager] " + args.join(" "));
			}
		}
		
		
		
	}
}