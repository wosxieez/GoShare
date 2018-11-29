package com.goshare.component
{
	import flash.display.Sprite;
	
	import coco.component.Alert;
	import coco.event.UIEvent;
	import coco.manager.PopUpManager;
	
	public class AppAlert extends Alert
	{
		public function AppAlert()
		{
			super();
			
			headerHeight = 40;
			footHeight = 40;
		}
		
		override protected function createChildren():void
		{
			super.createChildren();
			
			if (okButton)
				okButton.borderAlpha = okButton.backgroundAlpha = 0;
			if (cancelButton)
				cancelButton.borderAlpha = cancelButton.backgroundAlpha = 0;
		}
		
		override protected function measure():void
		{
			super.measure();
			
			//    10  titleDisplay 10
			//             10
			//    10  textDiplay   10
			//             10
			//  cancelButton  okButton
			
			// 如果titleDisplay存在  则有标题
			
			var minWidth:Number = 250;
			var minHeight:Number = 120;
			
			// header width
			var realWidth:Number = 0;
			var realHeight:Number = 0;
			if (titleDisplay)
			{
				realWidth = titleDisplay.width + 20;
				realHeight += headerHeight;
			}
			
			realWidth = Math.max(realWidth, textDisplay.width + 20);
			realHeight += textDisplay.height + 20;
			
			if (okButton || cancelButton)
			{
				realHeight += footHeight;
			}
			
			measuredWidth = Math.max(minWidth, realWidth);
			measuredHeight = Math.max(minHeight, realHeight);
		}
		
		override protected function drawSkin():void
		{
			graphics.clear();
			graphics.beginFill(0xFFFFFF);
			graphics.drawRoundRectComplex(0, 0, width, height, 5, 5, 5, 5);
			graphics.endFill();
			
			if (okButton || cancelButton)
			{
				graphics.lineStyle(1, 0xEBEBEB);
				graphics.moveTo(0, height - footHeight);
				graphics.lineTo(width, height - footHeight);
			}
			
			if (okButton && cancelButton)
			{
				graphics.lineStyle(1, 0xEBEBEB);
				graphics.moveTo(width / 2, height - footHeight);
				graphics.lineTo(width / 2, height);
			}
			
		}
		
		public static function show(text:String = "", 
									title:String = "",
									flags:uint = 0x4 /* Alert.OK */, 
									parent:Sprite = null, 
									closeHandler:Function = null,
									closeWhenMouseClickOutside:Boolean = false):AppAlert
		{
			
			var alert:AppAlert = new AppAlert();
			alert.buttonFlags = flags;
			alert.text = text;
			alert.title = title;
			
			if (closeHandler != null)
				alert.addEventListener(UIEvent.CLOSE, closeHandler);
			
			PopUpManager.addPopUp(alert, parent, true, closeWhenMouseClickOutside);
			PopUpManager.centerPopUp(alert);
			
			return alert;
		}
		
	}
}