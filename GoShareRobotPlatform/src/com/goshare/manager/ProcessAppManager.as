package com.goshare.manager
{
	import flash.desktop.NativeProcess;
	import flash.desktop.NativeProcessStartupInfo;
	import flash.errors.IllegalOperationError;
	import flash.events.IOErrorEvent;
	import flash.events.NativeProcessExitEvent;
	import flash.events.ProgressEvent;
	import flash.filesystem.File;

	public class ProcessAppManager
	{
		//--------------------------------------------------------------------------
		//
		//  Variables
		//
		//--------------------------------------------------------------------------
		/**  
		 * 当前正在运行的进程清单
		 *  [{name:"", processPath:"", processObj:XX}]
		 */
		private var runningProcessList:Array = [];
		
		
		//--------------------------------------------------------------------------
		//
		//  Methods
		//
		//--------------------------------------------------------------------------
		private static var _instance:ProcessAppManager;
		public static function getInstance():ProcessAppManager
		{
			if (!_instance) {
				_instance = new ProcessAppManager();
			}
			return _instance;
		}
		
		public function ProcessAppManager()
		{
		}
		
		/**
		 * 启动第三方进程
		 */
		public function startThirdProcess(appName:String, appRelativePath:String):void
		{
			trace("==== 打开第三方应用： " + appName + " : " + appRelativePath);
			
			var isRun:Boolean = processIsRunning(appName, appRelativePath);
			if (!isRun) {
				// 应用未运行 - 可以启动
				if (NativeProcess.isSupported) {
					
					var processFile:File;
					if (appRelativePath.indexOf("App://") == 0) {
						// exe程序为相对本应用的路径
						var tmpPath:String = appRelativePath.slice(6);
						processFile = File.applicationDirectory.resolvePath(tmpPath);
					} else {
						// exe程序为绝对路径
						processFile = new File(appRelativePath);
					}
					
					var na:NativeProcessStartupInfo = new NativeProcessStartupInfo;
					na.executable  = processFile;
//					var processArgs:Vector.<String> = new Vector.<String>();
//					processArgs[0] = "foo";
//					nativeProcessStartupInfo.arguments = processArgs;
					// 创建一个本地进程，并运行
					var process:NativeProcess = new NativeProcess();
					process.addEventListener(ProgressEvent.STANDARD_OUTPUT_DATA, onOutputData);
					process.addEventListener(ProgressEvent.STANDARD_ERROR_DATA, onErrorData);
					process.addEventListener(NativeProcessExitEvent.EXIT, onExit);
					process.addEventListener(IOErrorEvent.STANDARD_OUTPUT_IO_ERROR, onIOError);
					process.addEventListener(IOErrorEvent.STANDARD_ERROR_IO_ERROR, onIOError);
					try {
						trace("[ProcessAppManager] 启动本地程序进程：" + appName);
						process.start(na);
						addProcessToList(appName, appRelativePath, process);
					} catch (e:IllegalOperationError) {
						trace("异常！IllegalOperationError");
					}
				}
			}
		}
		
		/**
		 * 关闭第三方进程
		 */
		public function stopThirdProcess(appName:String, appRelativePath:String):void
		{
			trace("==== 关闭第三方应用： " + appName + " : " + appRelativePath);
			
			var isRun:Boolean = processIsRunning(appName, appRelativePath);
			if (isRun) {
				// 应用运行中 - 可以关闭
				var delProcess:NativeProcess = removeProcessFromList(appName, appRelativePath);
				if (delProcess && delProcess.running) {
					trace("[ProcessAppManager] 关闭本地程序进程！");
					delProcess.exit(true);
				}
			}
		}
		
		public function onOutputData(event:ProgressEvent):void
		{
			trace("Got: "); 
		}
		
		public function onErrorData(event:ProgressEvent):void
		{
			trace("ERROR -"); 
		}
		
		public function onExit(event:NativeProcessExitEvent):void
		{
			if (isNaN(event.exitCode)) {
				trace("本地应用进程被我关闭了(exit)");
			} else {
				if (event.exitCode == 0) {
					trace("本地应用进程已经启动了，但不是我拉起来的！");
				} else {
					trace("Process exited with ", event.exitCode);
				}
			}
		}
		
		public function onIOError(event:IOErrorEvent):void
		{
			trace(event.toString());
		}
		
		// ---------------------------------------------------------------------------------------------------
		/**
		 * 进程是否在运行中
		 */
		private function processIsRunning(appName:String, appRelativePath:String):Boolean
		{
			for each(var item:Object in runningProcessList) {
				if (item["name"] == appName && item["processPath"] == appRelativePath) {
					return true;
				}
			}
			return false;
		}
		
		/**
		 * 加入运行进程列表
		 */
		private function addProcessToList(appName:String, appRelativePath:String, process:NativeProcess):void
		{
			var isExist:Boolean = processIsRunning(appName, appRelativePath);
			if (!isExist) {
				var newItem:Object = {"name":appName, "processPath":appRelativePath, "processObj":process};
				runningProcessList.push(newItem);
			}
		}
		
		/**
		 * 从运行进程列表中移除
		 */
		private function removeProcessFromList(appName:String, appRelativePath:String):NativeProcess
		{
			for (var i:int = 0; i < runningProcessList.length; i++) 
			{
				if (runningProcessList[i]["name"] == appName && runningProcessList[i]["processPath"] == appRelativePath) {
					var delProcess:NativeProcess = runningProcessList[i]["processObj"];
					runningProcessList.splice(i);
					return delProcess;
				}
			}
			return null;
		}
		
	}
}