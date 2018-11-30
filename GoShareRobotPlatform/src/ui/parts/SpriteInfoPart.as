/*
 * Scratch Project Editor and Player
 * Copyright (C) 2014 Massachusetts Institute of Technology
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License
 * as published by the Free Software Foundation; either version 2
 * of the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
 */

// SpriteInfoPart.as
// John Maloney, November 2011
//
// This part shows information about the currently selected object (the stage or a sprite).

package ui.parts {
import com.goshare.component.CheckBoxOfImage;
import com.goshare.component.NewEditableLab;

import com.goshare.manager.AppManager;

import flash.display.*;
import flash.events.*;
import flash.geom.*;
import flash.text.*;

import scratch.*;

import translation.Translator;

import uiwidgets.*;

import util.DragClient;

/**
 * 人物元素的详情模块类
 */
public class SpriteInfoPart extends UIPart implements DragClient {

    private const readoutLabelFormat:TextFormat = new TextFormat(CSS.font, 12, 0x333333, true);

    private var shape:Shape;

    // sprite info parts
    private var closeButton:IconButton;
    private	var thumbnail:Bitmap;
    private var spriteLab:TextField
    private var spriteName:NewEditableLab;

    private var xReadoutLabel:TextField;
    private var yReadoutLabel:TextField;
    private var xReadout:NewEditableLab;
    private var yReadout:NewEditableLab;

    private var dirLabel:TextField;
    private var dirReadout:NewEditableLab;
    private var dirWheel:Sprite;

    private var rotationStyleLabel:TextField;
    private var rotationStyleButtons:Array;

    private var draggableLabel:TextField;
    private var draggableButton:IconButton;

    private var showSpriteLabel:TextField;
//    private var showSpriteButton:IconButton;

    private var showSpriteButton1:CheckBoxOfImage;
    private var showSpriteButton2:CheckBoxOfImage;

    private var lastX:Number, lastY:Number, lastDirection:Number, lastRotationStyle:String,lastSizeOfSprite:String;
    private var lastSrcImg:DisplayObject;

    private var sizeOfSpriteLab:TextField
    private var sizeOfSprite:NewEditableLab;///控制舞台上的元素大小

    private var paintButton:IconButton;///绘画按钮
    private var libraryButton:IconButton;///人物元素文件库按钮
    private var importButton:IconButton;///人物元素导入本地文件按钮
    private var photoButton:IconButton;///拍照按钮--作为人物

    public function SpriteInfoPart(app:Scratch) {
        this.app = app;
        shape = new Shape();
        addChild(shape);
        addParts();
        updateTranslation();
        addSpriteGropBtn();
    }

    /**
     * 添加人物元素操作系列按钮
     */
    private function addSpriteGropBtn():void {
        addChild(libraryButton = makeButton(spriteFromLibrary, 'library'));
        addChild(paintButton = makeButton(paintSprite, 'paintbrush'));
        addChild(importButton = makeButton(spriteFromComputer, 'import'));
        addChild(photoButton = makeButton(spriteFromCamera, 'camera'));
        SimpleTooltips.add(libraryButton, {text: 'Choose sprite from library', direction: 'bottom'});
        SimpleTooltips.add(paintButton, {text: 'Paint new sprite', direction: 'bottom'});
        SimpleTooltips.add(importButton, {text: 'Upload sprite from file', direction: 'bottom'});
        SimpleTooltips.add(photoButton, {text: 'New sprite from camera', direction: 'bottom'});
    }

    private function spriteFromCamera(b:IconButton):void {
        AppManager.ApiEvtDispatcher("myEventTest","spriteFromCamera")
    }

    private function spriteFromComputer(b:IconButton):void {
        AppManager.ApiEvtDispatcher("myEventTest","spriteFromComputer")
    }

    private function paintSprite(b:IconButton):void {
        AppManager.ApiEvtDispatcher("myEventTest","paintSprite")
    }

    private function spriteFromLibrary(b:IconButton):void {
        AppManager.ApiEvtDispatcher("myEventTest","spriteFromLibrary")
    }


    private function makeButton(fcn:Function, iconName:String):IconButton {
        var b:IconButton = new IconButton(fcn, iconName);
        b.isMomentary = true;
        return b;
    }

    public static function strings():Array {
        return ['direction:', 'rotation style:', 'can drag in player:', 'show:','size:'];
    }

    public function updateTranslation():void {
        sizeOfSpriteLab.text = Translator.map('size:');
        spriteLab.text = Translator.map('Sprites')+':';
        dirLabel.text = Translator.map('direction:');
        rotationStyleLabel.text = Translator.map('rotation style:');
        draggableLabel.text = Translator.map('can drag in player:');
        showSpriteLabel.text = Translator.map('show:');
        if (app.viewedObj()) refresh();
    }

    public function setWidthHeight(w:int, h:int):void {
        this.w = w;
        this.h = h;
        var g:Graphics = shape.graphics;
        g.clear();
//		g.beginFill(CSS.white)
        g.beginFill(0xeff4fe);
        g.drawRect(0, 0, w, h);
        g.endFill();
    }

    public function step():void { updateSpriteInfo() }

    public function refresh():void {
        ///如果是舞台元素，就让部分控件元素不可用
        if(app.viewedObj().isStage){
            forbidenSomeComponent();
        }else{
            allowTheseComponent();
        }
        spriteName.text = app.viewedObj().objName;///设置人物元素的名称
        updateSpriteInfo();///更新人物元素信息
        if (app.stageIsContracted) layoutCompact();///如果是缩略图的情况
        else layoutFullsize();///普通模式下，填满
    }

    private function allowTheseComponent():void {
        xReadout.editable = true;
        xReadout.recoverDataHandler();
        xReadout.clearResData();

        yReadout.editable = true;
        yReadout.recoverDataHandler();
        yReadout.clearResData();

        sizeOfSprite.editable = true;
        sizeOfSprite.recoverDataHandler();
        sizeOfSprite.clearResData();

        dirReadout.recoverDataHandler();
        dirReadout.clearResData();

        showSpriteButton1.addEventListener(MouseEvent.CLICK,clickshowSpriteButtonHandler);
        showSpriteButton2.addEventListener(MouseEvent.CLICK,clickshowSpriteButtonHandler);
        showSpriteButton1.buttonMode = showSpriteButton2.buttonMode = true;
    }

    private function forbidenSomeComponent():void {
        xReadout.editable = false;
        xReadout.storageDataHandler();
        xReadout.text = '';

        yReadout.editable = false;
        yReadout.storageDataHandler();
        yReadout.text = '';

        sizeOfSprite.editable = false;
        sizeOfSprite.storageDataHandler();
        sizeOfSprite.text = '';

        dirReadout.editable = false;
        dirReadout.storageDataHandler();
        dirReadout.text = '';

        showSpriteButton1.removeEventListener(MouseEvent.CLICK,clickshowSpriteButtonHandler);
        showSpriteButton2.removeEventListener(MouseEvent.CLICK,clickshowSpriteButtonHandler);
        showSpriteButton1.selected = showSpriteButton2.selected = false;
        showSpriteButton1.buttonMode = showSpriteButton2.buttonMode = false;
    }

    private function addParts():void {
        addChild(closeButton = new IconButton(closeSpriteInfo, 'backarrow'));
        closeButton.isMomentary = true;

        addChild(spriteLab = makeLabel('', readoutLabelFormat));
        spriteName = new NewEditableLab();
        spriteName.addEventListener(FocusEvent.FOCUS_OUT,spriteName_focusOutHandler)
        addChild(spriteName)

//		addChild(thumbnail = new Bitmap());

        addChild(xReadoutLabel = makeLabel('x:', readoutLabelFormat));
        xReadout = new NewEditableLab();
        xReadout.addEventListener(FocusEvent.FOCUS_OUT,xyReadout_focusOutHandler)
        addChild(xReadout)

        addChild(yReadoutLabel = makeLabel('y:', readoutLabelFormat));
        yReadout = new NewEditableLab();
        yReadout.addEventListener(FocusEvent.FOCUS_OUT,xyReadout_focusOutHandler)
        addChild(yReadout)

        ///添加缩放功能输入框
        addChild(sizeOfSpriteLab = makeLabel('', readoutLabelFormat));
        sizeOfSprite = new NewEditableLab();
        sizeOfSprite.addEventListener(FocusEvent.FOCUS_OUT,sizeOfSprite_focusOutHandler)
        addChild(sizeOfSprite)

        ///旋转度数
        addChild(dirLabel = makeLabel('', readoutLabelFormat));
        addChild(dirWheel = new Sprite());
        dirWheel.addEventListener(MouseEvent.MOUSE_DOWN, dirMouseDown);
        dirReadout = new NewEditableLab();
        dirReadout.editable = false;
        addChild(dirReadout)


        addChild(rotationStyleLabel = makeLabel('', readoutLabelFormat));
        rotationStyleButtons = [
            new IconButton(rotate360, 'rotate360', null, true),
            new IconButton(rotateFlip, 'flip', null, true),
            new IconButton(rotateNone, 'norotation', null, true)];///三种选择模式按钮（360,左右镜像,不旋转）
        for each (var b:IconButton in rotationStyleButtons) addChild(b);

        addChild(draggableLabel = makeLabel('', readoutLabelFormat));///是否可拖拽--标题
        addChild(draggableButton = new IconButton(toggleLock, 'checkbox'));///是否可拖拽--标题
        draggableButton.disableMouseover();

        addChild(showSpriteLabel = makeLabel('', readoutLabelFormat));


        showSpriteButton1 = new CheckBoxOfImage();
        showSpriteButton1.statusSrc = ["assets/UI/newIconForScratch/showSpriteBtn/visibleOFF.png",
            "assets/UI/newIconForScratch/showSpriteBtn/visibleON.png"];
        showSpriteButton1.buttonMode = true;
        showSpriteButton1.width = 30;
        showSpriteButton1.height = 18;
        showSpriteButton1.addEventListener(MouseEvent.CLICK,clickshowSpriteButtonHandler);
        addChild(showSpriteButton1);

        showSpriteButton2 = new CheckBoxOfImage();
        showSpriteButton2.statusSrc = ["assets/UI/newIconForScratch/showSpriteBtn/invisibleOFF.png",
            "assets/UI/newIconForScratch/showSpriteBtn/invisibleON.png"];
        showSpriteButton2.buttonMode = true;
        showSpriteButton2.width = 30;
        showSpriteButton2.height = 18;
        showSpriteButton2.addEventListener(MouseEvent.CLICK,clickshowSpriteButtonHandler);
        addChild(showSpriteButton2);
    }

    private function spriteName_focusOutHandler(event:FocusEvent):void {
        nameChanged();
    }

    private function sizeOfSprite_focusOutHandler(event:FocusEvent):void {
        sizeOfSpriteChanged();
    }

    private function xyReadout_focusOutHandler(event:FocusEvent):void {
        XYChanged();
    }

    private function clickshowSpriteButtonHandler(event:MouseEvent):void {
        if(!event.currentTarget.selected){
            showSpriteButton1.selected = !showSpriteButton1.selected;
            showSpriteButton2.selected = !showSpriteButton2.selected;
            var spr:ScratchSprite = ScratchSprite(app.viewedObj());
            if (spr) {
                spr.visible = !spr.visible;
                spr.updateBubble();
                app.setSaveNeeded();
            }
        }
    }

    private function sizeOfSpriteChanged():void {
        if(spr&&sizeOfSprite.text&&parseInt(sizeOfSprite.text)>0){
            spr.setSize(parseInt(sizeOfSprite.text));
        }
    }

    private function layoutFullsize():void {

        libraryButton.visible = paintButton.visible = importButton.visible = photoButton.visible = true;
        spriteLab.visible = true;
        dirLabel.visible = true;
        rotationStyleLabel.visible = false;
        rotationStyleButtons[0].visible = rotationStyleButtons[1].visible = rotationStyleButtons[2].visible = false;
        dirWheel.visible = !app.viewedObj().isStage;
        dirReadout.visible = true
        sizeOfSpriteLab.visible = true;
        sizeOfSprite.visible = true;
        showSpriteButton1.visible = showSpriteButton2.visible = true;

        closeButton.x = 5;
        closeButton.y = 5;
        closeButton.visible = false;

        var left:int = 15;
        var top:int = 12;

        xReadoutLabel.x = left;
        xReadoutLabel.y = top;
        xReadout.width = 40;
        xReadout.height = 20;
        xReadout.radius = 10;
        xReadout.fontSize = 10;
        xReadout.x = xReadoutLabel.x +xReadoutLabel.textWidth+ 10;
        xReadout.y = top;

        yReadoutLabel.x = xReadout.x + xReadout.width+ 15;
        yReadoutLabel.y = top;
        yReadout.width = 40;
        yReadout.height = 20;
        yReadout.radius = 10;
        yReadout.fontSize = 10;
        yReadout.x = yReadoutLabel.x +yReadoutLabel.textWidth+ 10;
        yReadout.y = top;

        sizeOfSpriteLab.x = yReadout.x+yReadout.width+10
        sizeOfSpriteLab.y = top;
        sizeOfSprite.width = 40;
        sizeOfSprite.height = 20;
        sizeOfSprite.radius = 10;
        sizeOfSprite.fontSize = 10;
        sizeOfSprite.x = sizeOfSpriteLab.x+sizeOfSpriteLab.textWidth+10;
        sizeOfSprite.y = top;

        /***************************/
        var nextY:int = spriteName.y + spriteName.height + 9;
        ///方向标签
        dirLabel.x = sizeOfSprite.x+sizeOfSprite.width+10;
        dirLabel.y = top;

        dirReadout.width = 40;
        dirReadout.height = 20;
        dirReadout.fontSize = 10;
        dirReadout.radius = 10;
        dirReadout.x = dirLabel.x+dirLabel.textWidth;
        dirReadout.y = dirLabel.y;
        dirWheel.x = dirReadout.x+dirReadout.width+40;///方向转盘
        dirWheel.y = top+10;

        ///旋转模式
        rotationStyleLabel.x = 220;
        rotationStyleLabel.y = top+22-5;
        ///旋转模式选择按钮
        var buttonsX:int = rotationStyleLabel.x + rotationStyleLabel.width + 5;
        rotationStyleButtons[0].x = buttonsX;
        rotationStyleButtons[1].x = buttonsX + 28;
        rotationStyleButtons[2].x = buttonsX + 55;
        rotationStyleButtons[0].y = rotationStyleButtons[1].y = rotationStyleButtons[2].y = rotationStyleLabel.y;

        ///可拖拽
//		draggableLabel.x = left;
//		draggableLabel.y = nextY;
//		draggableButton.x = draggableLabel.x + draggableLabel.textWidth + 10;
//		draggableButton.y = nextY + 4;
        draggableButton.visible = false;
        draggableLabel.visible = false;


        /***************************/

        spriteLab.x = left
        spriteLab.y = xReadout.y+xReadout.height+10
        spriteName.width = 60;
        spriteName.height = 20;
        spriteName.radius = 10;
        spriteName.fontSize = 10;
        spriteName.x = spriteLab.x+spriteLab.textWidth+10;
        spriteName.y = xReadout.y+xReadout.height+10;

        showSpriteLabel.visible = false;///显示标签

        showSpriteButton1.x = spriteName.x+spriteName.width+16 + 10;
        showSpriteButton1.y = spriteName.y;
        showSpriteButton2.x = spriteName.x+spriteName.width+16 + showSpriteButton1.width + 20;
        showSpriteButton2.y = spriteName.y;

        libraryButton.x = dirLabel.x+20;
        libraryButton.y = spriteName.y + 3;
        paintButton.x = libraryButton.x + libraryButton.width + 14;
        paintButton.y = spriteName.y + 1;
        importButton.x = paintButton.x + paintButton.width + 14;
        importButton.y = spriteName.y + 3;
        photoButton.x = importButton.x + importButton.width + 14;
        photoButton.y = spriteName.y + 4;
    }

    /**
     * 小舞台情况下，组件的布局情况
     */
    private function layoutCompact():void {

        sizeOfSprite.visible = sizeOfSpriteLab.visible = false;
        dirLabel.visible = dirReadout.visible = dirWheel.visible = false;
        draggableLabel.visible = draggableButton.visible = false;
        libraryButton.visible = paintButton.visible = importButton.visible = photoButton.visible = false;
//        showSpriteLabel.visible = showSpriteButton.visible = false;
        rotationStyleLabel.visible = false
        showSpriteButton1.visible = showSpriteButton2.visible = false;

        spriteLab.visible = false;
        spriteName.x = 10;
        spriteName.y = 10;

        xReadoutLabel.x = 10;
        xReadoutLabel.y = spriteName.y+30;
        xReadout.x = xReadoutLabel.x+xReadoutLabel.textWidth+10;
        xReadout.y = xReadoutLabel.y;

        yReadoutLabel.x = xReadout.x+xReadout.width+10;
        yReadoutLabel.y = xReadoutLabel.y;
        yReadout.x = yReadoutLabel.x+yReadoutLabel.textWidth+10;
        yReadout.y = yReadoutLabel.y;
    }

    private function closeSpriteInfo(ignore:*):void {
        var lib:LibraryPart = parent as LibraryPart;
        if (lib) lib.showSpriteDetails(false);
    }

    private function rotate360(ignore:*):void {
        var spr:ScratchSprite = app.viewedObj() as ScratchSprite;
        spr.rotationStyle = 'normal';
        spr.setDirection(spr.direction);
        app.setSaveNeeded();
    }

    private function rotateFlip(ignore:*):void {
        var spr:ScratchSprite = app.viewedObj() as ScratchSprite;
        var dir:Number = spr.direction;
        spr.setDirection(90);
        spr.rotationStyle = 'leftRight';
        spr.setDirection(dir);
        app.setSaveNeeded();
    }

    private function rotateNone(ignore:*):void {
        var spr:ScratchSprite = app.viewedObj() as ScratchSprite;
        var dir:Number = spr.direction;
        spr.setDirection(90);
        spr.rotationStyle = 'none';
        spr.setDirection(dir);
        app.setSaveNeeded();
    }

    private function toggleLock(b:IconButton):void {
        var spr:ScratchSprite = ScratchSprite(app.viewedObj());
        if (spr) {
            spr.isDraggable = b.isOn();
            app.setSaveNeeded();
        }
    }

//    private function toggleShowSprite(b:IconButton):void {
//        var spr:ScratchSprite = ScratchSprite(app.viewedObj());
//        if (spr) {
//            spr.visible = !spr.visible;
//            spr.updateBubble();
//            b.setOn(spr.visible);
//            app.setSaveNeeded();
//        }
//    }

    private var spr:ScratchSprite;
    private function updateSpriteInfo():void {
        ///这个函数一直在轮循？
        // Update the sprite info. Do nothing if a field is already up to date (to minimize CPU load).
        spr= app.viewedObj() as ScratchSprite;///获取到当前高亮选择的（人物）元素对象
        if (spr == null) return;
//		updateThumbnail();
        if (spr.scratchX != lastX) {
            xReadout.text = String(Math.round(spr.scratchX));
            lastX = spr.scratchX;
        }
        if (spr.scratchY != lastY) {
            yReadout.text = String(Math.round(spr.scratchY));
            lastY = spr.scratchY;
        }
        if (spr.direction != lastDirection) {
            dirReadout.text = String(Math.round(spr.direction)) + '\u00B0';
            drawDirWheel(spr.direction);
            lastDirection = spr.direction;
        }
        if (spr.rotationStyle != lastRotationStyle) {
            updateRotationStyle();
            lastRotationStyle = spr.rotationStyle;
        }
//		draggableButton.setOn(spr.isDraggable);
        draggableButton.setOn(true);///一直支持在脚本执行时可拖动
//        showSpriteButton.setOn(spr.visible);
        showSpriteButton1.selected = spr.visible;
        showSpriteButton2.selected = !spr.visible;

        if(spr.getSize()!=lastSizeOfSprite){
            sizeOfSprite.text = spr.getSize()+""
            lastSizeOfSprite = spr.getSize()+"";
        }
//
    }

    /**
     * 画旋转盘
     * @param dir
     */
    private function drawDirWheel(dir:Number):void {
        const DegreesToRadians:Number = (2 * Math.PI) / 360;
        var r:Number = 11;
        var g:Graphics = dirWheel.graphics;
        g.clear();

        // circle
        g.beginFill(0xFFFFFF, 1);
        g.drawCircle (0, 0, r + 5);
        g.endFill();
        g.lineStyle(2, 0xD0D0D0, 1, true);
        g.drawCircle (0, 0, r - 3);

        // direction pointer
        g.lineStyle(3, 0x006080, 1, true);
        g.moveTo(0, 0);
        var dx:Number = r * Math.sin(DegreesToRadians * (180 - dir));
        var dy:Number = r * Math.cos(DegreesToRadians * (180 - dir));
        g.lineTo(dx, dy);
    }

    private function nameChanged():void {
        app.runtime.renameSprite(spriteName.text);
        spriteName.text = app.viewedObj().objName;
    }

    private function XYChanged():void {
        if(spr&&xReadout.text&&yReadout.text){
            spr.setScratchXY(parseInt(xReadout.text),parseInt(yReadout.text))
        }
    }

    public function updateThumbnail():void {
        var targetObj:ScratchObj = app.viewedObj();
        if (targetObj == null) return;
        if (targetObj.img.numChildren == 0) return; // shouldn't happen

        var src:DisplayObject = targetObj.img.getChildAt(0);
        if (src == lastSrcImg) return; // thumbnail is up to date

        var c:ScratchCostume = targetObj.currentCostume();
        thumbnail.bitmapData = c.thumbnail(80, 80, targetObj.isStage);
        lastSrcImg = src;
    }

    private function updateRotationStyle():void {
        var targetObj:ScratchSprite = app.viewedObj() as ScratchSprite;
        if (targetObj == null) return;
        for (var i:int = 0; i < numChildren; i++) {
            var b:IconButton = getChildAt(i) as IconButton;
            if (b) {
                if (b.clickFunction == rotate360) b.setOn(targetObj.rotationStyle == 'normal');
                if (b.clickFunction == rotateFlip) b.setOn(targetObj.rotationStyle == 'leftRight');
                if (b.clickFunction == rotateNone) b.setOn(targetObj.rotationStyle == 'none');
            }
        }
    }

    // -----------------------------
    // Direction Wheel Interaction
    //------------------------------

    private function dirMouseDown(evt:MouseEvent):void { app.gh.setDragClient(this, evt) }

    public function dragBegin(evt:MouseEvent):void { dragMove(evt) }
    public function dragEnd(evt:MouseEvent):void { dragMove(evt) }

    public function dragMove(evt:MouseEvent):void {
        var spr:ScratchSprite = app.viewedObj() as ScratchSprite;
        if (!spr) return;
        var p:Point = dirWheel.localToGlobal(new Point(0, 0));
        var dx:int = evt.stageX - p.x;
        var dy:int = evt.stageY - p.y;
        if ((dx == 0) && (dy == 0)) return;
        var degrees:Number = 90 + ((180 / Math.PI) * Math.atan2(dy, dx));
        spr.setDirection(degrees);
    }

}}
