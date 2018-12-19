package com.goshare.util
{
	import flash.display.BitmapData;
	import flash.geom.Matrix;
	import flash.utils.ByteArray;
	
	import util.Base64Encoder;
	
	public class BitmapUtil
	{
		public function BitmapUtil()
		{
		}
		
		/**
		 * 缩放位图
		 */
		public static function scaleBitmapData(bmpData:BitmapData, scaleX:Number, scaleY:Number):BitmapData
        {
            var matrix:Matrix = new Matrix();
            matrix.scale(scaleX, scaleY);
            var bmpData_:BitmapData = new BitmapData(scaleX * bmpData.width, scaleY * bmpData.height, true, 0);
            bmpData_.draw(bmpData, matrix);
            return bmpData_;
        }
		
		/**
		 * Base64字符串(jpg图片)转换为BitmapData
		 */
		private static var jpgCallbackFunc:Function;
		public static function decodeJpgBase64(baseStr:String, callback:Function=null):void
		{
			try {
				jpgCallbackFunc = callback;
				
				// 去除末尾补位的==
				while(baseStr.charAt(baseStr.length-1) == "=") {
					baseStr = baseStr.slice(0, baseStr.length-1);
				}
				
				var imgByte:ByteArray = Base64Encoder.decode(baseStr);
				if (imgByte == null) {
					trace("base64数据为空，转换失败!");
				}
				
				function reDrawCatchFaceCostum(imgData:BitmapData):void
				{
					if (jpgCallbackFunc != null) {
						jpgCallbackFunc.call(null, imgData);
					}
				}
				
				var jpgDataLoader:UrlLoader = new UrlLoader(reDrawCatchFaceCostum);
				jpgDataLoader.loadBitmapDataFromByteArray(imgByte);
			} catch (e:Error) {
				trace(e.message);
			}
		}
		
		/**
		 * base64字符串(bmp)转换为bitmapData - 未完工
		 */
		private static var bmpCallbackFunc:Function;
		public static function decodeBmpBase64(data:String, _width:Number, _height:Number, _callback:Function=null):BitmapData 
		{
			try {
				bmpCallbackFunc = _callback;
				
				// 去除末尾补位的==
				while(data.charAt(data.length-1) == "=") {
					data = data.slice(0, data.length-1);
				}
				
				var imgByte:ByteArray = Base64Encoder.decode(data);
				if (imgByte == null) {
					trace("base64数据为空，转换失败!");
					return null;
				}
				
//				if(imgByte.length <  6){  
//	                throw new Error("bytes参数为无效值!");  
//	            }
//	            imgByte.position = imgByte.length - 1;  
//	            var transparent:Boolean = imgByte.readBoolean();  
//	            imgByte.position = imgByte.length - 3;  
//	            var height:int = imgByte.readShort();  
//	            imgByte.position = imgByte.length - 5;  
//	            var width:int = imgByte.readShort();  
//	            imgByte.position = 0;  
//	            var datas:ByteArray = new ByteArray();            
//	            imgByte.readBytes(datas,0,imgByte.length - 5);
//				trace("======= width: " + width + "			height:" + height)
//	            var bmp:BitmapData = new BitmapData(width,height,transparent,0);  
//	            bmp.setPixels(new Rectangle(0,0,width,height),datas); 
				
//				imgByte.position = 0;
//				var bmp:BitmapData = new BitmapData(_width, _height);
//				bmp.setPixels(new Rectangle(0, 0, _width, _height), imgByte);
//				return bmp;
				
				function reDrawCatchFaceCostum(imgData:BitmapData):void
				{
					if (bmpCallbackFunc) {
						bmpCallbackFunc(imgData);
					}
				}
				
				function loadCommandsListFail(failReason:String):void
				{
				}
				
				var jpgDataLoader:UrlLoader = new UrlLoader(reDrawCatchFaceCostum, loadCommandsListFail, 10000);
				jpgDataLoader.loadBitmapDataFromByteArray(imgByte);
			} catch (e:Error) {
				trace(e.message);
			}
			
			return null;
		}
		
		/**
		 * bitmapData转换为base64字符串
		 */
		public static function encodeBmpToBase64Str(data:BitmapData):String {
			if(data == null){
				throw new Error("data参数不能为空!");
			}
			var bytes:ByteArray = data.getPixels(data.rect);
			bytes.writeShort(data.width);
			bytes.writeShort(data.height);
			bytes.writeBoolean(data.transparent);
			bytes.compress();
			
			return Base64Encoder.encode(bytes);
		}
		
	}
}