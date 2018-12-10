package com.goshare.gpipservice.data
{
	public class GpipDataParam
	{
		public function GpipDataParam()
		{
		}
		
		// ------------------------------------ 平台通信报文内 - key -----------------------------
		/**初始化**/
		public static var CMD_INIT:String = "Init";
		public static var CMD_INIT_TYPE:String = "31018";
		
		/**注销服务**/
		public static var CMD_UNINIT:String = "Uninit";
		public static var CMD_UNINIT_TYPE:String = "31036";
		
		/**心跳包**/
		public static var CMD_HEART:String = "HeartBeat";
		public static var CMD_HEART_TYPE:String = "31000";
		
		/**平台切换服务**/
		public static var CMD_SWITCHNOTIFY:String = "SwitchNotify";
//		public static var CMD_SWITCHNOTIFY_TYPE:String = "31024";
		
		/**前端切换服务**/
		public static var CMD_SWITCH:String = "Switch";
		public static var CMD_SWITCH_TYPE:String = "31016";
		
		/**状态准备完毕**/
		public static var CMD_READY:String = "Ready";
		public static var CMD_READY_TYPE:String = "31026";
		
		/**事件通知服务**/
		public static var CMD_EVENTNOTIFY:String = "EventNotify";
//		public static var CMD_EVENTNOTIFY_TYPE:String = "31028";
		
		/**自定义服务**/
		public static var CMD_CUSTOM:String = "CustomEvent";
		public static var CMD_CUSTOM_TYPE:String = "31034";
		
		/**获取数据服务**/
		public static var CMD_GETDATA:String = "GetData";
		public static var CMD_GETDATA_TYPE:String = "31030";
		
		/**设置数据服务**/
		public static var CMD_SETDATA:String = "SetData";
		public static var CMD_SETDATA_TYPE:String = "31032";
		
		/**注册服务**/
		public static var CMD_REG:String = "RegServiceEvent";
		public static var CMD_REG_TYPE:String = "31006";
		
		/**反注册服务**/
		public static var CMD_UNREG:String = "UnregServiceEvent";
		public static var CMD_UNREG_TYPE:String = "31008";
		
		// ------------------------------------ 平台Service服务清单(库工程内使用) -----------------------------
		/** ASR模式设置：在线/离线 **/
		public static var ASR_MODE_SET_SERVICE:String = "EventOfSetAsrModeService";
		/** ASR方言设置：0-普通话；1-粤语 **/
		public static var ASR_DIALECTS_SET_SERVICE:String = "EventOfSetAsrAccentService";
		/** TTS模式设置：在线/离线 **/
		public static var TTS_MODE_SET_SERVICE:String = "EventOfSetTtsModeService";
		/** TTS发音人设置：jiajia/mengmeng **/
		public static var TTS_SPEAKER_SET_SERVICE:String = "EventOfSetTtsSpeakerService";
		/** 播放指定字符串 **/
		public static var TTS_SPEAK_SERVICE:String = "EventOfPlayCustomText";
		/** 跟读服务 **/
		public static var KEYWORD_FOLLOW_UP_SERVICE:String = "EventOfFollowUpRequest";
		
		/** 场景同步服务 **/
		public static var GPIP_SCENE_SYNCHRO:String = "EventOfStatusInfoSync";
		
		// ------------------------------------ 平台回应事件清单(库工程内使用)  -----------------------------
		/** 对话信息事件 **/
		public static var CHAT_INFO_BACK_EVENT:String = "EventOfAnswerType";
		/** 语音指令事件 **/
		public static var CHAT_COMMAND_EVENT:String = "EventOfBusinessPass";
		/** 跟读结果事件 - 结果回应 **/
		public static var FOLLOW_UP_RESULT_EVENT:String = "EventOfFollowUpResponse";
		
		// ------------------------------- 库工程对外事件 ----------------------
		/** 查询数据结果 **/
		public static const GPIP_DATA_GET_CALLBACK:String = "gpipGetDataResultEvent";
		
		/** 存储数据结果 **/
		public static const GPIP_DATA_SET_CALLBACK:String = "gpipSetDataResultEvent";
		
		/** 识别到人脸变化(人来/人走) **/
		public static const FACE_INFO_CHANGE_EVENT:String = "EventOfFaceInfo";
		
		/** 上课铃声响起 **/
		public static const CLASS_BEGIN_RING_EVENT:String = "classBeginRingEvent";
		/** 下课铃声响起 **/
		public static const CLASS_END_RING_EVENT:String = "classEndRingEvent";
		
		/** 语义库指令 - 现在上课 **/
		public static const COMMAND_CLASS_BEGIN_EVENT:String = "begin_to_be_in_class";
		/** 语义库指令 - 现在下课 **/
		public static const COMMAND_CLASS_END_EVENT:String = "begin_to_be_outside_class";
		/** 语义库指令 - 继续上课 - 二期 **/
		public static const COMMAND_CLASS_CONTINUE_EVENT:String = "commandClassContinueEvent";
		/** 语义库指令 - 开始讲课 **/
		public static const COMMAND_LESSON_BEGIN_EVENT:String = "begin_to_exe_courseware";
		/** 语义库指令 - 停止讲课 **/
		public static const COMMAND_LESSON_END_EVENT:String = "end_to_exe_courseware";
		/** 语义库指令 - 显示课件窗口 **/
		public static const COMMAND_LESSON_SHOW_EVENT:String = "open_courseware_window";
		/** 语义库指令 - 关闭课件窗口 **/
		public static const COMMAND_LESSON_HIDE_EVENT:String = "close_courseware_window";
		/** 语义库指令 - 音量变大 **/
		public static const COMMAND_VOLUME_UP_EVENT:String = "increase_volume";
		/** 语义库指令 - 音量变小 **/
		public static const COMMAND_VOLUME_DOWN_EVENT:String = "decrease_volume";
		/** 语义库指令 - 关闭表情窗口 **/
		public static const COMMAND_FACE_HIDE_EVENT:String = "close_face_window";
		/** 语义库指令 - 显示表情窗口 **/
		public static const COMMAND_FACE_SHOW_EVENT:String = "open_face_window";

	}
}