package com.goshare.data
{
	/************************************
	 * 
	 * 场景内容数据模型
	 * 
	 ***********************************/
	public class SceneContentVO
	{
		public function SceneContentVO(inParam:Object)
		{
			this._id = inParam["id"];
			this._desc = inParam["desc"];
			this._sceneName = inParam["sceneName"];
			this._teacherID = inParam["teacherID"];
			this._teacherName = inParam["teacherName"];
			this._playBookID = inParam["playBookID"];
			this._beginTime = inParam["beginTime"];
			this._endTime = inParam["endTime"];
		}
		
		/**
		 * 获取本对象的克隆体
		 */
		public function cloneMe():SceneContentVO
		{
			var newVO:SceneContentVO = new SceneContentVO(this);
			return newVO;
		}
		
		private var _id:String = "";
		private var _desc:String = "";
		private var _sceneName:String = "";
		private var _teacherID:String = "";
		private var _teacherName:String = "";
		private var _playBookID:String = "";
		private var _beginTime:Number = 0;
		private var _endTime:Number = 0;
		
		/**
		 * 场景ID
		 */
		public function get id():String
		{
			return _id;
		}

		/**
		 * 场景描述："晨读"、"第二节课" ....
		 */
		public function get desc():String
		{
			return _desc;
		}

		/**
		 * 场景类型(与SceneConfig.xml配置中的name字段对应)："classFinish"、"classIng" ....
		 */
		public function get sceneName():String
		{
			return _sceneName;
		}

		/**
		 * 场景教师ID：课程中 - 本节课任课老师；下课状态 - 下节课任课老师
		 */
		public function get teacherID():String
		{
			return _teacherID;
		}

		/**
		 * 场景教师名字：课程中 - 本节课任课老师；下课状态 - 下节课任课老师
		 */
		public function get teacherName():String
		{
			return _teacherName;
		}

		/**
		 * 场景要使用的课件ID
		 */
		public function get playBookID():String
		{
			return _playBookID;
		}

		/**
		 * 场景开始时间
		 */
		public function get beginTime():Number
		{
			return _beginTime;
		}

		/**
		 * 场景结束时间
		 */
		public function get endTime():Number
		{
			return _endTime;
		}


	}
}