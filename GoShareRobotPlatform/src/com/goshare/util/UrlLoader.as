package com.goshare.util
{
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.events.TimerEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.URLRequestMethod;
	import flash.net.URLVariables;
	import flash.utils.Timer;
	
	/**
	 *  URLLoader
	 *  支持超时处理
	 */
	public class UrlLoader extends flash.net.URLLoader
	{
		private var timeout:Number;
		private var timeoutEnable:Boolean = false;
		private var timeoutTimer:Timer;
		
		private var loadRequest:URLRequest;
		private var resultCallback:Function;
		private var faultCallback:Function;
		
		/**
		 * 构造函数
		 * @param _resultHandler 加载成功回掉函数 - 传入参数object
		 * @param _faultHandler 加载失败回掉 - 传入失败原因String
		 * @param _timeout 超时时间
		 */
		public function UrlLoader(_resultHandler:Function=null, _faultHandler:Function=null, _timeout:Number=-1)
		{
			super(null);
			
			resultCallback = _resultHandler;
			faultCallback = _faultHandler;
			
			timeout = _timeout;
			if (timeout > 0) {
				timeoutTimer = new Timer(timeout);
				timeoutTimer.addEventListener(TimerEvent.TIMER, handleTimeout);
				timeoutEnable = true;
			} else {
				timeoutEnable = false;
			}
		}
		
		/**
		 * 加载配置文件
		 * @param request url
		 */
		public function loadCfgFile(url:String):void
		{
			loadRequest = new URLRequest(url);
			
			addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
			addEventListener(Event.COMPLETE, completeHandler);
			addEventListener(SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler);
			
			if (timeoutEnable) {
				timeoutTimer.start();
			}
			
			super.load(loadRequest);
		}
		
		
		/**
		 * 访问远程http交易
		 * @param url 访问url
		 * @param dataParam 数据
		 */
		public function loadHttpService(url:String, dataParam:URLVariables):void
		{
			addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
			addEventListener(Event.COMPLETE, completeHandler);
			addEventListener(SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler);
			
			if (timeoutEnable) {
				timeoutTimer.start();
			}
			
			loadRequest = new URLRequest(url);
			loadRequest.contentType = "application/x-www-form-urlencoded; charset=UTF-8";
			loadRequest.method = URLRequestMethod.POST;
			loadRequest.data = dataParam;
			
			super.load(loadRequest);
		}
		
		
		protected function completeHandler(event:Event):void
		{
			if (resultCallback != null) {
				resultCallback.call(null, event.currentTarget.data);
			}
			destory();
		}
		
		
		protected function securityErrorHandler(event:SecurityErrorEvent):void
		{
			if (timeoutEnable && timeoutTimer.running) {
				// 再次发起请求
				super.load(loadRequest);
			} else {
				if (faultCallback != null) {
					faultCallback.call(null, "加载失败！--- securityError");
				}
				destory();
			}
		}
		
		
		protected function ioErrorHandler(event:IOErrorEvent):void
		{
			if (timeoutEnable && timeoutTimer.running) {
				// 再次发起请求
				super.load(loadRequest);
			} else {
				if (faultCallback != null) {
					faultCallback.call(null, "加载失败！--- ioError");
				}
				destory();
			}
		}
		
		
		private function handleTimeout(event:TimerEvent):void
		{
			if (faultCallback != null) {
				faultCallback.call(null, "加载超时");
			}
			
			close();
		}
		
		
		override public function close():void
		{
			destory();
			try {
				super.close();
			} catch(error:Error) {
				// 异常错误
			}
		}
		
		
		private function destory():void
		{
			if (timeoutEnable)
			{
				timeoutEnable = false;
				
				timeoutTimer.reset();
				timeoutTimer.removeEventListener(TimerEvent.TIMER, handleTimeout);
				timeoutTimer = null;
			}
			
			removeEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
			removeEventListener(Event.COMPLETE, completeHandler);
			removeEventListener(SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler);
		}
		
	}
}