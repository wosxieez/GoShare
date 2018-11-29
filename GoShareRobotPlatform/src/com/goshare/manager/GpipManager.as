package com.goshare.manager
{
	import com.goshare.data.GlobalEventDict;
	import com.goshare.event.EventExchangeEvent;
	import com.goshare.gpipservice.GpipService;
	import com.goshare.gpipservice.data.GpipDataParam;
	import com.goshare.gpipservice.event.GpipEvent;
	
	import flash.events.EventDispatcher;
	
	import blocks.Block;
	
	import scratch.ScratchObj;

	/********************************************************
	 *
	 * 平台Gpip管理
	 * 1. 初始化连接
	 * 2. 指令信息转发
	 * 3. 指令信息解析(部分)
	 * 		3.1 人脸识别结果分析处理 <br/>
     * 		3.2 对话记录信息处理 <br/>
     * 		3.3 语义指令的分析处理 <br/>
	 *
	 ****************************************************/
	public class GpipManager extends EventDispatcher
	{
		private static var instance:GpipManager=null;
		public static function getInstance():GpipManager
		{
			if (!instance){
				instance = new GpipManager();
			}
			return instance;
		}
		
		public function GpipManager() 
		{
			this.app = Scratch.app;
		}
		
		//-------------------------------------------------------------------------------------
		//
		//  Properties
		//
		//-------------------------------------------------------------------------------------
		private var app:Scratch;
		// 是否已经初始化
		public var hasInit:Boolean = false;
		// 当前人脸识别到的用户
		private var currentFaceUser: Object;
		
		//-------------------------------------------------------------------------------------
		//
		//  Methods
		//
		//-------------------------------------------------------------------------------------
		/**
		 * 初始化
		 */
		public function init():void
		{
			if (!hasInit) {
				// 添加监听 - 人脸识别事件
				AppManager.ApiEvtRegister(this, GpipDataParam.FACE_INFO_CHANGE_EVENT, peopleFaceInfoChangeHandler, GlobalEventDict.APP_SPACE);
				// 添加监听 - 对话记录信息
				AppManager.ApiEvtRegister(this, GpipDataParam.CHAT_INFO_BACK_EVENT, gpipReturnChatInfo, GlobalEventDict.APP_SPACE);
				// 添加监听 - 语音指令
				AppManager.ApiEvtRegister(this, GpipDataParam.CHAT_COMMAND_EVENT, asrCommandHandler, GlobalEventDict.APP_SPACE);
				
				GpipService.getInstance().addEventListener(GpipEvent.GPIP_SERVICE_EVENT, receiveGpipEvent);
				GpipService.getInstance().addEventListener(GpipEvent.GPIP_SERVICE_LOG_EVENT, receiveGpipLogEvent);
				GpipService.getInstance().init("127.0.0.1", 9090);
//				GpipService.getInstance().init('192.168.1.247', 19090);
				
				hasInit = true;
			}
		}
		
		public function destory():void
		{
			// 取消监听 - 人脸识别事件
			AppManager.ApiEvtUnRegister(GpipDataParam.FACE_INFO_CHANGE_EVENT, GlobalEventDict.APP_SPACE);
			// 取消监听 - 对话记录信息
			AppManager.ApiEvtUnRegister(GpipDataParam.CHAT_INFO_BACK_EVENT, GlobalEventDict.APP_SPACE);
			// 取消监听 - 语音指令
			AppManager.ApiEvtUnRegister(GpipDataParam.CHAT_COMMAND_EVENT, GlobalEventDict.APP_SPACE);
			
			GpipService.getInstance().removeEventListener(GpipEvent.GPIP_SERVICE_EVENT, receiveGpipEvent);
			GpipService.getInstance().removeEventListener(GpipEvent.GPIP_SERVICE_LOG_EVENT, receiveGpipLogEvent);
			GpipService.getInstance().dispose();
			
			hasInit = false;
		}
		
		// -----------------------------  指令信息转发 ------------------------------------
		/**
		 * Gpip平台服务事件转发
		 */
		private function receiveGpipEvent(evt:GpipEvent):void
		{
			if (evt.eventName && evt.eventName != "") {
				AppManager.ApiEvtDispatcher(evt.eventName, evt.eventParam, GlobalEventDict.APP_SPACE);
			}
		}
		
		// -----------------------------  部分指令信息解析 start ------------------------------------
		/**
		 * 发现人脸信息变更
		 */
		private function peopleFaceInfoChangeHandler(evt:EventExchangeEvent):void
		{
			try {
				if (evt.exchangeData["recognition"] == 1) {
					// 有人来到
					if (evt.exchangeData["face_num"] == 1) {
						// 熟人 - 人脸信息已注册
	//					"face":[{"track_id":16,"gender":1,"age":27,"token_id":1999,"person_name":"刘国敏","personId":"16","type":"","id_card":"","duty":"{\"role\":\"20180905151931335\",\"roleName\":\"老师\",\"subject\":\"null\",\"subjectName\":\"null\",\"grade\":\"000000093\",\"gradeName\":\"一年级\",\"teachClasses\":\"000000095\",\"teachClassesName\":\"101班\"}"}]
	//					"face":[{"token_id":41,"gender":1,"id_card":"","track_id":32,"work":"","person_name":"吴凌彪","personId":"32","age":27,"type":"","duty":"{\"role\":\"20180905152137041\",\"roleName\":\"学生\",\"subject\":\"null\",\"subjectName\":\"null\",\"grade\":\"000000093\",\"gradeName\":\"一年级\",\"teachClasses\":\"000000095\",\"teachClassesName\":\"101班\"}"}]}]
						var face:Object = evt.exchangeData.face[0];
						if (currentFaceUser && currentFaceUser.personId == face.personId) {
							// 同一个用户 不做提示
						} else {
							currentFaceUser = face;
							peopleNearHandler(true, face);
						}
					} else {
						// 陌生人
						peopleNearHandler(false);
					}
				} else {
					// 用户离开
					currentFaceUser = null;
					peopleLeaveHandler();
				}
			} catch (e: Error) {
				// 用户离开
				currentFaceUser = null;
				peopleLeaveHandler();
			}
		}
		
		/**
		 * 检测到用户来到
		 * @param isRegister 用户人脸数据是否已注册
		 * @param faceInfo 如果已注册，人脸信息
		 */
		private function peopleNearHandler(isRegister:Boolean, faceInfo:Object=null):void
		{
			if (isRegister) {
				// 熟人来到
				if (faceInfo) {
					faceInfo["isStranger"] = false;
				} else {
					faceInfo = {isStranger:false};
				}
			} else {
				// 陌生人来到
				faceInfo = {isStranger:false};
			}
			
			// 存储到全局信息里
			app.runtime.currentFaceInfo = faceInfo;
			// 当前人脸数量
			app.runtime.currentFacesNum = 1;
			
			// 触发所有监听block
			function findPeopleFaceNearOp(stack:Block, target:ScratchObj):void {
				// 省去无谓的计算，这里只处理事件函数且有后续处理的Block
				if (!stack.isHat || !stack.nextBlock) return;

				if (stack.op == 'peopleFaceNear') {
					app.interp.toggleThread(stack, target);
				}
				if (stack.op == 'designatedPersonNear') {
					var iwantName:String = String(app.interp.arg(stack, 0));
					if (iwantName == faceInfo["person_name"]) {
						app.interp.toggleThread(stack, target);
					}
				}
			}
			app.runtime.allStacksAndOwnersDo(findPeopleFaceNearOp);
		}
		
		/**
		 * 检测到用户离开
		 */
		private function peopleLeaveHandler():void
		{
			// 存储到全局信息里
			app.runtime.currentFaceInfo = null;
			// 当前人脸数量
			app.runtime.currentFacesNum = 0;
			// 触发所有监听block
			function findPeopleFaceLeaveOp(stack:Block, target:ScratchObj):void {
				// 省去无谓的计算，这里只处理事件函数且有后续处理的Block
				if (!stack.isHat || !stack.nextBlock) return;

				if (stack.op == 'peopleFaceLeave') {
					app.interp.toggleThread(stack, target);
				}
			}
			app.runtime.allStacksAndOwnersDo(findPeopleFaceLeaveOp);
		}
		
		/**
		 * 平台返回对话信息
		 */
		private function gpipReturnChatInfo(evt:EventExchangeEvent):void
		{
			var chatInfo:Object = evt.exchangeData;
			
			var personSaid:String = chatInfo["text"];
			var robotSaid:String = "";
			// answer_total 字段是对answer_best的补充，针对文本长度特别长的情况，有该字段则优先
			if(chatInfo.hasOwnProperty("answer_total")){
				robotSaid = chatInfo["answer_total"];
			}else{
				robotSaid = chatInfo["answer_best"];
			}
			
			// 触发所有监听block
			function findTalkInfoListener(stack:Block, target:ScratchObj):void {
				// 省去无谓的计算，这里只处理事件函数且有后续处理的Block
				if (!stack.isHat || !stack.nextBlock) return;
				
				if (stack.op == 'hearPeopleSaid') {
					// 这个block想听 来人说的话
					if (personSaid && personSaid.length > 0) {
						stack.inputParameter = personSaid;
						app.interp.toggleThread(stack, target);
					}
				}
				if (stack.op == 'hearRobotSaid') {
					// 这个block想听 机器人说的话
					if (robotSaid && robotSaid.length > 0) {
						stack.inputParameter = robotSaid;
						app.interp.toggleThread(stack, target);
					}
				}
				if (stack.op == 'whenPeopleAsk') {
					// 这个Block想听到 来人说指定的话语
					var questionText:String = app.interp.arg(stack, 0) as String;
					if (questionText == personSaid) {
						app.interp.toggleThread(stack, target);
					}
				}
			}
			app.runtime.allStacksAndOwnersDo(findTalkInfoListener);
		}
		
		/**
		 * 语音库返回语义指令处理
		 */
		private function asrCommandHandler(evt:EventExchangeEvent):void
		{
			// TODO 暂时取commands[0] 可能有复杂情况 need to do here
			try {
				var command:String = evt.exchangeData.commands[0];
				var cmdDesc:String = AppDataManager.getInstance().getCmdDescByName(command);
			} catch (e: Error) {
				throw new Error('解析指令失败')
			}
			
			// 触发所有监听block
			function findListenCommandsBlock(stack:Block, target:ScratchObj):void {
				// 省去无谓的计算，这里只处理事件函数且有后续处理的Block
				if (!stack.isHat || !stack.nextBlock) return;

				if (stack.op == 'whenReceiveCommands') {
					// 这个Block想听到特定的指令
					var commandsText:String = stack.args[0].argValue.toLowerCase();;
					if (commandsText == cmdDesc) {
						app.interp.toggleThread(stack, target);
					}
				}
			}
			app.runtime.allStacksAndOwnersDo(findListenCommandsBlock);
		}
		
		// -----------------------------  部分指令信息解析 end ------------------------------------
		
		/**
		 * 记录Gpip平台服务日志
		 */
		private function receiveGpipLogEvent(evt:GpipEvent):void
		{
			AppManager.log("[GpipManager]  " + evt.logInfo);
		}
		
	}
}