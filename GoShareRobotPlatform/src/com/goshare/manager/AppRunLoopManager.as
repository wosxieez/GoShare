package com.goshare.manager
{
	import com.goshare.util.DateTimeUtil;
	
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	import flash.utils.getTimer;
	
	/**
	 * 全局定时轮循处理器
	 * @author coco
	 */	
	public class AppRunLoopManager
	{
		public function AppRunLoopManager()
		{
			super();
		}
		
		//--------------------------------------------------------------------------
		//
		//  Get Instance
		//
		//--------------------------------------------------------------------------
		
		private static var instance:AppRunLoopManager;
		
		public static function getInstance():AppRunLoopManager
		{
			if (!instance)
				instance = new AppRunLoopManager();
			
			return instance;
		}
		
		
		//--------------------------------------------------------------------------
		//
		//  Properties
		//
		//--------------------------------------------------------------------------
		
		private var runLoops:Vector.<RunLoop> = new Vector.<RunLoop>();
		private var runLoopTimer:Timer;
		
		/** 当前系统时间 (Date型) */
		public var nowSysDate:Date; 
		/** 当前系统时间(以天为周期，单位s) **/
		public var nowSysTime:Number = -1;
		/** 校准定时器：定时校准当前系统时间（暂定10分钟） **/
		private var calibrateTimer:Timer;
		
		//--------------------------------------------------------------------------
		//
		//  Methods
		//
		//--------------------------------------------------------------------------
		public function init():void
		{
			AppManager.log("[AppRunLoopManager] RunLoop管理器启动");
			
			if (!runLoopTimer)
			{
				runLoopTimer = new Timer(1000); // 每秒一次
				runLoopTimer.addEventListener(TimerEvent.TIMER, runLoopTimer_timerHandler);
				runLoopTimer.start();
			}
			
			if (!calibrateTimer) {
				calibrateTimer = new Timer(600000); // 每十分钟校准一次 
				calibrateTimer.addEventListener(TimerEvent.TIMER, sysTimerCheckHandler);
				calibrateTimer.start();
			}
			
			// 初始化当前系统时间
			nowSysTime = DateTimeUtil.getTimeNumForThisDate(new Date());
		}
		
		public function dispose():void
		{
			if (runLoopTimer)
			{
				runLoopTimer.removeEventListener(TimerEvent.TIMER, runLoopTimer_timerHandler);
				runLoopTimer.stop();
				runLoopTimer = null;
			}
			if (calibrateTimer)
			{
				calibrateTimer.removeEventListener(TimerEvent.TIMER, sysTimerCheckHandler);
				calibrateTimer.stop();
				calibrateTimer = null;
			}
			AppManager.log("[AppRunLoopManager] RunLoop管理器关闭");
		}
		
		
		public function addRunLoop(func:Function, interval:int = 1000):void
		{
			removeRunLoop(func);
			
			var runLoop:RunLoop = new RunLoop();
			runLoop.func = func;
			runLoop.interval = interval;
			runLoop.time = getTimer();
			runLoops.push(runLoop);
		}
		
		public function removeRunLoop(func:Function):void
		{
			var runLoopLen:int = runLoops.length;
			for (var i:int = 0; i < runLoopLen; i++)
			{
				if (runLoops[i].func == func)
				{
					runLoops.splice(i, 1);
					return;
				}
			}
		}
		
		protected function runLoopTimer_timerHandler(event:TimerEvent):void
		{
//			AppManager.log("[AppRunLoopManager] RunLoop...Begin");
			
			// 当前系统时间Date对象更新
			nowSysDate = new Date();
			
			// 当前系统时间变化 +1s 
			if(nowSysTime>0){
				nowSysTime++;
			}
			
			// 执行轮询计划
			var nowTime:int = getTimer();
			for each (var runLoop:RunLoop in runLoops)
			{
				if (nowTime - runLoop.time >= runLoop.interval)
				{
					runLoop.func.call();
					runLoop.time = nowTime;
				}
			}
		}
		
		/**
		 * 定时重新核对系统时间
		 */
		private function sysTimerCheckHandler(evt:TimerEvent):void
		{
			nowSysTime = DateTimeUtil.getTimeNumForThisDate(new Date());
		}
		
	}
}

class RunLoop
{
	public var time:int;
	public var func:Function;
	public var interval:int;
}