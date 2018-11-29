package com.goshare.util
{
	import flash.desktop.Clipboard;
	import flash.desktop.ClipboardFormats;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
    import flash.system.Capabilities;

    public class LoggerUtils
	{
		public function LoggerUtils()
		{
			appPath = File.applicationStorageDirectory.nativePath.toString();
		}
		
		private static var instance:LoggerUtils=null;
		public static function getInstance():LoggerUtils
		{
			if (!instance){
				instance = new LoggerUtils();
			}
			return instance;
		}
		
		/** 缓存日志(最多100条) **/
		private var logTempData:Array = [];
		private var appPath:String = "";
		
		/**
		 * 输出日志 - 普通
		 */	
		public function printLog(...args):void
		{
			try
			{
				var date:Date = new Date();
				var arg:Array = args as Array;
				if (arg.length > 0)
				{
					var message:String = date.toLocaleTimeString() + " " + arg.join(" ");
					
					// 更新缓存日志 
					logTempData.push(message);
					if  (logTempData.length > 100) {
						logTempData.shift();
					}
					
					// 写到本地文件
					var logFilePath:String = appPath + File.separator + "logs" + File.separator + date.fullYear + "-" + (date.month + 1) + "-" + date.date + ".txt";
					var valueFile:File = new File(logFilePath);
					var fs:FileStream = new FileStream();
					fs.open(valueFile, FileMode.APPEND);
					fs.writeMultiByte(message + "\r", "utf-8");
					fs.close();
					
					// 打印到控制台 (开发期间使用)
                    // todo Use Capabilities.isDebugger ?
					 trace(message);
				}
			} 
			catch(error:Error) 
			{
				trace(error.message);
			}
		}
		
		/**
		 * 输出日志 - 错误Error
		 */	
		public function printErrorLog(...args):void
		{
			try
			{
				var date:Date = new Date();
				var arg:Array = args as Array;
				if (arg.length > 0)
				{
					var message:String = date.toLocaleTimeString() + " " + arg.join(" ");
					
					// 更新缓存日志 
					logTempData.push(message);
					if  (logTempData.length > 100) {
						logTempData.shift();
					}
					
					// 写到本地文件
					var logFilePath:String = appPath + File.separator + "logs" + File.separator + date.fullYear + "-" + (date.month + 1) + "-" + date.date + "_error.txt";
					var valueFile:File = new File(logFilePath);
					var fs:FileStream = new FileStream();
					fs.open(valueFile, FileMode.APPEND);
					fs.writeMultiByte(message + "\r", "utf-8");
					fs.close();
					
					// 打印到控制台 (开发期间使用)
					trace(message);
				}
			} 
			catch(error:Error) 
			{
				trace(error.message);
			}
		}
		
		/**
		 * 复制日志缓存到操作系统粘贴板
		 */
		public function copyLogs():void
		{
			Clipboard.generalClipboard.setData(ClipboardFormats.TEXT_FORMAT, logTempData.join("\r"));
		}
		
	}
}
