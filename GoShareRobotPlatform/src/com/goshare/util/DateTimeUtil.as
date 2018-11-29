package com.goshare.util
{
	import flash.globalization.DateTimeFormatter;
	import flash.globalization.DateTimeStyle;
	import flash.globalization.LocaleID;

	/**
	 * <p>时间操作工具类</p>
	 * @author Wulingbiao
	 * @langversion 1.0
	 */
	public class DateTimeUtil
	{
		/**
		 * 默认日期格式 
		 */
		public static const DEFAULT_DATE_FORMAT:String="yyyy-MM-dd";  
		/**
		 * 默认日期时间格式 
		 */
		public static const DEFAULT_DATETIME_FORMAT:String="yyyy-MM-dd HH:mm:ss";
		
		public function DateTimeUtil()
		{
		}
		
		/** 
		 * <p>格式化时间, 默认格式为yyyy-MM-dd HH:mm:ss</p> 
		 * @param date 待格式化时间
		 * @param formatString 格式字符串
		 * @return 格式化后字符串
		 */ 
		public static function formatDateTime(date:Date, formatString:String=DEFAULT_DATETIME_FORMAT):String  
		{
			var dateFormater:DateTimeFormatter=new DateTimeFormatter(LocaleID.DEFAULT, DateTimeStyle.SHORT, DateTimeStyle.LONG);
			dateFormater.setDateTimePattern(formatString); 
			return dateFormater.format(date);  
		}  
		
		/** 
		 * <p>获取传入的字符串内表示的时间的秒数，格式 "HH:MM:SS"</p> 
		 * @param formatTimeStr 格式化时间字符串
		 */ 
		public static function getTimeFromHMS(formatTimeStr:String):Number  
		{
			var result:Number = 0;
			
			var hmsSplice:Array = formatTimeStr.split(":");
			if (hmsSplice.length == 3) {
				result = parseInt(hmsSplice[0]) * 3600 + parseInt(hmsSplice[1]) * 60 + parseInt(hmsSplice[2]);
			}
			
			return result;
		}
		
		/** 
		 * <p>获取传入的时间对象内的时间秒数(仅时、分、秒)</p>
		 */ 
		public static function getTimeNumForThisDate(date:Date):Number  
		{
			var result:Number = date.getHours()*3600 + date.getMinutes()*60 + date.getSeconds();
			return result;
		}
		
		/** 
		 * <p>获取传入的时间对象内的时间秒数(仅年、月、日)</p> 
		 */ 
		public static function getDateNumForThisDate(date:Date):Number  
		{
//			var result:Number = date.getYear()*3600 + date.getMinutes()*60 + date.getSeconds();
			return 0;
		}
		
		/** 
		 * <p>获取传入的时间对象内的时间秒数(年、月、日、时、分、秒)</p> 
		 */ 
		public static function getWholeNumForThisDate(date:Date):Number  
		{
//			var result:Number = date.getYear()*3600 + date.getMinutes()*60 + date.getSeconds();
			return 0;
		}
		
	}
}