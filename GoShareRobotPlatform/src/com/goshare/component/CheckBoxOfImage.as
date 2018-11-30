/**
 * Author: fangchao
 * Date: 2018/11/28
 * Time: 上午10:53
 */
package com.goshare.component {

import coco.component.Image;
import coco.core.UIComponent;

/**
 description:
 */
public class CheckBoxOfImage extends UIComponent{
    public function CheckBoxOfImage() {
    }

    private var img : Image;

    private var _statusSrc:Array;

    public function get statusSrc():Array
    {
        return _statusSrc;
    }

    public function set statusSrc(value:Array):void
    {
        _statusSrc = value;
        invalidateProperties();
    }

    private var _selected:Boolean;

    public function get selected():Boolean
    {
        return _selected;
    }

    public function set selected(value:Boolean):void
    {
        _selected = value;
        invalidateProperties();
    }

    override protected function createChildren():void
    {
        super.createChildren();

        img = new Image();
        addChild(img);
    }

    override protected function commitProperties():void
    {
        super.commitProperties();

        if(!selected){
            img.source = statusSrc[0];
        }else{
            img.source = statusSrc[1];
        }
    }

    override protected function updateDisplayList():void
    {
        super.updateDisplayList();

        img.width = width*0.6;
        img.height = height*0.6;
        img.x = (width-img.width)/2;
        img.y = (height-img.height)/2;
    }

    override protected function measure():void
    {
        super.measure();

        measuredWidth = 40;
        measuredHeight = 30;
    }

    override protected function drawSkin():void
    {
        super.drawSkin();

        graphics.clear();
        graphics.beginFill(0xFFFFFF);
        graphics.drawRoundRect(0,0,width,height,10,10);
        graphics.endFill();
    }
}
}
