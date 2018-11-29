package com.goshare.data
{
	/******************************************
	 * 
	 * 单条聊天记录数据对象
	 * 
	 ****************************************/
	public class ItemChatVO
	{
		public function ItemChatVO()
		{
		}
		
		private var _role:String = "";
		
		/**
		 * 角色：teacher-教师；student-学生；robot-机器人
		 */
		public function get role():String
		{
			return _role;
		}
		
		/**
		 * @private
		 */
		public function set role(value:String):void
		{
			if (value == "robot") {
				this.name = "哥学";
			}
			if (value == "student" && name == "") {
				this.name = "同学";
			}
			if (value == "teacher" && name == "") {
				this.name = "老师";
			}
			_role = value;
		}
		
		/**
		 * 昵称：teacher-王老师；student-陈二狗；robot-哥学
		 */
		public var name:String = "";
		
		/**
		 * 话语具体内容
		 */
		public var content:String = "";
		
		/**
		 * 这段话是否需要进行语音播报
		 */
		public var needTTS:Boolean = false;

	}
}