package com.goshare.service
{
	import com.goshare.util.UrlLoader;
	
	import flash.net.URLVariables;
	
	/**
	 * 自助服务接口
	 *
	 * @author Coco
	 */
	public class HttpTradeService
	{
		public function HttpTradeService()
		{
		}
		
		private static var instance:HttpTradeService;
		
		public static function getInstance():HttpTradeService
		{
			if (!instance)
			{
				instance = new HttpTradeService();
			}
			return instance;
		}
		
		public var httpServerUrl:String;
		
		/**
		 *
		 * 获取终端信息
		 *
		 * @param termId 终端ID
		 * @param resultHandler
		 * @param faultHandler
		 *
		 */
		public function getRobotInfoData(termId:String,
										 resultHandler:Function = null,
										 faultHandler:Function = null):void
		{
			var url:String = httpServerUrl + "/tdassist/ACI0001.do";
			
			var reqMsg:Object = new Object();
			reqMsg.termId = termId;
			reqMsg.flowNo =  (new Date()).getTime() + "" + int(Math.random() * 1000);
			
			var params:URLVariables = new URLVariables();
			params.REQ_MESSAGE = JSON.stringify(reqMsg);
			
			var urlLoader:UrlLoader = new UrlLoader(resultHandler, faultHandler, 20000);
			urlLoader.loadHttpService(url, params);
		}
		
		/**
		 *
		 * 获取坐席端需要过滤的敏感词
		 *
		 * @param resultHandler
		 * @param faultHandler
		 *
		 */
		public function getClientSensitiveWords(resultHandler:Function = null,
												faultHandler:Function = null):void
		{
			var url:String = httpServerUrl + "/tdassist/ASW0001.do";
			
			var reqMsg:Object = new Object();
			reqMsg.flowNo =  (new Date()).getTime() + "" + int(Math.random() * 1000);
			
			var params:URLVariables = new URLVariables();
			params.REQ_MESSAGE = JSON.stringify(reqMsg);
			
			var urlLoader:UrlLoader = new UrlLoader(resultHandler, faultHandler, 20000);
			urlLoader.loadHttpService(url, params);
		}
		
		
		/**
		 *  获取历史记录
		 **/
		public function getHistoryInfo(termId:String,
									   resultHandler:Function = null,
									   faultHandler:Function = null):void
		{
			var url:String = httpServerUrl+"/tdassist/record0002.do";
			
			var params:URLVariables = new URLVariables();
			params.termId = termId;
			
			var urlLoader:UrlLoader = new UrlLoader(resultHandler, faultHandler);
			urlLoader.loadHttpService(url, params);
		}
		
		
		/**
		 * 发送历史记录
		 *@param date:String 要发送的数据
		 * */
		public function historyMessageSend(data:String):void
		{
			try
			{
				var reauestUrl:String = httpServerUrl+"/tdassist/record0001.do";
				
				var params:URLVariables = new URLVariables(data);
				
				var urlLoader:UrlLoader = new UrlLoader();
				urlLoader.loadHttpService(reauestUrl, params);
			} 
			catch(error:Error) 
			{
				trace("[AppService]   历史记录数据发送出现错误");
			}
		}
		
		
		/**
		 * 发送 半人工坐席的信息给后台 
		 * 智能快速检索  依据C2场景参数，缩小检索范围
		 * @param tdosToken         从tdos端获取的token
		 * @param tdosRobotStateSet     从tdos端获取的场景参数
		 * @param keyword    输入的关键字（标准问？）
		 * @param serialNo     连载号
		 */
		public function SendSEMIZAgentMessage(
											  tdosToken : String,
											  tdosRobotStateSet : Array,
											  keyword:String,
											  serialNo:Number =NaN,
											  resultHandler:Function = null,
											  faultHandler:Function = null):void
		{
			var reauestUrl:String = httpServerUrl+"/tdassist/IKN0004.do";
			
			var reqBody:Object = new Object();
			reqBody.token = tdosToken ; //令牌  注意防止过期  由tdos提供
			reqBody.uniqueCode =  (new Date()).getTime() + "" + int(Math.random() * 1000); //交互唯一码	
			reqBody.supportModel = "000300";  //支持模式码
			reqBody.serialNo = serialNo;  //知识唯一码
			
			var keywordArr:Array = [];
			keywordArr.push(keyword);
			
			reqBody.questions =  keywordArr;
			reqBody.robotStateSet = tdosRobotStateSet;
			
			var params:URLVariables = new URLVariables();
			params.REQ_MESSAGE = JSON.stringify(reqBody);
			
			var urlLoader:UrlLoader = new UrlLoader(resultHandler, faultHandler, 20000);
			urlLoader.loadHttpService(reauestUrl, params);
		}
	}
}
