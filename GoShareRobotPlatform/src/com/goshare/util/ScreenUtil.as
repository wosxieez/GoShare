package com.goshare.util
{
import flash.display.NativeWindow;
import flash.display.Screen;

/**
	 * 屏幕辅助类
	 *  
	 * @author coco
	 * 
	 */	
	public class ScreenUtil
	{
		public function ScreenUtil()
		{
		}
		
		//--------------------------------------------------------------------------
		//
		//  Static Methods
		//
		//--------------------------------------------------------------------------
		
		/**
		 *	将 本地窗口 移至屏幕中央
		 * 
		 * @param nativeWindow 本地窗口
		 */		
		public static function moveToScreenCenter(nativeWindow:NativeWindow):void
		{
			var sx:Number = (screenWidth - nativeWindow.width) / 2;
			var sy:Number = (screenHeight - nativeWindow.height) / 2;
			
			nativeWindow.x = sx + screenX;
			nativeWindow.y = sy + screenY;
		}
		
		public static function get screenWidth():Number
		{
			return Screen.mainScreen.visibleBounds.width;
		}
		
		public static function get screenHeight():Number
		{
			return Screen.mainScreen.visibleBounds.height;
		}
		
		public static function get screenX():Number
		{
			return Screen.mainScreen.visibleBounds.x;
		}
		
		public static function get screenY():Number
		{
			return Screen.mainScreen.visibleBounds.y;
		}
		
	}
}