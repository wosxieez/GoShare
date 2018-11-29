/*
 * Scratch Project Editor and Player
 * Copyright (C) 2014 Massachusetts Institute of Technology
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License
 * as published by the Free Software Foundation; either version 2
 * of the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
 */

// MotionAndPenPrims.as
// John Maloney, April 2010
//
// Scratch motion and pen primitives.

package primitives {
    
    import com.goshare.gpipservice.GpipService;
    import com.goshare.manager.AppDataManager;
    import com.goshare.manager.AppRunLoopManager;
    import com.goshare.manager.ControllerManager;
    import com.goshare.manager.GpipManager;
    
    import flash.utils.Dictionary;
    import flash.utils.setTimeout;
    
    import blocks.Block;
    
    import interpreter.Interpreter;
    
    import scratch.ScratchObj;
    
    import uiwidgets.DialogBox;

    public class GoSharePrims {

        private var app:Scratch;
        private var interp:Interpreter;

        public function GoSharePrims(app:Scratch, interpreter:Interpreter) {
            this.app = app;
            this.interp = interpreter;
        }

        public function addPrimsTo(primTable:Dictionary):void {
			primTable["loadProjectComplete"] = loadProjectComplete;
            primTable["connectGpip"] = connectGpip;
            primTable["connectControler"] = connectControler;
			primTable["designatedPersonNear"] = interp.primNoop;
			primTable["peopleFaceNear"] = interp.primNoop;
			primTable["peopleFaceLeave"] = interp.primNoop;
			primTable["getPeopleIdentity"] = getCurrPeopleIndentity;
			primTable["getPeopleName"] = getCurrPeopleName;
			primTable["faceFuncOpenAndClose"] = faceFuncOpenAndClose;
			primTable["asrFuncOpenAndClose"] = asrFuncOpenAndClose;
			primTable["waitCommands"] = changeToWaitCommands;
			primTable["cameraOpenAndClose"] = cameraOpenAndClose;
			primTable["screenOpenAndClose"] = screenOpenAndClose;
			primTable["hearPeopleSaid"] = hearPeopleSaidEventHandle;
			primTable["hearRobotSaid"] = hearRobotSaidEventHandle;
			primTable["peopleSaidTxt"] = function(b:*):* { return app.runtime.lastPeopleSaid};
			primTable["robotSaidTxt"] = function(b:*):* { return app.runtime.lastRobotSaid};
			primTable["volumeIncrease"] = volumeIncreaseHandler;
			primTable["volumeDecrease"] = volumeDecreaseHandler;
            primTable["robotSaid"] = primGoShareTTS;
			primTable["robotAskAndWait"] = robotAskAndWaitHandler;
			primTable["peopleAnswer"] = function(b:*):* { return app.runtime.lastPeopleAnswer };
			primTable["include"] = includeRelationJudge;
			
			primTable["showExpression"] = showFaceExpreesion;
			primTable["whenShowExpression"] = interp.primNoop;
			
			primTable["currentFacesNum"] = function(b:*):* { return app.runtime.currentFacesNum};
			
			primTable["whenPeopleAsk"] = interp.primNoop;
            primTable["whenTimeUp"] = interp.primNoop;
			primTable["whenReceiveCommands"] = interp.primNoop;
			
            primTable["switchScene"] = noticeSwitchSceneHandler;
            primTable["currentScene"] = getCurrentSceneHandler;
			primTable["whenReceiveSwitchScene"] = interp.primNoop;
			
			primTable["faceIsExist"] = function(b:*):* { return app.runtime.currentFaceInfo? true:false};
			primTable["faceIsLeave"] = function(b:*):* { return !app.runtime.currentFaceInfo};
			
//            primTable["goSharePDF:"] = primGoSharePDF;
//            primTable["goShareSWF:"] = primGoShareSWF;
//            primTable["goShareMove:"] = primGoShareSWF;
//            primTable["classPlan:"] = classPlan;
			
			// 按理来说 应该在 当"编辑区有 whenTimeUp 的Block块存在时候再添加该监控" - 节省资源开销
			AppRunLoopManager.getInstance().addRunLoop(whenTheTimeIsUp);
        }

		private function loadProjectComplete(b:*):void {
			trace('工程加载完毕 - start ！')
//			createGlobalVarOrList(false, "来人身份");
//			createGlobalVarOrList(false, "来人名字");
			trace('工程加载完毕 - end ！')
		}
		
		/**
		 * 发起GPIP平台连接
		 */
        private function connectGpip(b:Block):void {
            trace('do connectGpip start');
			GpipManager.getInstance().init();
			trace('do connectGpip end');
        }

		/**
		 * 发起控制器连接
		 */
		private function connectControler(b:Block):void {
			trace('do connectControler start');
			ControllerManager.getInstance().init();
			trace('do connectControler end');
		}
		
		/**
		 * 机器人进行文本播报
		 */
		private function primGoShareTTS(b:Block):void {
			trace('do tts start ')
			GpipService.getInstance().tts(interp.arg(b, 0));
			trace('do tts end ')
		}
		
		/**
		 * 当 XX 时间到了: 每秒检查一次
		 */
		private function whenTheTimeIsUp():void {
			// 触发所有监听block
			function findTimeUpBlockEverySecond(stack:Block, target:ScratchObj):void {
				// 省去无谓的计算，这里只处理事件函数且有后续处理的Block
				if (!stack.isHat || !stack.nextBlock) return;

				if (stack.op == 'whenTimeUp') {
					var waitHourNum:int = parseInt(interp.arg(stack, 0));
					var waitMinuteNum:int = parseInt(interp.arg(stack, 1));
					var hourNum:int = AppRunLoopManager.getInstance().nowSysDate.hours;
					var minuteNum:int = AppRunLoopManager.getInstance().nowSysDate.minutes;
					var secondsNum:int = AppRunLoopManager.getInstance().nowSysDate.seconds;
					if (waitHourNum == hourNum && waitMinuteNum == minuteNum && secondsNum == 0) {
						// 到了要等待的时间点了
						app.interp.toggleThread(stack, target);
					}
				}
			}
			app.runtime.allStacksAndOwnersDo(findTimeUpBlockEverySecond);
		}
		
		/**
		 * 机器人问并等待答复
		 */
		private function robotAskAndWaitHandler(b:Block):void
		{
			if (app.runtime.waitPeopleAnswer) {
				interp.doYield();
				return;
			}
			var question:String = interp.arg(b, 0) as String;
			trace("robot ask and wait , question : " + question);
			app.runtime.robotAskQuestion(question);
			setTimeout(test, 5000);
		}
		
		private function test():void
		{
			app.runtime.hideRobotAskPrompt("我叫李白111");
		}
	
		/**
		 * 查询用户回答内容
		 */
		private function getPeopleAnswer():String
		{
			return app.runtime.lastPeopleAnswer;
		}
		
		/**
		 * 获取当前来人身份
		 */
		public function getCurrPeopleIndentity(b:Block):String
		{
			var peopleInfo:Object = app.runtime.currentFaceInfo;
			
			if (peopleInfo) {
				if (peopleInfo["isStranger"]) {
					// 陌生人 - 无身份
					return "陌生人";
				} else {
					// 已注册  - 有身份
					var duty:Object = JSON.parse(peopleInfo["duty"]);
					return duty.roleName;
				}
			} else {
				return "陌生人";
			}
		}
		
		/**
		 * 获取当前来人姓名
		 */
		public function getCurrPeopleName(b:Block):String
		{
			var peopleInfo:Object = app.runtime.currentFaceInfo;
			
			if (peopleInfo) {
				if (peopleInfo["isStranger"]) {
					// 陌生人 - 无身份
					return "";
				} else {
					// 已注册  - 有身份
					return peopleInfo["person_name"];
				}
			} else {
				return "";
			}
		}
		
		/**
		 * 开启/关闭 人脸识别功能
		 */
		private function faceFuncOpenAndClose(b:Block):void
		{
			var newState:String = interp.arg(b, 0) as String;
			
			if (newState == "打开") {
				trace("打开人脸识别");
			}
			if (newState == "关闭") {
				trace("关闭人脸识别");
			}
		}
		
		/**
		 * 开启/关闭 语音识别功能
		 */
		private function asrFuncOpenAndClose(b:Block):void
		{
			var newState:String = interp.arg(b, 0) as String;
			
			if (newState == "打开") {
				trace("打开语音识别");
			}
			if (newState == "关闭") {
				trace("关闭语音识别");
			}
		}
		
		/**
		 * 开启/关闭 摄像头
		 */
		private function cameraOpenAndClose(b:Block):void
		{
			var newState:String = interp.arg(b, 0) as String;
			
			if (newState == "打开") {
				trace("打开摄像头");
			}
			if (newState == "关闭") {
				trace("关闭摄像头");
			}
		}
		
		/**
		 * 开启/关闭 屏幕
		 */
		private function screenOpenAndClose(b:Block):void
		{
			var newState:String = interp.arg(b, 0) as String;
			
			if (newState == "打开") {
				trace("打开屏幕");
			}
			if (newState == "关闭") {
				trace("关闭屏幕");
			}
		}
		
		/**
		 * 音量增大
		 */
		private function volumeIncreaseHandler(b:Block):void
		{
			var num:int = parseInt(interp.arg(b, 0));
			trace("音量增大值：" + num);
		}
		
		/**
		 * 音量减小
		 */
		private function volumeDecreaseHandler(b:Block):void
		{
			var num:int = parseInt(interp.arg(b, 0));
			trace("音量减小值：" + num);
		}
		
		/**
		 * 平台识别到来人说话
		 */
		private function hearPeopleSaidEventHandle(b:Block):void
		{
			trace("======== 我听到了来人说话：" + b.inputParameter);
			app.runtime.lastPeopleSaid = String(b.inputParameter);
		}
		
		/**
		 * 平台返回  机器人 说话
		 */
		private function hearRobotSaidEventHandle(b:Block):void
		{
			trace("======== 机器人说的话： " + b.inputParameter);
			app.runtime.lastRobotSaid = String(b.inputParameter);
		}
		
		/**
		 * 开始等待指令
		 */
		private function changeToWaitCommands(b:Block):void
		{
			trace("原地等待指令！");
		}
		
		/**
		 * 包含关系判定
		 * 只能进行文本字符串类型计算：
		 */
		private static const emptyDict:Dictionary = new Dictionary();
		private static var lcDict:Dictionary = new Dictionary();
		private function includeRelationJudge(b:Block):Boolean
		{
			var a1:* = interp.arg(b, 0);
			var a2:* = interp.arg(b, 1);
			
			// This is static so it can be used by the list "contains" primitive.
			var n1:Number = Interpreter.asNumber(a1);
			var n2:Number = Interpreter.asNumber(a2);
			// X != X is faster than isNaN()
			if (n1 != n1 || n2 != n2) {
				// Suffix the strings to avoid properties and methods of the Dictionary class (constructor, hasOwnProperty, etc)
				if (a1 is String && emptyDict[a1]) a1 += '_';
				if (a2 is String && emptyDict[a2]) a2 += '_';
	
				// at least one argument can't be converted to a number: compare as strings
				var s1:String = lcDict[a1];
				if(!s1) s1 = lcDict[a1] = String(a1).toLowerCase();
				var s2:String = lcDict[a2];
				if(!s2) s2 = lcDict[a2] = String(a2).toLowerCase();
				return s1.indexOf(s2) >= 0;
			} else {
				// compare as numbers
				return false;
			}
			return false;
		}
		
		
		/**
		 * 通知做出XX表情
		 */
		private function showFaceExpreesion(b:Block):void
		{
			var face:String = interp.arg(b, 0) as String;
			
			// 触发所有监听block
			function findBlockToShowExpression(stack:Block, target:ScratchObj):void {
				// 省去无谓的计算，这里只处理事件函数且有后续处理的Block
				if (!stack.isHat || !stack.nextBlock) return;

				if (stack.op == 'whenShowExpression') {
					var waitExpression:String = interp.arg(stack, 0) as String;
					if (waitExpression == face) {
						app.interp.toggleThread(stack, target);
					}
				}
			}
			app.runtime.allStacksAndOwnersDo(findBlockToShowExpression);
		}
		
		/**
		 * 通知切换场景
		 */
		private function noticeSwitchSceneHandler(b:Block):void
		{
			var sceneDesc:String = String(interp.arg(b, 0));
			
			// 平台/语义库 状态同步
			var sceneName:String = AppDataManager.getInstance().getSceneNameByDesc(sceneDesc);
			GpipService.getInstance().switchGpipScene(sceneName);

			// 触发所有监听block
			function findBlockWhenReciveSwitchScene(stack:Block, target:ScratchObj):void {
				// 省去无谓的计算，这里只处理事件函数且有后续处理的Block
				if (!stack.isHat || !stack.nextBlock) return;

				if (stack.op == 'whenReceiveSwitchScene') {
					var waitDesc:String = String(interp.arg(stack, 0));
					if (waitDesc == sceneDesc) {
						app.runtime.currentSceneDesc = waitDesc;
						app.interp.toggleThread(stack, target);
					}
				}
			}
			app.runtime.allStacksAndOwnersDo(findBlockWhenReciveSwitchScene);
		}
		
		/**
		 * 获取当前场景
		 */
		private function getCurrentSceneHandler(b:Block):String
		{
			return app.runtime.currentSceneDesc;
		}
		
		private function primGoSharePDF(b:Block):void {
			trace('do tts')
			GpipService.getInstance().tts(interp.arg(b, 0))
		}
		
		private function primGoShareSWF(b:Block):void {
			trace('do tts')
			GpipService.getInstance().tts(interp.arg(b, 0))
		}
		
        private function classPlan(b:Block):void {
            trace('do classPlan')
			GpipService.getInstance().tts('收到课程计划 ' +  interp.arg(b, 0) + '要上' + interp.arg(b, 1) + '课')
        }

		/**
		 * 设置全局变量 （在变量区域内，用户可删除） - 该功能待定
		 * @param isList 变量是否为列表数据
		 * @param name 变量名
		 */
		public function createGlobalVarOrList(isList:Boolean, name:String):void 
		{
			var obj:ScratchObj = isList? app.viewedObj() : app.stageObj();
			if (obj.hasName(name)) {
				DialogBox.notify("Cannot Add", "That name is already in use.");
				return;
			}
			var variable:* =  (isList? obj.lookupOrCreateList(name):obj.lookupOrCreateVar(name));
			app.runtime.showVarOrListFor(name, isList, obj);
			app.setSaveNeeded();
		}
		
    }}
