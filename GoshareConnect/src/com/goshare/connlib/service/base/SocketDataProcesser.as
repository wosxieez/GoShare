package com.goshare.connlib.service.base
{
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.net.Socket;
	import flash.utils.ByteArray;
	import flash.utils.Endian;
	
	public class SocketDataProcesser extends EventDispatcher
	{
		public function SocketDataProcesser(target:IEventDispatcher = null)
		{
			super(target);
		}
		
		
		//--------------------------------------------------------------------------
		//
		//  Socket消息包处理部分
		//
		//--------------------------------------------------------------------------
		protected var bufferBytes:ByteArray = new ByteArray();   // 缓冲区字节
		private var packetBytesLength:int = 0;  			   // 包字节长度
		private var packetBytes:ByteArray; 		               // 包字节
		private var processing:Boolean = false;				   // 包处理中
		
		/**
		 * Mina服务器通讯报文头解析：报文头 8字节
		 */
		protected function processSocketPacket8():void
		{
			if (processing) return;
			processing = true;
			
			// 读包头 当前包头等于0 且 缓存中的可读字节数大于包头的字节数才去读
			if (packetBytesLength == 0 && bufferBytes.bytesAvailable >= 8)
			{
				packetBytesLength = int(bufferBytes.readUTFBytes(8));
				packetBytes = new ByteArray();
			}
			
			// 读包内容 只有内容大于包长度的时候才会去读
			if (packetBytesLength > 0 && bufferBytes.bytesAvailable >= packetBytesLength)
			{
				bufferBytes.readBytes(packetBytes, 0, packetBytesLength);
				processPacket8(packetBytes);
				
				// 将剩下的字节读取到新的字节组中
				var newBufferBytes:ByteArray = new ByteArray();
				bufferBytes.readBytes(newBufferBytes);
				bufferBytes.clear();
				newBufferBytes.readBytes(bufferBytes);
				newBufferBytes.clear();
				packetBytesLength = 0;
				processing = false;
				
				// 一个包处理完毕 继续处理下一个
				if (bufferBytes.bytesAvailable > 0)
					processSocketPacket8();
			}
			else
			{
				processing = false;
			}
		}
		
		private function processPacket8(packetData:ByteArray):void
		{
			// 将包的字节流转换成包的json字符串
			var message:String = packetData.readUTFBytes(packetData.bytesAvailable);
			receiveMessage(message);
		}
		
		/**
		 * Gpip进程通讯报文头解析：报文头 16字节
		 */
		protected function processSocketPacket16():void
		{
			if (processing) return;
			processing = true;
			
			// 读包头 当前包头等于0 且 缓存中的可读字节数大于包头的字节数才去读
			if (packetBytesLength == 0 && bufferBytes.bytesAvailable >= 16)
			{
				//packetBytesLength = int(bufferBytes.readUTFBytes(8));
				//packetBytes = new ByteArray();
				
				bufferBytes.endian = Endian.LITTLE_ENDIAN;
				
				var temp1:int = bufferBytes.readInt();
				var temp2:int = bufferBytes.readInt();
				packetBytesLength = bufferBytes.readInt();
				var temp4:int = bufferBytes.readInt();
				packetBytes = new ByteArray();
				
//					var temp:String = bufferBytes.readMultiByte(bufferBytes.bytesAvailable, "GBK");
//					txtInfo.text += "\n 服务器数据：" + temp;
//					
//					var json:Object = JSON.parse(temp);
//					packetBytesLength = int(temp);
//					processing = false;
//					return;
			}
			
			// 读包内容 只有内容大于包长度的时候才会去读
			if (packetBytesLength > 0 && bufferBytes.bytesAvailable >= packetBytesLength)
			{
				bufferBytes.readBytes(packetBytes, 0, packetBytesLength);
				processPacket16(packetBytes);
				
				// 将剩下的字节读取到新的字节组中
				var newBufferBytes:ByteArray = new ByteArray();
				bufferBytes.readBytes(newBufferBytes);
				bufferBytes.clear();
				newBufferBytes.readBytes(bufferBytes);
				newBufferBytes.clear();
				packetBytesLength = 0;
				processing = false;
				
				// 一个包处理完毕 继续处理下一个
				if (bufferBytes.bytesAvailable > 0)
					processSocketPacket16();
			}
			else
			{
				processing = false;
			}
		}
		
		private function processPacket16(packetData:ByteArray):void
		{
			// 将包的字节流转换成包的json字符串
			//var message:String = packetData.readUTFBytes(packetData.bytesAvailable);
			var message:String = packetData.readMultiByte(packetData.bytesAvailable, "GBK");
			receiveMessage(message);
		}
		
		
		protected function receiveMessage(message:String):void
		{
			// override here
		}
		
		
		/**
		 * C2进程发送报文头封装(同Mina服务器间数据)：报文头 8字节
		 */
		protected function sendSocketMsgByPacket8(message:String, clientSocket:Socket):void
		{
			// 拼装发送socke报文
			var messageBytes:ByteArray = new ByteArray();
			messageBytes.writeUTFBytes(message);
			var packetLength:int = messageBytes.length;
			var packetLengthString:String = packetLength.toString();
			while (packetLengthString.length < 8)
			{
				packetLengthString = "0" + packetLengthString;
			}
			clientSocket.writeUTFBytes(packetLengthString);
			clientSocket.writeBytes(messageBytes);
			clientSocket.flush();
		}
		
		/**
		 * Gpip服务器发送报文头封装：报文头 16字节
		 */
		protected function sendSocketMsgByPacket16(message:String, clientSocket:Socket):void
		{
			var jslen:int = message.replace(/[\u0391-\uFFE5]/g, "aa").length;
			var smes:String = "";
			/* 此处注意socket报文头长度在网络传输的时候容存在大端小端的问题，需要应用以下方法进行特殊处理  */
			var tmpBufferBytes:ByteArray = new ByteArray();
			tmpBufferBytes.endian = Endian.LITTLE_ENDIAN;
			
			tmpBufferBytes.writeUnsignedInt(0);
			tmpBufferBytes.writeUnsignedInt(0);
			tmpBufferBytes.writeUnsignedInt(jslen);
			tmpBufferBytes.writeUnsignedInt(0);
			
			clientSocket.writeBytes(tmpBufferBytes);
			clientSocket.writeMultiByte(message, "GBK");
			clientSocket.flush();
		}
		
	}
}