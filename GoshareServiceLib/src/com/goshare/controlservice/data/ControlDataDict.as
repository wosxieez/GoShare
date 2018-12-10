package com.goshare.controlservice.data
{
	/*******************************************************
	 * 
	 * 控制器Control 数据字典, 由以下部分构成: 
	 * 1. Agent坐席指令
	 * 2. 控制器Control发出的消息
	 * 
	 ***************************************************/
	public class ControlDataDict
	{
		public function ControlDataDict()
		{
		}
		
		// ------------------------------------- 控制器Control转发的坐席Z端的消息 -----------------------------
		/** 打开课件 **/
		public static const AGENT_COURSEWARE_OPEN:String = "classPlanOpen";
		/** 替换课件 **/
		public static const AGENT_COURSEWARE_REPLACE:String = "classPlanReplace";
		/** 播放课件 **/
		public static const AGENT_COURSEWARE_PLAY:String = "classPlanPlay";
		/** 暂停课件 **/
		public static const AGENT_COURSEWARE_PAUSE:String = "classPlanPause";
		/** 停止播放课件 **/
		public static const AGENT_COURSEWARE_STOP:String = "classPlanStop";
		//		/** 上一页 **/
		//		public static const TEACHER_VIDEO_STATUS_UPDATE:String = "pageToPre";
		//		/** 下一页 **/
		//		public static const TEACHER_VIDEO_STATUS_UPDATE:String = "pageToNext";
		
		
		// ------------------------------------- 控制器Control自身的消息 -----------------------------
		/** 
		 * 当前在观看的老师清单发生更新
		 * 返回当前全部清单：[{id:'000001', streamName:'0090890_201825042'}, {id:'000002', streamName:'0090251_201825042'}]
		 ***/
		public static const TEACHERS_LIST_UPDATE:String = "watchTeachersUpdate";
		
		/** 当前在观看的老师中有人打开/关闭了自己的视频 **/
		public static const TEACHER_VIDEO_STATUS_UPDATE:String = "teacherVideoStatusUpdate";
	}
}