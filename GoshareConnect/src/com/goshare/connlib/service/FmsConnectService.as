package com.goshare.connlib.service
{
	import com.goshare.connlib.event.ConnectLibLogEvent;
	import com.goshare.connlib.event.FmsServerEvent;
	
	import flash.events.AsyncErrorEvent;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.NetStatusEvent;
	import flash.events.SecurityErrorEvent;
	import flash.media.Camera;
	import flash.media.Microphone;
	import flash.media.VideoStreamSettings;
	import flash.net.NetConnection;
	import flash.net.NetStream;
	
	[Event(name="fmsServerConnect", type="com.goshare.connlib.event.FmsServerEvent")]

	[Event(name="fmsServerDisconnect", type="com.goshare.connlib.event.FmsServerEvent")]
	
	[Event(name="fmsServerError", type="com.goshare.connlib.event.FmsServerEvent")]
	
	[Event(name="fmsServerData", type="com.goshare.connlib.event.FmsServerEvent")]
	
	/**
	 *
	 * FMS服务器 连接类
	 *  
	 * @author coco
	 * 
	 */	
	public class FmsConnectService extends EventDispatcher
	{
		
		public function FmsConnectService()
		{
		}
		
		//--------------------------------------------------------------------------
		//
		//  Variables
		//
		//--------------------------------------------------------------------------
		
		private var netConnection:NetConnection;
		
		/**
		 * FMS服务器连接状态
		 * @return 
		 */		
		public function get connected():Boolean
		{
			return netConnection && netConnection.connected;
		}
		
		//--------------------------------------------------------------------------
		//
		//  Methods
		//
		//--------------------------------------------------------------------------
		
		/**
		 * 连接FMS服务器
		 *  
		 * @param url 视频流服务地址
		 * 
		 */		
		public function connect(url:String):void
		{
			clearConnection(netConnection); 
			netConnection = new NetConnection();
			netConnection.client = new FMSClient("netConnection");
			addConnectionHandler(netConnection);
			netConnection.connect(url);
		}
		
		/**
		 *	断开与FMS服务器的连接 
		 */		
		public function disconnect():void
		{
			if (netConnection && netConnection.connected)
				netConnection.close();
		}
		
		/**
		 * 
		 * 发布视频或音频
		 * 
		 * @param name 流名称
		 * @param camera 使用的摄像头对象
		 * @param microphone 使用的麦克风对象
		 * @param videoStreamSettings 音视频配置
		 * @param type 类型
		 * @param rePublishFlag 是否使用原有NetStream对象
		 * @param oldStream 原有的NetStream对象
		 */		
		public function send(name:String, 
							 camera:Camera = null, 
							 microphone:Microphone = null,
							 videoStreamSettings:VideoStreamSettings = null,
							 type:String = "live",
							 rePublishFlag:Boolean = false, oldStream:NetStream=null):NetStream
		{
			if (!netConnection || !netConnection.connected)
			{
				var fse:FmsServerEvent;
				fse = new FmsServerEvent(FmsServerEvent.ERROR)
				fse.descript = "发布失败，FMS服务器未连接！";
				dispatchEvent(fse);
				return null;
			}
			
			var outstream:NetStream = oldStream;
			if (rePublishFlag) {
				if (outstream == null) {
					outstream = new NetStream(netConnection);
					outstream.addEventListener(NetStatusEvent.NET_STATUS, connection_netStatusHandler);
				}
			} else {
				outstream = new NetStream(netConnection);
				outstream.addEventListener(NetStatusEvent.NET_STATUS, connection_netStatusHandler);
			}
			if (camera){
				outstream.attachCamera(camera);
			}
			if (microphone){
				outstream.attachAudio(microphone);
			}
			if (videoStreamSettings){
				outstream.videoStreamSettings = videoStreamSettings;
			}
			outstream.client = new FMSClient("outstream " + name);
			outstream.publish(name, type);
			return outstream;
		}
		
		/**
		 * 订阅指定名称的流
		 * 
		 * @param name
		 * @return 
		 */		
		public function receive(name:String):NetStream
		{
			if (!netConnection || !netConnection.connected)
			{
				var fse:FmsServerEvent;
				fse = new FmsServerEvent(FmsServerEvent.ERROR)
				fse.descript = "订阅失败，当前FMS服务器未连接！";
				dispatchEvent(fse);
				return null;
			}
			
			var instream:NetStream = new NetStream(netConnection);
			instream.client = new FMSClient("instream " + name);
			instream.play(name);
			
			return instream;
		}
		
		/**
		 *
		 * 添加connection事件
		 *  
		 * @param connection
		 * 
		 */		
		private function addConnectionHandler(connection:NetConnection):void
		{
			if (connection)
			{
				connection.addEventListener(NetStatusEvent.NET_STATUS, connection_netStatusHandler);
				connection.addEventListener(AsyncErrorEvent.ASYNC_ERROR,connection_asyncErrorHandler);
				connection.addEventListener(IOErrorEvent.IO_ERROR, connection_ioErrorHandler);
				connection.addEventListener(SecurityErrorEvent.SECURITY_ERROR, connection_netSecurityErrorHandler);
			}
		}
		
		/**
		 * 
		 * 移除Connection
		 *  
		 * @param connection
		 * 
		 */		
		private function clearConnection(connection:NetConnection):void
		{
			if (connection)
			{
				connection.removeEventListener(NetStatusEvent.NET_STATUS, connection_netStatusHandler);
				connection.removeEventListener(AsyncErrorEvent.ASYNC_ERROR,connection_asyncErrorHandler);
				connection.removeEventListener(IOErrorEvent.IO_ERROR, connection_ioErrorHandler);
				connection.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, connection_netSecurityErrorHandler);
				
				if (connection.connected)
					connection.close();
				
				connection = null;
			}
		}
		
		protected function connection_netStatusHandler(event:NetStatusEvent):void
		{
			var fse:FmsServerEvent;
			log("[FmsConnectService] 服务通信消息：" + event.info.code);
			switch(event.info.code)
			{
				case "NetConnection.Connect.Success":
					fse = new FmsServerEvent(FmsServerEvent.CONNECT);
					fse.descript = "连接成功";
					break;
				case "NetConnection.Connect.Rejected":
					fse = new FmsServerEvent(FmsServerEvent.ERROR);
					fse.descript = "拒绝连接";
					break;
				case "NetConnection.Connect.InvalidApp":
					fse = new FmsServerEvent(FmsServerEvent.ERROR);
					fse.descript = "指定的应用程序没有找到";
					break;
				case "NetConnection.Connect.Failed":
					fse = new FmsServerEvent(FmsServerEvent.ERROR);
					fse.descript = "连接失败";
					break;
				case "NetConnection.Connect.AppShutDown":
					fse = new FmsServerEvent(FmsServerEvent.ERROR);
					fse.descript = "服务器应用程序已经关闭（由于资源耗用过大等原因）或者服务器已经关闭";
					break;
				case "NetConnection.Connect.Closed":
					fse = new FmsServerEvent(FmsServerEvent.DISCONNECT);
					fse.descript = "连接断开";
					break;
				case "NetStream.Play.Stop":
					fse = new FmsServerEvent(FmsServerEvent.DATA);
					fse.descript = "视频流播放停止";
					break;
				case "NetStream.Buffer.Empty":
					fse = new FmsServerEvent(FmsServerEvent.DATA);
					fse.descript = "视频流为空";
					break;
				case "NetStream.Pause.Notify":
					fse = new FmsServerEvent(FmsServerEvent.DATA);
					fse.descript = "流已暂停";
					break;
				case "NetStream.Unpause.Notify":
					fse = new FmsServerEvent(FmsServerEvent.DATA);
					fse.descript = "流已恢复";
					break;
				default :  
				{
					fse = new FmsServerEvent(FmsServerEvent.DATA)
					fse.descript = event.info.code;
					break;
				}
			}
			
			dispatchEvent(fse);
		}
		
		protected function connection_netSecurityErrorHandler(event:SecurityErrorEvent):void
		{
			log("[FmsConnectService] 网络安全错误：" + event.text);
			var mse:FmsServerEvent = new FmsServerEvent(FmsServerEvent.ERROR);
			mse.descript = event.text;
			dispatchEvent(mse);
		}
		
		protected function connection_ioErrorHandler(event:IOErrorEvent):void
		{
			log("[FmsConnectService] 通信IO异常：" + event.text);
			var mse:FmsServerEvent = new FmsServerEvent(FmsServerEvent.ERROR);
			mse.descript = event.text;
			dispatchEvent(mse);
		}
		
		protected function connection_asyncErrorHandler(event:AsyncErrorEvent):void
		{
			log("[FmsConnectService] 异步错误事件：" + event.text);
			var mse:FmsServerEvent = new FmsServerEvent(FmsServerEvent.ERROR);
			mse.descript = event.text;
			dispatchEvent(mse);
		}
		
		/**
		 * 输出日志
		 * @param args
		 */		
		protected function log(...args):void
		{
			var arg:Array = args as Array;
			if (arg.length > 0)
			{
				var ame:ConnectLibLogEvent = new ConnectLibLogEvent(ConnectLibLogEvent.LOG_MESSAGE);
				ame.logText = args.join(" ");
				dispatchEvent(ame);
			}
		}
		
	}
}

class FMSClient 
{
	public function FMSClient(name:String)
	{
		clientName = name;
	}
	
	private var clientName:String;
}