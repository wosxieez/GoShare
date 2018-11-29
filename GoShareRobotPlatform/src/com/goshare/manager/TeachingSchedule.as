package com.goshare.manager
{
	import com.goshare.event.TeachingScheduleEvent;
	import com.goshare.util.CloneUtil;
	import com.goshare.util.DateTimeUtil;
	
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	/**
	 * 课程计划表sb2文件(全程独立运行) - 模拟课件大师
	 * 
	 * 初始化后独立运行：
	 * 特定时间对外发送事件 - 上课了、下课了以及相关课程信息等 
	 */
	public class TeachingSchedule extends EventDispatcher
	{
		public function TeachingSchedule(target:IEventDispatcher=null)
		{
			super(target);
		}
		
		/** 校准定时器：定时核对（暂定10分钟） **/
		private var calibrateTimer:Timer = new Timer(600000);
		/** 每秒心跳计时器 **/
		private var heartTimer:Timer = new Timer(1000);
		/** 当前系统时间(以天为周期，单位s) **/
		private var nowSysTime:Number = -1;
		
		/** 计划表主体信息 **/
		private var scheduleList:Array;
		/**  当前时间点所处的任务 **/
		private var currTask:Object;
		/**  当前时间点所处的任务在任务清单里的序号 **/
		private var currTaskIndex:int = -1;
		
		/**
		 * 初始化课程表并运行
		 */
		public function init(planInfo:XML):void
		{
			// 初始化当前系统时间
			nowSysTime = DateTimeUtil.getTimeNumForThisDate(new Date());
			// 添加本地心跳计时器事件
			heartTimer.addEventListener(TimerEvent.TIMER, heartHandlerBySeconds);
			// 添加时间校准定时器事件
			calibrateTimer.addEventListener(TimerEvent.TIMER, sysTimerCheckHandler);
			
			// 初始化今日计划对象
			if (!planInfo) {
				// 无安排 - 设置默认计划
				var wakeTime:Object = {id:"01", desc:"唤醒", sceneName:"classFinish"};
				wakeTime.beginTime = DateTimeUtil.getTimeFromHMS("08:00:00");
				wakeTime.endTime = DateTimeUtil.getTimeFromHMS("19:30:00");
				
				var sleepTime:Object = {id:"02", desc:"睡眠", sceneName:""};
				sleepTime.beginTime = DateTimeUtil.getTimeFromHMS("19:30:00");
				wakeTime.endTime = -1;
				
				scheduleList = [wakeTime, sleepTime];
			} else {
				// 有计划 - 按计划走
				var taskList:XMLList = planInfo.Task;
				scheduleList = [];
				
				var index:int = 0;
				for each(var task:XML in taskList) {
					
					var oneTask:Object = {};
					oneTask["id"] = String(task.@id);
					oneTask["desc"] = String(task.@desc);
					oneTask["sceneName"] = String(task.@sceneName);
					oneTask["playBookID"] = String(task.@playBookID);
					oneTask["teacherID"] = String(task.@teacherID);
					oneTask["teacherName"] = String(task.@teacherName);
					oneTask["beginTime"] = DateTimeUtil.getTimeFromHMS(task.@beginTime);
					oneTask["endTime"] = DateTimeUtil.getTimeFromHMS(task.@endTime);
					
					scheduleList.push(oneTask);
					
					// 如果当前时间已经下班了
					if (nowSysTime >= oneTask["beginTime"] && oneTask["sceneName"] == "close") {
						// 通知外部开始切换场景
						broadcastSceneSwitchEvent(true);
						return;
					}
					// 如果当前时间处于已经唤醒状态
					if (nowSysTime >= oneTask["beginTime"] && nowSysTime < oneTask["endTime"]) {
						// 设置当前所处环节信息
						currTask = oneTask;
						currTaskIndex  = index;
					}
					
					index++;
				}
			}
			
			if (!currTask) {
				// 初始化时 - 未到第一个场景开始时间
				trace("当前时间未到第一个场景开始时间，暂不做场景切换动作，等待时间到达！");
			} else {
				// 初始化时 - 知道当前所属场景，通知页面进行切换
				broadcastSceneSwitchEvent();
			}
			// 开始生命运行
			run();
		}
		
		/**
		 * 销毁课程表
		 */
		public function destory():void
		{
			
		}
		
		private function run():void
		{
			// 启动定时器
			heartTimer.start();
			calibrateTimer.start();
		}
		
		/**
		 * 定时重新核对系统时间
		 */
		private function sysTimerCheckHandler(evt:TimerEvent):void
		{
			nowSysTime = DateTimeUtil.getTimeNumForThisDate(new Date());
		}
		
		/**
		 * 本地每秒心跳处理
		 */
		private function heartHandlerBySeconds(evt:TimerEvent):void
		{
			// 当前系统时间变化 +1s 
			if(nowSysTime>0){
				nowSysTime++;
			}
			
			if (currTask) {
				//检查当前状态
				// 如果有设置睡眠场景(即最后一个场景)，则永远走不到最后一个场景：一旦判定下个场景是睡眠，直接关闭应用
				if (nowSysTime > currTask["endTime"]) {
					// 时间到了 - 切换下一个场景
					if (currTaskIndex < scheduleList.length-1) {
						//  获取到下一场景
						var nextTaskInfo:Object = scheduleList[currTaskIndex+1];
						if (nextTaskInfo["sceneName"] == "close") {
							// 下个场景 - 睡眠 -要进行关机了
							broadcastSceneSwitchEvent(true);
						} else {
							// 下个场景 - 非睡眠
							var waitTask:Object = CloneUtil.clone(nextTaskInfo);
							// 如果下一场景为非上课场景，则需设置该场景内要等待的老师信息 (课间判定任课老师来临使用)
							if (waitTask["sceneName"] == "classFinish") {
								if (currTaskIndex <= scheduleList.length-3) {
									waitTask["teacherID"] = scheduleList[currTaskIndex+2]["teacherID"];
									waitTask["teacherName"] = scheduleList[currTaskIndex+2]["teacherName"];
								} else {
									waitTask["teacherID"] = "";
									waitTask["teacherName"] = "";
								}
							}
							// 更新场景信息
							currTaskIndex = currTaskIndex +1;
							currTask = waitTask;
							// 通知外部开始切换场景
							broadcastSceneSwitchEvent();
						}
					} else {
						trace("当前已是最后一个场景了，无后续场景，进入睡眠状态 ...");
						broadcastSceneSwitchEvent(true);
					}
				}
			} else {
				if (nowSysTime >= scheduleList[0]["beginTime"]) {
					// 初始化时 - 未到第一个场景开始时间 - 现在时间到了才会触发该代码段
					// 进入第一个场景
					currTask = scheduleList[0];
					currTaskIndex = 0;
					// 通知外部开始切换场景
					broadcastSceneSwitchEvent();
				}
			}
		}
		
		/**
		 * 通知外层当前应切换到的场景信息
		 */
		private function broadcastSceneSwitchEvent(isClose:Boolean=false):void
		{
			if (isClose) {
				trace("通知日程已完毕！")
				var classCompleteEvt:TeachingScheduleEvent = new TeachingScheduleEvent(TeachingScheduleEvent.TIME_TABLE_COMPLETE_EVENT);
				this.dispatchEvent(classCompleteEvt);
			} else {
				trace("下个状态信息" + JSON.stringify(currTask));
				if (currTask["sceneName"] == "classFinish") {
					trace("通知下课了！")
					var classFinishEvt:TeachingScheduleEvent = new TeachingScheduleEvent(TeachingScheduleEvent.TIME_TABLE_CLASS_END_EVENT);
					classFinishEvt.currSceneInfo = currTask;
					this.dispatchEvent(classFinishEvt);
				}
				if (currTask["sceneName"] == "classIng") {
					trace("通知上课了！")
					var classBeginEvt:TeachingScheduleEvent = new TeachingScheduleEvent(TeachingScheduleEvent.TIME_TABLE_CLASS_BEGIN_EVENT);
					classBeginEvt.currSceneInfo = currTask;
					this.dispatchEvent(classBeginEvt);
				}
			}
		}
		
		/**
		 * 获取当前所处场景信息
		 */
		public function queryCurrSceneInfo():Object
		{
			var result:Object;
			if (currTask) {
				result = currTask;
			}
			return result;
		}
		
		/**
		 * 获取下个场景信息
		 */
		public function queryNextSceneInfo():Object
		{
			var result:Object;
			if (currTaskIndex < scheduleList.length-1) {
				var nextTask:Object = CloneUtil.clone(scheduleList[currTaskIndex+1]);
				// 如果下一场景为非上课场景，则需设置该场景内要等待的老师信息 (课间判定任课老师来临使用)
				if (nextTask["sceneName"] == "classFinish") {
					if (currTaskIndex <= scheduleList.length-3) {
						nextTask["teacherID"] = scheduleList[currTaskIndex+2]["teacherID"];
						nextTask["teacherName"] = scheduleList[currTaskIndex+2]["teacherName"];
					} else {
						nextTask["teacherID"] = "";
						nextTask["teacherName"] = "";
					}
				}
				result = nextTask;
			}
			return result;
		}
		
	}
}