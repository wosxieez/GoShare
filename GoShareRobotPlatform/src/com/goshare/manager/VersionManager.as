package com.goshare.manager
{
    import com.goshare.event.VersionEvent;
    import com.xiaomu.event.VersionEvent;
	
	import flash.desktop.NativeApplication;
	import flash.desktop.Updater;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	
	/**
	 * 检查更新成功后派发 
	 */	
	[Event(name="checkResult", type="com.goshare.event.VersionEvent")]
	
	/**
	 * 检查更新失败后派发 
	 */	
	[Event(name="checkFault", type="com.goshare.event.VersionEvent")]
	
	/**
	 * 下载安装文件时派发 用于指示下载进度
	 */	
	[Event(name="progress", type="com.goshare.event.VersionEvent")]
	
	/**
	 * 更新文件下载成功后派发
	 */	
	[Event(name="downloadResult", type="com.goshare.event.VersionEvent")]
	
	/**
	 * 更新文件下载失败后派发
	 */	
	[Event(name="downloadFault", type="com.goshare.event.VersionEvent")]
	
	/**
	 * 程序更新辅助类
	 * 
	 * <pre>
	 * var updater:AppUpdater = new AppUpdater(updateURL);
	 * 
	 * 使用updater.checkVersion()进行版本检查
	 * 
	 * 版本检查结束后使用updater.update()进行程序更新
	 * 
	 * </pre>
	 * 
	 * @author coco
	 */	
	public class VersionManager extends EventDispatcher
	{
		public function VersionManager()
		{
		}
		
		//--------------------------------------------------------------------------
		//
		//  Get Instance
		//
		//--------------------------------------------------------------------------
		
		private static var instance:VersionManager;
		
		public static function getInstance():VersionManager
		{
			if (!instance)
				instance = new VersionManager();
			
			return instance;
		}
		
		
		//--------------------------------------------------------------------------
		//
		//  Variables
		//
		//--------------------------------------------------------------------------
		
		/**
		 * 更新地址 
		 */		
		public var updateURL:String = "http://www.hefeixiaomu.com/goshare/update.xml";
		
		/**
		 * 当前版本号 
		 */		
		public var curVersionNumber:String;
		
		/**
		 * 当前版本符
		 */		
		public var curVersionLabel:String;
		
		/**
		 *  最新版本号
		 */		
		public var latestVersionNumber:String;
		
		/**
		 * 最新版本符 
		 */		
		public var latestVersionLabel:String;
		
		/**
		 *  从服务器获取的版本描述符信息
		 */		
		public var description:String;
		
		/**
		 * 文件下载地址
		 */		
		public var downloadURL:String = null;
		
		/**
		 * 下载的文件名 
		 */		
		public var downloadFilename:String = null;
		
		/**
		 * 下载文件的大小 
		 */		
		public var downloadFileSize:int = 0;
		
		/**
		 * 是否可以更新 
		 */		
		public var available:Boolean = false;
		
		/**
		 * 下载到本地的文件
		 */		
		public var downloadFile:File;
		
		
		//--------------------------------------------------------------------------
		//
		//  Methods
		//
		//--------------------------------------------------------------------------
		
		/**
		 * 检查版本
		 */		
		public function checkVersion():void
		{
			var urlLoader:URLLoader = new URLLoader();
			urlLoader.addEventListener(Event.COMPLETE, urlLoader_completeHandler);
			urlLoader.addEventListener(IOErrorEvent.IO_ERROR,check_errorHandler);
			urlLoader.load(new URLRequest(updateURL));
		}
		
		/**
		 * 开始下载更新文件
		 */		
		public function download():void
		{
			if (!downloadURL || !available)
				return;
			
			var urlLoader:URLLoader = new URLLoader();
			urlLoader.dataFormat = URLLoaderDataFormat.BINARY;
			urlLoader.addEventListener(Event.COMPLETE, air_completeHandler);
			urlLoader.addEventListener(Event.OPEN, urlLoader_openHandler);
			urlLoader.addEventListener(ProgressEvent.PROGRESS, urlLoader_progressHandler);
			urlLoader.addEventListener(IOErrorEvent.IO_ERROR, urlLoader_errorHandler);
			urlLoader.load(new URLRequest(downloadURL));
		}
		
		/**
		 * 开始安装
		 */		
		public function install():void
		{
			if (!downloadFile || !available)
				return;
			
			new Updater().update(downloadFile, latestVersionNumber);
		}
		
		/**
		 * 获取描述符文件目录URL
		 */		
		private function getDesDirUrl():String
		{
			var end:int = updateURL.lastIndexOf('/');
			var newURL:String = updateURL.substring(0, end + 1);
			return newURL;
		}
		
		private function dispathchProgressEvent(value:int):void
		{
			var progressEvent:VersionEvent = new VersionEvent(VersionEvent.PROGRESS);
			progressEvent.progressValue = value;
			dispatchEvent(progressEvent);
		}
		
		//--------------------------------------------------------------------------
		//
		//  Event Handlers
		//
		//--------------------------------------------------------------------------
		
		protected function urlLoader_completeHandler(e:Event):void
		{
			// local version
			var localXML:XML = NativeApplication.nativeApplication.applicationDescriptor;
			var nss:Namespace = localXML.namespace();
			curVersionNumber = localXML.nss::versionNumber;
			curVersionLabel = localXML.nss::versionLabel;
			
			//  version
			var remoteXML:XML = XML(e.target.data);
			var ns:Namespace = remoteXML.namespace();
			latestVersionNumber = remoteXML.ns::versionNumber;
			latestVersionLabel = remoteXML.ns::versionLabel;
			downloadFilename = remoteXML.ns::filename;
			downloadFileSize = remoteXML.ns::filesize;
			downloadURL = remoteXML.ns::url;
			description = remoteXML.ns::description;
			
			// 1.2.3 -> 123
			var nowVersion:String = curVersionNumber.split('.').join('');
			var remoteVersion:String = latestVersionNumber.split('.').join('');
			
			var event:VersionEvent = new VersionEvent(VersionEvent.CHECK_RESULT);
			
			if (Number(nowVersion) < Number(remoteVersion))
				available = event.available = true;
			else
				available = event.available = false;
			
			dispatchEvent(event);
		}
		
		private function check_errorHandler(e:IOErrorEvent):void
		{
			dispatchEvent(new VersionEvent(VersionEvent.CHECK_FAULT));
		}
		
		protected function air_completeHandler(e:Event):void
		{
			downloadFile = File.userDirectory.resolvePath(downloadFilename);
			var fs:FileStream = new FileStream();
			fs.open(new File(downloadFile.nativePath), FileMode.WRITE);
			fs.writeBytes(e.currentTarget.data);
			fs.close();
			
			dispatchEvent(new VersionEvent(VersionEvent.DOWNLOAD_RESULT));
		}
		
		private function urlLoader_errorHandler(e:IOErrorEvent):void
		{
			dispatchEvent(new VersionEvent(VersionEvent.DOWNLAOD_FAULT));
		}
		
		private function urlLoader_openHandler(e:Event):void
		{
			dispathchProgressEvent(0);
		}
		
		private function urlLoader_progressHandler(e:ProgressEvent):void
		{
			var value:int = int(e.bytesLoaded / downloadFileSize * 100);
			dispathchProgressEvent(value);
		}
		
	}
}