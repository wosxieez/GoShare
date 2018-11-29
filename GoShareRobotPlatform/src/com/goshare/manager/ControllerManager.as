package com.goshare.manager
{
    import com.goshare.connlib.data.SocketMessageVO;
    import com.goshare.controlservice.ControlService;
    import com.goshare.controlservice.data.ControlDataDict;
    import com.goshare.controlservice.event.ControlServiceEvent;
    import com.goshare.data.GlobalEventDict;

    /********************************************************
     *
     * 控制器C1管理
	 * 1. 初始化连接
	 * 2. 指令信息解析
     *
     ****************************************************/
    public class ControllerManager
    {
        private static var instance:ControllerManager=null;
        public static function getInstance():ControllerManager
        {
            if (!instance){
                instance = new ControllerManager();
            }
            return instance;
        }

		//-------------------------------------------------------------------------------------
		//
		//  Properties
		//
		//-------------------------------------------------------------------------------------
		// 是否已经初始化
		public var hasInit:Boolean = false;
		
		//-------------------------------------------------------------------------------------
		//
		//  Methods
		//
		//-------------------------------------------------------------------------------------
        /**
         * 初始化 - test 192.168.1.247
         */
        public function init():void
        {
			if (!hasInit) {
				ControlService.getInstance().addEventListener(ControlServiceEvent.CONTROLLER_MESSAGE, analysisHandler);
				ControlService.getInstance().addEventListener(ControlServiceEvent.CONTROLLER_SERVICE_LOG, receiveControlServiceLog);
				ControlService.getInstance().connect("127.0.0.1", 17581);
				
				hasInit = true;
			}
        }

		public function destory():void
		{
			ControlService.getInstance().removeEventListener(ControlServiceEvent.CONTROLLER_MESSAGE, analysisHandler);
			ControlService.getInstance().removeEventListener(ControlServiceEvent.CONTROLLER_SERVICE_LOG, receiveControlServiceLog);
			ControlService.getInstance().disconnect();
			
			hasInit = false;
		}
		
        /**
         * C1控制器返回信息解析
         */
        private function analysisHandler(evt:ControlServiceEvent):void
        {
            var newMsg:SocketMessageVO = evt.controllerMsg;
            log("解析C1消息：" + newMsg.type);

            switch(newMsg.type)
            {
                case ControlDataDict.TEACHERS_LIST_UPDATE: // 观看的老师清单发生更新
                {
//                    AppDataManager.getInstance().watchingTeachers = newMsg.messageContent as Array;
//                    AppManager.ApiEvtDispatcher(GlobalEventDict.TEACHERS_LIST_UPDATE_EVENT, null, GlobalEventDict.APP_SPACE);
                    break;
                }
                case ControlDataDict.TEACHER_VIDEO_STATUS_UPDATE: // 观看的某个老师打开/关闭了自己的视频
                {
//                    var teacherList:Array = AppDataManager.getInstance().watchingTeachers;
//                    for (var i:int=0; i<teacherList.length; i++) {
//                        if (teacherList[i]["agentID"] == newMsg.messageContent["agentID"]) {
//                            teacherList[i]["streamName"] = newMsg.messageContent["streamName"];
//                            break;
//                        }
//                    }
//                    AppManager.ApiEvtDispatcher(GlobalEventDict.TEACHERS_LIST_UPDATE_EVENT, null, GlobalEventDict.APP_SPACE);
                    break;
                }
                case ControlDataDict.AGENT_COURSEWARE_PLAY: // 播放课件 - 坐席指令
                {
//                    AppManager.ApiEvtDispatcher(GlobalEventDict.NOTICE, '播放课件', GlobalEventDict.APP_SPACE)
//					AppManager.ApiEvtDispatcher(GlobalEventDict.COURSEWARE_PLAY, null, GlobalEventDict.APP_SPACE);
                    break;
                }
                case ControlDataDict.AGENT_COURSEWARE_PAUSE: // 暂停课件 - 坐席指令
                {
//                    AppManager.ApiEvtDispatcher(GlobalEventDict.NOTICE, '暂停课件', GlobalEventDict.APP_SPACE)
//                    // todo 暂时不支持暂停 使用停止代替
//					AppManager.ApiEvtDispatcher(GlobalEventDict.COURSEWARE_STOP, null, GlobalEventDict.APP_SPACE);
                    break;
                }
                case ControlDataDict.AGENT_COURSEWARE_STOP: // 停止播放课件 - 坐席指令
                {
//                    AppManager.ApiEvtDispatcher(GlobalEventDict.NOTICE, '停止播放课件', GlobalEventDict.APP_SPACE);
//					AppManager.ApiEvtDispatcher(GlobalEventDict.COURSEWARE_STOP, null, GlobalEventDict.APP_SPACE);
                    break;
                }
                default:
                {
//                    AppManager.ApiEvtDispatcher(GlobalEventDict.NOTICE, newMsg.messageType, GlobalEventDict.APP_SPACE)
                    break;
                }
            }
        }

		/**
		 * 记录Gpip平台服务日志
		 */
		private function receiveControlServiceLog(evt:ControlServiceEvent):void
		{
			log(evt.logText);
		}
		
        /**
         * 输出日志
         */
        protected function log(...args):void
        {
            var arg:Array = args as Array;
            if (arg.length > 0)
            {
                AppManager.log("[ControllerManager]  " + args.join(" "));
            }
        }

    }
}