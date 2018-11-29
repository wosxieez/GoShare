package com.goshare.component
{
	import coco.core.UIComponent;
	
	
	/**
	 *
	 * 进度条
	 *  
	 * @author coco
	 * 
	 */	
	public class AppLoading extends UIComponent
	{
		public function AppLoading()
		{
			super();
			
			width = 300;
			height = 10;
		}
		
		
		private var _value:Number = 0;

		public function get value():Number
		{
			return _value;
		}

		public function set value(value:Number):void
		{
			_value = value;
			invalidateSkin();
		}
		
		override protected function drawSkin():void
		{
			super.drawSkin();
			
			graphics.clear();
			graphics.beginFill(0x000000, .3);
			graphics.drawRoundRectComplex(0, 0, width, height, 5, 5, 5, 5);
			graphics.endFill();
			
			graphics.beginFill(0x1CBBB1);
			graphics.drawRoundRectComplex(0, 0, width * value, height, 5, 5, 5, 5);
			graphics.endFill();
		}
		
	}
}