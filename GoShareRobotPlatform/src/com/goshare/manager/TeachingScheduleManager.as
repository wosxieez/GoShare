package com.goshare.manager
{
	import com.goshare.data.GlobalEventDict;
	import com.goshare.data.SceneContentVO;
	import com.goshare.event.TeachingScheduleEvent;
	import com.goshare.gpipservice.GpipService;
	import com.goshare.util.UrlLoader;
	
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	
	/**********************************************
	 * 
	 * 今日教学流程管理 (每日开机启动程序后进行教学计划更新)
	 * 
	 ********************************************/
	public class TeachingScheduleManager extends EventDispatcher
	{
		public function TeachingScheduleManager(target:IEventDispatcher=null)
		{
			super(target);
		}
		
		private static  var _instance:TeachingScheduleManager;
		
		public static function getInstance():TeachingScheduleManager
		{
			if (!_instance) {
				_instance = new TeachingScheduleManager();
			}
			return _instance;
		}
		
		// -------------------------------------------------------- parameter --------------------------------------------
		/**  教学计划 **/
		private var mainTeachingSchedule:TeachingSchedule;
		
		// -------------------------------------------------------- method -----------------------------------------------
		/**
		 * 初始化教学流程管理类
		 */
		public function init():void
		{
			// 创建教学计划主文件
			mainTeachingSchedule = new TeachingSchedule();
			mainTeachingSchedule.addEventListener(TeachingScheduleEvent.TIME_TABLE_CLASS_BEGIN_EVENT, classBeginEvtHandler);
			mainTeachingSchedule.addEventListener(TeachingScheduleEvent.TIME_TABLE_CLASS_END_EVENT, classFinishEvtHandler);
			mainTeachingSchedule.addEventListener(TeachingScheduleEvent.TIME_TABLE_COMPLETE_EVENT, classCompleteEvtHandler);
			// 加载教学计划内容- 开发期暂用配置文件形式
			var loader:UrlLoader = new UrlLoader(loadTeachingScheduleCfgSuc, loadTeachingScheduleCfgFail, 10000);
			loader.loadCfgFile("com/goshare/conf/TeachingSchedule.xml");
		}
		
		/**
		 * 销毁今日教学计划管理类
		 */
		public function destory():void
		{
			if (mainTeachingSchedule) {
				mainTeachingSchedule.removeEventListener(TeachingScheduleEvent.TIME_TABLE_CLASS_BEGIN_EVENT, classBeginEvtHandler);
				mainTeachingSchedule.removeEventListener(TeachingScheduleEvent.TIME_TABLE_CLASS_END_EVENT, classFinishEvtHandler);
				mainTeachingSchedule.removeEventListener(TeachingScheduleEvent.TIME_TABLE_COMPLETE_EVENT, classCompleteEvtHandler);
				mainTeachingSchedule.destory();
			}
		}
		
		/**
		 * 配置文件加载成功
		 */
		protected function loadTeachingScheduleCfgSuc(scheduleCfg:Object):void
		{
			log("今日课程计划配置文件[TeachingSchedule.xml] 加载成功..");
			
			// 场景布局配置信息解析
			if (scheduleCfg) {
				var cfgXML:XML = XML(scheduleCfg);
				mainTeachingSchedule.init(cfgXML);
			} else {
				mainTeachingSchedule.init(null);
			}
		}
		
		/**
		 * 配置文件加载失败
		 */
		protected function loadTeachingScheduleCfgFail(failReason:String):void
		{
			log("今日课程计划配置文件[TeachingSchedule.xml] 加载失败.." + failReason);
			mainTeachingSchedule.init(null);
		}
		
		/**
		 * 收到课程表通知 - 上课了
		 */
		private function classBeginEvtHandler(evt:TeachingScheduleEvent):void
		{
			if (evt.currSceneInfo) {
//				log("课程表上课时间到，上课事件通知派发！");
//				var currSceneVO:SceneContentVO = new SceneContentVO(evt.currSceneInfo);
//
//				if (AppSceneManager.getInstance().currentScene == null) {
//					// 当前场景为空(刚启动)，直接进入上课状态
//					AppManager.ApiEvtDispatcher(GlobalEventDict.REQUEST_CLASS_BEGIN_EVENT, {trigger:"classplan", sceneVO:currSceneVO}, GlobalEventDict.APP_SPACE);
//				} else {
//					AppManager.ApiEvtDispatcher(GlobalEventDict.REQUEST_CLASS_READY_EVENT, {trigger:"classplan", sceneVO:currSceneVO}, GlobalEventDict.APP_SPACE);
//				}
//				GpipService.getInstance().tts('同学们,开始上节课了');
			}
		}
		
		/**
		 * 收到课程表通知 - 下课了
		 */
		private function classFinishEvtHandler(evt:TeachingScheduleEvent):void
		{
			if (evt.currSceneInfo) {
//				log("课程表下课时间到，下课事件通知派发！");
//				var currSceneVO:SceneContentVO = new SceneContentVO(evt.currSceneInfo);
//				AppManager.ApiEvtDispatcher(GlobalEventDict.REQUEST_CLASS_FINISH_EVENT, {trigger:"classplan", sceneVO:currSceneVO}, GlobalEventDict.APP_SPACE);
//				GpipService.getInstance().tts('同学们,下课了');
            }
		}
		
		/**
		 * 收到课程表通知 - 日程安排已完毕
		 */
		private function classCompleteEvtHandler(evt:TeachingScheduleEvent):void
		{
//			log("课程表安排已完毕！");
//			AppManager.ApiEvtDispatcher(GlobalEventDict.REQUEST_PLAN_COMPLETE_EVENT, null, GlobalEventDict.APP_SPACE);
		}
		
		/**
		 * 主动从课程表内获取当前所处的场景信息
		 */
		public function queryCurrSceneInfo():SceneContentVO{
//			var tempVO:SceneContentVO;
//			var tempObj:Object = mainTeachingSchedule.queryCurrSceneInfo();
//			if (tempObj) {
//				tempVO = new SceneContentVO(tempObj);
//			}
//			return tempVO;
			return null;
		}
		
		/**
		 * 从课程表内获取下个场景的信息
		 */
		public function queryNextSceneInfo():SceneContentVO{
			var tempVO:SceneContentVO;
			var tempObj:Object = mainTeachingSchedule.queryNextSceneInfo();
			if (tempObj) {
				tempVO = new SceneContentVO(tempObj);
			}
			return tempVO;
		}
		
		// ---------------------------- log --------------------------------
		/**
		 * 输出日志
		 */
		protected function log(...args):void
		{
			var arg:Array = args as Array;
			if (arg.length > 0)
			{
				AppManager.log("[TeachingScheduleManager]  " + args.join(" "));
			}
		}
		
	}
}