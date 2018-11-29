package com.goshare.util
{
	import flash.utils.ByteArray;

	public class CloneUtil
	{
		public function CloneUtil()
		{
		}
		
		public static function clone(obj:Object):* 
		{
			var copier:ByteArray = new ByteArray();
			copier.writeObject(obj);
			copier.position = 0;
			return copier.readObject();
		}
		
	}
}