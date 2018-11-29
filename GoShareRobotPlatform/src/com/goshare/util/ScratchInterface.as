package com.goshare.util
{
import flash.events.Event;
import flash.filesystem.File;
import flash.utils.ByteArray;

public class ScratchInterface
	{
		public function ScratchInterface()
		{
		}
		
		/**
		 * 导入sb2文件
		 * @param filePath sb文件路径
		 */
		public static function loadSbFiles(filePath:String):void
		{
			Scratch.app.runtime.stopAll();

			function onComplete(event:Event):void {
				var fileName:String = loadFile.name;
				var data:ByteArray = loadFile.data;
				Scratch.app.runtime.installProjectFromFile(fileName, data);
			}

//			var loadFile:File = new File(filePath);
			var loadFile:File = File.applicationDirectory.resolvePath(filePath)
			loadFile.addEventListener(Event.COMPLETE, onComplete);
			loadFile.load();
		}
		
		/**
		 * 卸载课件sb2文件 --- 其实就是新建项目 - 老项目不保存改动
		 */
		public static function unloadSbFiles():void
		{
			Scratch.app.clearToBlankProject();
		}

	}
}