package com.goshare.manager
{
    import com.goshare.util.LoggerUtils;
    
    import flash.events.EventDispatcher;
    
    /**
     *
     * <p>APP管理中心</p>
     * 		事件框架动作定义<br/>
     * <br/>
     */
    public class AppManager extends EventDispatcher
    {

        private static  var _instance:AppManager;

        public static function getInstance():AppManager
        {
            if (!_instance) {
                _instance = new AppManager();
            }
            return _instance;
        }

        //-------------------------------------------------------------------------------------
        //
        //  Properties
        //
        //-------------------------------------------------------------------------------------

        //-------------------------------------------------------------------------------------
        //
        //  Methods
        //
        //-------------------------------------------------------------------------------------
        public function init():void
        {
			// Gpip平台管理器初始化
//			GpipManager.getInstance().init();
			// C1控制器管理器初始化
//            ControllerManager.getInstance().init();
			// 场景管理器初始化
//			AppSceneManager.getInstance().init();
			// 主课程表初始化
//			TeachingScheduleManager.getInstance().init();
        }

        public function destory():void
        {
			GpipManager.getInstance().destory();
			ControllerManager.getInstance().destory();
        }

        // -------------------------- 事件框架动作 --------------------------------
        private static var eventExchangeManager:EventExchangeManager = EventExchangeManager.getInstance();

        /**
         * 注册全局操作事件方法
         * @param instance		要添加监听事件的实例对象
         * @param evtName		要添加的监听事件名称
         * @param evtFun		当监听事件触发回调函数
         * @param nameSpace		设置命名空间，防止事件覆盖
         *
         */
        public static function ApiEvtRegister(instance:Object,evtName:String,
                                              evtFun:Function,nameSpace:String=""):void
        {
            eventExchangeManager.registerGlobalAction(evtName,instance,evtFun,nameSpace);
        }

        /**
         * 全局操作事件触发方法
         * @param evtName		要触发的监听事件
         * @param data			派发事件传递参数
         * @param nameSpace		命名空间
         *
         */
        public static function ApiEvtDispatcher(evtName:String,data:Object,nameSpace:String=""):void
        {
            eventExchangeManager.triggerGlobalAction(evtName,data,nameSpace);
        }
        /**
         * 取消全局操作事件方法
         * @param evtName		要取消监听的事件名称
         * @param nameSpace		命名空间
         *
         */
        public static function ApiEvtUnRegister(evtName:String,nameSpace:String):void{
            eventExchangeManager.unregisterGlobalAction(evtName,nameSpace);
        }

        // -------------------------- 日志记录 --------------------------------
        /**
         * 当前日志对象
         */
        private static var _log:LoggerUtils = LoggerUtils.getInstance();

        public static function log(...args):void
        {
            var arg:Array = args as Array;
            if (arg.length > 0)
            {
                _log.printLog(args.join(" "));
            }
        }

        public static function logError(...args):void
        {
            var arg:Array = args as Array;
            if (arg.length > 0)
            {
                _log.printErrorLog(args.join(" "));
            }
        }

    }
}