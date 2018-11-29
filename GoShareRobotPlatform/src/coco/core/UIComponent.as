/**
 * Copyright (c) 2014-present, ErZhuan(coco) Xie
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */
package coco.core
{
    import coco.event.UIEvent;
    import coco.util.NameUtil;

    import flash.display.DisplayObject;
    import flash.display.Sprite;
    import flash.events.Event;
    import flash.geom.Point;

    use namespace coco;


    /**
     * 组件创建完成的时候派发 在调用createChildren调用之前派发 initialized = false
     */
    [Event(name="ui_preinitialize", type="coco.event.UIEvent")]

    /**
     * 组件创建完成的时候派发 在调用createChildren调用之后派发 initialized = true
     */
    [Event(name="ui_creationComplete", type="coco.event.UIEvent")]

    /**
     * 组件大小发生改变的时候派发
     */
    [Event(name="ui_resize", type="coco.event.UIEvent")]

    /**
     * UIComponent</br>
     * cocoui框架中，所有组件应该继承于UIComponent</br>
     *
     * createChildren
     * commitProperties
     * measure
     * updateDisplayList
     * drawSkin
     *
     * @author Coco
     */
    public class UIComponent extends Sprite implements IUIComponent
    {

        public function UIComponent()
        {
            super();

            tabEnabled = false;
            focusRect = false;

            try
            {
                // name
                name = NameUtil.createUniqueName(this);
            }
            catch(e:Error)
            {
            }

            // 兼容Scratch 跟 cocoui 框架
            addEventListener(Event.ADDED_TO_STAGE, this_addedToStageHandler)
            addEventListener(Event.REMOVED_FROM_STAGE, this_removedFromStageHandler)
        }

        //---------------------------------------------------------------------------------------------------------------------
        //
        // Properties
        //
        //---------------------------------------------------------------------------------------------------------------------

        override public function get x():Number
        {
            return super.x;
        }

        override public function set x(value:Number):void
        {
            if (x == value)
                return;

            super.x = value;
        }

        //---------------------
        //	y
        //---------------------

        override public function get y():Number
        {
            return super.y;
        }

        override public function set y(value:Number):void
        {
            if (y == value)
                return;

            super.y = value;
        }

        //---------------------
        //	width
        //---------------------
        coco var _width:Number;

        override public function get width():Number
        {
            return isNaN(_width) ? measuredWidth : _width;
        }

        override public function set width(value:Number):void
        {
            value = Math.ceil(value);
            if (_width == value)
                return;
            _width = value;

            invalidateSize();
            invalidateDisplayList();
            invalidateSkin();
            invalidateResizeEvent();
        }

        //---------------------
        //	measuredWidth
        //---------------------
        coco var _measuredWidth:Number = 0;

        public function get measuredWidth():Number
        {
            return _measuredWidth;
        }

        public function set measuredWidth(value:Number):void
        {
            value = Math.ceil(value);
            if (_measuredWidth == value)
                return;
            _measuredWidth = value;

            // 用户宽度没有设置的情况下 才会失效显示列表
            if (isNaN(_width))
            {
                invalidateDisplayList();
                invalidateSkin();
                invalidateResizeEvent();
            }
        }


        //---------------------
        //	height
        //---------------------
        coco var _height:Number;

        override public function get height():Number
        {
            return isNaN(_height) ? measuredHeight : _height;
        }

        override public function set height(value:Number):void
        {
            value = Math.ceil(value);
            if (_height == value)
                return;
            _height = value;

            invalidateSize();
            invalidateDisplayList();
            invalidateSkin();
            invalidateResizeEvent();
        }

        //---------------------
        //	measuredHeight
        //---------------------

        coco var _measuredHeight:Number = 0;

        public function get measuredHeight():Number
        {
            return _measuredHeight;
        }

        public function set measuredHeight(value:Number):void
        {
            value = Math.ceil(value);
            if (_measuredHeight == value)
                return;
            _measuredHeight = value;

            // 用户宽度没有设置的情况下 才会失效显示列表
            if (isNaN(_height))
            {
                invalidateDisplayList();
                invalidateSkin();
                invalidateResizeEvent();
            }
        }

        //---------------------
        //	isPopUp
        //---------------------
        private var _isPopUp:Boolean = false;

        /**
         * 是否是PopUp状态
         */
        public function get isPopUp():Boolean
        {
            return _isPopUp;
        }

        public function set isPopUp(value:Boolean):void
        {
            _isPopUp = value;
        }

        //---------------------
        //	是否包含在布局中
        //  2015-12-1新增
        //---------------------
        private var _includeInLayout:Boolean = true;

        /**
         * 是否包含在布局中
         */
        public function get includeInLayout():Boolean
        {
            return _includeInLayout;
        }

        public function set includeInLayout(value:Boolean):void
        {
            _includeInLayout = value;
        }

        //---------------------
        //	application
        //---------------------
        private var _application:Application;

        public function get application():Application
        {
            return _application;
        }

        public function set application(value:Application):void
        {
            if (_application == value)
                return;

            _application = value;

            pushCallLaterMethodsToApplicationCallLaterMethods();
            setChildrenApplication();
        }

        //---------------------
        //	initialized
        //---------------------
        private var _initialized:Boolean = false;

        /**
         * [Read only]
         * @return
         */
        public function get initialized():Boolean
        {
            return _initialized;
        }


        //---------------------------------------------------------------------------------------------------------------------
        //
        //	Life Cycle
        //
        //---------------------------------------------------------------------------------------------------------------------

        public function initialize():void
        {
            if (initialized)
                return;

            dispatchEvent(new UIEvent(UIEvent.PREINITIALIZE));

            // Life Cycle
            createChildren();
            invalidatePropertiesInLifeCycle();
            invalidateSizeInLifeCycle();
            invalidateDisplayListInLifeCycle();
            invalidateSkinInLifeCycle();
            _initialized = true;

            dispatchEvent(new UIEvent(UIEvent.CREATION_COMPLETE));
        }

        protected function createChildren():void
        {
            // override code
        }

        //----------------------------------------
        //	Invalidate Flags
        //----------------------------------------
        private var invalidatePropertiesFlag:Boolean = false; // 属性失效
        private var invalidateSizeFlag:Boolean = false; // 大小失效
        private var invalidateDisplayListFlag:Boolean = false; // 显示列表失效
        private var invalidaetSkinFlag:Boolean = false; // 皮肤失效

        //----------------------------------------
        //	Invalidate Methods
        //----------------------------------------
        /**
         * Only Call In Life Cycle
         */
        private function invalidatePropertiesInLifeCycle():void
        {
            if (!invalidatePropertiesFlag)
            {
                invalidatePropertiesFlag = true;
                callLaterInLifeCycle(validateProperties, 0).descript = "[LifeCycle] validateProperties()";
            }
        }
        /**
         * Only Call In Life Cycle
         */
        private function invalidateSizeInLifeCycle():void
        {
            if (!invalidateSizeFlag)
            {
                invalidateSizeFlag = true;
                callLaterInLifeCycle(validateSize, 1).descript = "[LifeCycle] validateSize()";
            }
        }
        /**
         * Only Call In Life Cycle
         */
        private function invalidateDisplayListInLifeCycle():void
        {
            if (!invalidateDisplayListFlag)
            {
                invalidateDisplayListFlag = true;
                callLaterInLifeCycle(validateDisplayList, 2).descript = "[LifeCycle] validateDisplayList()";
            }
        }
        /**
         * Only Call In Life Cycle
         */
        private function invalidateSkinInLifeCycle():void
        {
            if (!invalidaetSkinFlag)
            {
                invalidaetSkinFlag = true;
                callLaterInLifeCycle(validateSkin, 3).descript = "[LifeCycle] validateSkin()";
            }
        }

        public function invalidateProperties():void
        {
            if (!invalidatePropertiesFlag && _initialized)
            {
                invalidatePropertiesFlag = true;
                callLater(validateProperties).descript = "validateProperties()";
            }
        }

        public function invalidateSize():void
        {
            if (!invalidateSizeFlag && _initialized)
            {
                invalidateSizeFlag = true;
                callLater(validateSize).descript = "validateSize()";
            }
        }

        public function invalidateDisplayList():void
        {
            if (!invalidateDisplayListFlag && _initialized)
            {
                invalidateDisplayListFlag = true;
                callLater(validateDisplayList).descript = "validateDisplayList()";
            }
        }

        public function invalidateSkin():void
        {
            if (!invalidaetSkinFlag && _initialized)
            {
                invalidaetSkinFlag = true;
                callLater(validateSkin).descript = "validateSkin()";
            }
        }

        //----------------------------------------
        //	Validate Methods
        //----------------------------------------

        /**
         * 如果有失效方法，则立即生效方法</br>
         * call commitProperties now</br>
         * call measure now</br>
         * call updateDisplayList now</br>
         */
        public function validateNow():void
        {
            validateProperties();
            validateSize();
            validateSkin();
            validateDisplayList();
        }

        /**
         * call commitProperties now
         */
        public function validateProperties():void
        {
            if (invalidatePropertiesFlag)
            {
                invalidatePropertiesFlag = false;
                commitProperties();
            }
        }

        /**
         * call measure now
         */
        public function validateSize():void
        {
            if (invalidateSizeFlag)
            {
                invalidateSizeFlag = false;

                // 如果高度或者宽度没有设置 才会执行measure
                if (isNaN(_width) || isNaN(_height))
                    measure();
            }
        }

        /**
         * call updateDisplayList now
         */
        public function validateDisplayList():void
        {
            if (invalidateDisplayListFlag)
            {
                invalidateDisplayListFlag = false;
                updateDisplayList();
            }
        }

        /**
         * call drawSkin now
         */
        public function validateSkin():void
        {
            if (invalidaetSkinFlag)
            {
                invalidaetSkinFlag = false;
                drawSkin();
            }
        }

        //----------------------------------------
        //	Real Methods
        //----------------------------------------
        /**
         * commitProperties
         */
        protected function commitProperties():void
        {
            // override code here
        }

        /**
         * measure
         */
        protected function measure():void
        {
            measuredWidth = 0;
            measuredHeight = 0;
        }

        /**
         * 更新显示列表
         */
        protected function updateDisplayList():void
        {
            // override code here
        }

        /**
         * 画皮肤
         */
        protected function drawSkin():void
        {

        }


        //----------------------------------------
        //	Invalidate Resize Event
        //----------------------------------------
        private var invalidateResizeEventFlag:Boolean = false;

        /**
         * 稍后调用dispatchReszieEvent()方法
         */
        private function invalidateResizeEvent():void
        {
            if (!hasEventListener(UIEvent.RESIZE))
                return;

            if (!invalidateResizeEventFlag)
            {
                invalidateResizeEventFlag = true;
                callLater(validateResizeEvent).descript = "validateResizeEvent()";
            }
        }

        /**
         * 立即调用dispatchReszieEvent()方法
         */
        private function validateResizeEvent():void
        {
            if (invalidateResizeEventFlag)
            {
                invalidateResizeEventFlag = false;
                dispatchReszieEvent();
            }
        }

        private function dispatchReszieEvent():void
        {
            if (hasEventListener(UIEvent.RESIZE))
                dispatchEvent(new UIEvent(UIEvent.RESIZE));
        }

        //---------------------------------------------------------------------------------------------------------------------
        //
        //	Methods
        //
        //---------------------------------------------------------------------------------------------------------------------

        public function setSizeWithoutDispatchResizeEvent(w:Number = NaN, h:Number = NaN):void
        {
            var invalidateFlag:Boolean = false;
            if (!isNaN(w))
            {
                _width = w;
                invalidateFlag = true;
            }

            if (!isNaN(h))
            {
                _height = h;
                invalidateFlag = true;
            }

            if (invalidateFlag)
            {
                invalidateDisplayList();
                invalidateSkin();
            }
        }

        public function setmeasuredSizeWithoutDispatchResizeEvent(w:Number = NaN, h:Number = NaN):void
        {
            var invalidateFlag:Boolean = false;
            if (!isNaN(w))
            {
                _measuredWidth = w;
                invalidateFlag = true;
            }

            if (!isNaN(h))
            {
                _measuredHeight = h;
                invalidateFlag = true;
            }

            if (invalidateFlag)
            {
                invalidateDisplayList();
                invalidateSkin();
            }
        }


        /**
         * set each child 'application'
         */
        coco function setChildrenApplication():void
        {
            var child:DisplayObject;
            for (var i:int = 0; i < numChildren; i++)
            {
                child = getChildAt(i);
                if (child is UIComponent)
                    UIComponent(child).application = application;
            }
        }

        override public function toString():String
        {
            return NameUtil.displayObjectToString(this);
        }

        /**
         * 再缩放的情况下保持全局坐标点统一
         */
        override public function localToGlobal(point:Point):Point
        {
            var globalPoint:Point = super.localToGlobal(point);
            globalPoint.x = globalPoint.x / Application.topApplication.scaleX;
            globalPoint.y = globalPoint.y / Application.topApplication.scaleY;
            return globalPoint;
        }

        /**
         * 再缩放的情况下保持全局坐标点统一
         */
        override public function globalToLocal(point:Point):Point
        {
            point.x = point.x * Application.topApplication.scaleX;
            point.y = point.y * Application.topApplication.scaleY;
            return super.globalToLocal(point);
        }


        //---------------------------------------------------------------------------------------------------------------------
        //
        // Call Later
        //
        //---------------------------------------------------------------------------------------------------------------------

        coco var callLaterMethods:Vector.<CallLaterMethod> = new Vector.<CallLaterMethod>();

        /**
         *
         * 下一帧执行函数
         *
         * @param method 函数
         * @param flag 函数标记 callLater(test, 'test()')
         * @param args 函数参数
         *
         */
        public function callLater(method:Function, ...args):CallLaterMethod
        {
            var clm:CallLaterMethod = new CallLaterMethod();
            clm.method = method;
            clm.args = args;
            clm.caller = name;

            // if 'application' not null, push method to 'application'
            // if 'application' null, push to 'callLaterMethods', When 'application' not null, push to 'application'
            if (application)
                application.pushCallLaterMethodToApplicationCallLaterMethods(clm);
            else
                callLaterMethods.push(clm);

            return clm;
        }

        /**
         * 延迟调用 在生命周期中
         * 在生命周期中application总是为null, 所以保存到自己的callLaterMethods中去
         */
        private function callLaterInLifeCycle(method:Function, index:int, ...args):CallLaterMethod
        {
            var clm:CallLaterMethod = new CallLaterMethod();
            clm.method = method;
            clm.args = args;
            clm.caller = name;
            callLaterMethods.splice(index, 0, clm);
            return clm;
        }

        /**
         *  Push 'callLaterMethods' method to 'application' method
         */
        coco function pushCallLaterMethodsToApplicationCallLaterMethods():void
        {
            if (!application)
                return;

            while(callLaterMethods.length > 0)
            {
                application.pushCallLaterMethodToApplicationCallLaterMethods(callLaterMethods.shift());
            }
        }

        //---------------------------------------------------------------------------------------------------------------------
        //
        //	Added Removed Child
        //
        //---------------------------------------------------------------------------------------------------------------------

        /**
         * Add Child
         *
         * @param child
         * @return
         */
        override public function addChild(child:DisplayObject):DisplayObject
        {
            var addedChild:DisplayObject = super.addChild(child);

            if (addedChild is IUIComponent)
            {
                IUIComponent(addedChild).initialize();
                IUIComponent(addedChild).application = application;
            }

            return addedChild;
        }

        /**
         * Add Child At Index
         *
         * @param child
         * @param index
         * @return
         */
        override public function addChildAt(child:DisplayObject, index:int):DisplayObject
        {
            var addedChild:DisplayObject = super.addChildAt(child, index);

            if (addedChild is IUIComponent)
            {
                IUIComponent(addedChild).initialize();
                IUIComponent(addedChild).application = application;
            }

            return addedChild;
        }

        /**
         * Remove Child
         *
         * @param child
         * @return
         */
        override public function removeChild(child:DisplayObject):DisplayObject
        {
            var removedChild:DisplayObject = super.removeChild(child);

            if (removedChild is IUIComponent)
                IUIComponent(removedChild).application = null;

            return removedChild;
        }

        /**
         * Remove Child At Index
         *
         * @param index
         * @return
         */
        override public function removeChildAt(index:int):DisplayObject
        {
            var removedChild:DisplayObject = super.removeChildAt(index);

            if (removedChild is IUIComponent)
                IUIComponent(removedChild).application = null;

            return removedChild;
        }

        /**
         * Remove All Child
         */
        public function removeAllChild():void
        {
            for (var i:int = numChildren - 1; i >= 0; i--)
            {
                removeChildAt(i);
            }
        }

        //---------------------------------------------------------------------------------------------------------------------
        //
        //	为了兼容UIComponent框架
        //
        //---------------------------------------------------------------------------------------------------------------------

        private function this_addedToStageHandler(event:Event):void {
            if (!initialized) {
                initialize()
                application = Application.topApplication
            }
        }

        private function this_removedFromStageHandler(event:Event):void {
            if (initialized) {
                application = null
            }
        }

    }
}
