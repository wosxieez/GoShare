/**
 * Author: fangchao
 * Date: 2018/11/29
 * Time: 下午3:54
 */
package com.goshare.component {
import coco.component.TextAlign;
import coco.component.TextInput;
import coco.util.FontFamily;

import flash.events.KeyboardEvent;

/**
 description:
 */
public class NewEditableLab extends TextInput{

    private var restoreData : String;

    public function NewEditableLab() {

        addEventListener(KeyboardEvent.KEY_UP,keyUpHandler);
        initHandler();
    }

    private function initHandler():void {
        this.color = 0x333333;
        this.fontFamily = FontFamily.MICROSOFT_YAHEI;
        textAlign = TextAlign.CENTER;
    }

    /**
     * 恢复上次数据
     */
    public function recoverDataHandler():void
    {
        if(restoreData){
            this.text = restoreData;
        }
    }

    /**
     * 存储上次数据
     */
    public function storageDataHandler():void
    {
        if(this.text){
            restoreData = this.text;
        }
    }

    public function clearResData():void{
        restoreData = '';
    }

    private function keyUpHandler(event:KeyboardEvent):void {
        if(event.charCode==13){
            stage.focus = null;
        }
    }

}
}
