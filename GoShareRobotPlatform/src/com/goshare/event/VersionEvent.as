package com.goshare.event
{
	import flash.events.Event;
	
	/**
	 * 更新调度事件
	 * 
	 * @author coco
	 */	
	public class VersionEvent extends Event
	{
		/**
		 * 检查更新成功后派发
		 */		
		public static const CHECK_RESULT:String = "checkResult";
		
		/**
		 * 检查更新失败的时候派发 
		 */		
		public static const CHECK_FAULT:String = "checkFault";
		
		/**
		 * 下载安装文件时派发 用于指示下载进度 
		 */		
		public static const PROGRESS:String = "progress";
		
		/**
		 * 更新文件下载成功时候派发
		 */		
		public static const DOWNLOAD_RESULT:String = "downloadResult";
		
		/**
		 * 更新文件下载失败时候派发
		 */		
		public static const DOWNLAOD_FAULT:String = "downloadFault";
		
		/**
		 * 是否有新版本更新 
		 */		
		public var available:Boolean = false;
		
		/**
		 * 下载安装文件的进度 0-100
		 */		
		public var progressValue:int;
		
		public function VersionEvent(type:String)
		{
			super(type);
		}
	}
}