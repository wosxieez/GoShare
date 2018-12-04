package com.goshare.manager
{
	import com.goshare.service.HttpTradeService;
	import com.goshare.util.UrlLoader;
	
	import flash.net.SharedObject;
	
	/************************************************************
	 ********************************************
	 * 
	 * 全局数据管理
	 * 
	 ********************************************
	 *************************************************************/
	public class AppDataManager
	{
		public function AppDataManager()
		{
		}
		
		private static  var _instance:AppDataManager;
		
		public static function getInstance():AppDataManager
		{
			if (!_instance) {
				_instance = new AppDataManager();
			}
			return _instance;
		}
		
		// -------------------------------------------------------- parameter --------------------------------------------
		/** 视频服务器地址 **/
		public var fmsService:String = "";
		/** 应用运行模式：0-编辑器模式; 1-播放器模式 **/
		public var projectType:int = 0;
		
		/**
		 * 当前系统指令清单
		 */
		public var commandsList:Array = [];
		
		/**
		 * 当前系统场景清单
		 */
		public var sceneList:Array = [];
		
		// ------------------------------------------ method ---------------------------------
		public function init():void
		{
			loadCfgFile();
		}
		
		public function destory():void
		{
			
		}
		
		/********************
		 * 
		 *  初始化各配置信息 
		 * 
		 ********************/
		private function loadCfgFile():void
		{
			// 加载系统配置文件sysconfig.xml
			var sysCfgLoader:UrlLoader = new UrlLoader(sysConfigInfoLoadSuc, sysConfigInfoLoadFail, 10000);
			sysCfgLoader.loadCfgFile("conf/Sysconfig.xml");
			
			// 加载指令清单 commands.xml
			var commandsLoader:UrlLoader = new UrlLoader(loadCommandsListSuc, loadCommandsListFail, 10000);
			commandsLoader.loadCfgFile("conf/Commands.xml");
			
			// 加载场景配置清单 sceneconfig.xml
			var scenesLoader:UrlLoader = new UrlLoader(loadSceneInfoSuc, loadSceneInfoFail, 10000);
			scenesLoader.loadCfgFile("conf/SceneConfig.xml");
		}
		
		/**
		 * 系统配置文件加载成功
		 */
		private function sysConfigInfoLoadSuc(sysCfg:Object):void
		{
			log("系统配置文件[sysconfig.xml] 加载成功..");
			
			// 场景布局配置信息解析
			if (sysCfg) {
				var cfgXML:XML = XML(sysCfg);
				var paramList:XMLList = cfgXML.Param;
				for each(var item:XML in paramList) {
					if (item.@name == "FMS_SERVER") {
						fmsService = item.@value;
					}
					if (item.@name == "HTTP_SERVER") {
						HttpTradeService.getInstance().httpServerUrl = item.@value;
					}
					if (item.@name == "PROJECT_TYPE") {
						projectType = item.@value;
						// 设置当前页面显示模式
						if (projectType == 0) {
							Scratch.app.setEditMode(true);
						} else {
							Scratch.app.setEditMode(false);
						}
					}
				}
			}
		}
		
		private function sysConfigInfoLoadFail(failReason:String):void
		{
			log("系统配置文件[sysconfig.xml] 加载失败.." + failReason);
		}
		
		/**
		 * 指令清单加载成功
		 */
		private function loadCommandsListSuc(commandsCfg:Object):void
		{
			log("指令清单[Commands.xml] 加载成功..");
			
			if (commandsCfg) {
				var cfgXML:XML = XML(commandsCfg);
				var cmdList:XMLList = cfgXML.command;
				for each(var item:XML in cmdList) {
					var command:Object = {};
					command["id"] = item.@id;
					command["name"] = item.@name;
					command["desc"] = item.@desc;
					commandsList.push(command);
				}
			}
		}
		
		private function loadCommandsListFail(failReason:String):void
		{
			log("指令清单[Commands.xml] 加载失败.." + failReason);
		}
		
		/**
		 * 获取中文描述 - 根据指令名
		 */
		public function getCmdDescByName(name:String):String
		{
			for each (var item:Object in commandsList) {
				if (item["name"] == name) {
					return item["desc"];
				}
			}
			return "";
		}
		
		/**
		 * 获取指令名 - 根据中文描述
		 */
		public function getCmdNameByDesc(desc:String):String
		{
			for each (var item:Object in commandsList) {
				if (item["desc"] == desc) {
					return item["name"];
				}
			}
			return "";
		}
		
		/**
		 * 场景信息清单加载成功
		 */
		private function loadSceneInfoSuc(sceneCfg:Object):void
		{
			log("指令清单[SceneConfig.xml] 加载成功..");
			
			if (sceneList) {
				var cfgXML:XML = XML(sceneCfg);
				var cmdList:XMLList = cfgXML.GpipScene;
				for each(var item:XML in cmdList) {
					var command:Object = {};
					command["name"] = item.@name;
					command["desc"] = item.@desc;
					sceneList.push(command);
				}
			}
		}
		
		private function loadSceneInfoFail(failReason:String):void
		{
			log("指令清单[SceneConfig.xml] 加载失败.." + failReason);
		}
		
		/**
		 * 获取中文描述 - 根据场景名
		 */
		public function getSceneDescByName(name:String):String
		{
			for each (var item:Object in sceneList) {
				if (item["name"] == name) {
					return item["desc"];
				}
			}
			return "";
		}
		
		/**
		 * 获取场景名 - 根据中文描述
		 */
		public function getSceneNameByDesc(desc:String):String
		{
			for each (var item:Object in sceneList) {
				if (item["desc"] == desc) {
					return item["name"];
				}
			}
			return "";
		}
		
		// ------------------------------------------ tool  function start ---------------------------------
		/**
		 * 写入配置信息到flash缓存中
		 */
		public static function setShareObjectValue(key:String, value:String):void
		{
			SharedObject.getLocal("goshareEduRobot").data[key] = value;
			SharedObject.getLocal("goshareEduRobot").flush();
		}
		
		/**
		 * 从flash缓存中读取配置信息
		 */
        public static function getShareObjectValue(key:String):String
		{
			if (SharedObject.getLocal("goshareEduRobot").data[key] != undefined) {
				return SharedObject.getLocal("goshareEduRobot").data[key];
			} else {
				return "";
			}
		}
		
		// ------------------------------------------ tool  function end ---------------------------------
		
		/**
		 * 输出日志
		 */
		protected function log(...args):void
		{
			var arg:Array = args as Array;
			if (arg.length > 0)
			{
				AppManager.log("[AppDataManager]  " + args.join(" "));
			}
		}
		
	}
}