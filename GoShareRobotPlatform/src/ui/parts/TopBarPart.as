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

// TopBarPart.as
// John Maloney, November 2011
//
// This part holds the Scratch Logo, cursor tools, screen mode buttons, and more.

package ui.parts {
import assets.Resources;

import coco.component.Image;


import extensions.ExtensionDevManager;

import flash.display.*;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.text.*;

import translation.Translator;

import uiwidgets.*;

public class TopBarPart extends UIPart {

    private var shape:Shape;///图形
    protected var logoDisplay: Image;///logo
//    protected var languageButton:IconButton;///语言

    protected var fileMenu:IconButton;///文件菜单
//    protected var editMenu:IconButton;///文件菜单

    private var copyTool:IconButton;///复制按钮
    private var cutTool:IconButton;///剪切按钮
    private var growTool:IconButton;///放大按钮
    private var shrinkTool:IconButton;///收缩按钮
    private var helpTool:IconButton;///帮助按钮
    private var toolButtons:Array = []; ///上述工具条按钮容器数组
    private var toolOnMouseDown:String;///鼠标cover时按钮的tip

    private var offlineNotice:TextField;///离线提示
    private const offlineNoticeFormat:TextFormat = new TextFormat(CSS.font, 13, CSS.white, true);///离线提示文本格式

    protected var loadExperimentalButton:Button;///加载实验按钮
    protected var exportButton:Button;///导出按钮
    protected var extensionLabel:TextField;///扩展标签

    private var minWindowIcon : Image;
    private var maxOrResWindowIcon : Image;
    private var closeWindowIcon : Image;

    public function TopBarPart(app:Scratch) {
        this.app = app;
        addButtons();
        refresh();
        addWindowControlBtn();
        addMouseDragHandler();
    }

    private function addMouseDragHandler():void {
        this.addEventListener(MouseEvent.MOUSE_DOWN,mouseDownHandler)
    }

    private function mouseDownHandler(event:MouseEvent):void {
        stage.nativeWindow.startMove();
    }

    private function addWindowControlBtn():void {
        logoDisplay = new Image();
        logoDisplay.width = 101;
        logoDisplay.height = 21;
        logoDisplay.buttonMode = true;
        logoDisplay.source = 'assets/UI/topbar/logo.png';
        addChild(logoDisplay)

        minWindowIcon = new Image();
        minWindowIcon.width = 29;
        minWindowIcon.height = 29;
        minWindowIcon.buttonMode = true;
        minWindowIcon.source = 'assets/UI/windowControl/minSize.png';
        minWindowIcon.addEventListener(MouseEvent.CLICK,minHandler)
        addChild(minWindowIcon)

        maxOrResWindowIcon = new Image();
        maxOrResWindowIcon.width = 29;
        maxOrResWindowIcon.height = 29;
        maxOrResWindowIcon.buttonMode = true;
        maxOrResWindowIcon.source = 'assets/UI/windowControl/maxSize.png';
        maxOrResWindowIcon.addEventListener(MouseEvent.CLICK,maxOrResHandler)
        addChild(maxOrResWindowIcon)

        closeWindowIcon = new Image();
        closeWindowIcon.width = 29;
        closeWindowIcon.height = 29;
        closeWindowIcon.buttonMode = true;
        closeWindowIcon.source = 'assets/UI/windowControl/close.png';
        closeWindowIcon.addEventListener(MouseEvent.CLICK,closeHandler)
        addChild(closeWindowIcon)
    }

    private function maxOrResHandler(event:MouseEvent):void {
        if(app.stage.nativeWindow.displayState != NativeWindowDisplayState.MAXIMIZED){
            app.stage.nativeWindow.maximize();
            maxOrResWindowIcon.source = 'assets/UI/windowControl/restoreSize.png';
            maxOrResWindowIcon.width = 29;
            maxOrResWindowIcon.height = 29;
        }else{
            app.stage.nativeWindow.restore();
            maxOrResWindowIcon.source = 'assets/UI/windowControl/maxSize.png';
            maxOrResWindowIcon.width = 29;
            maxOrResWindowIcon.height = 29;
        }
    }

    private function closeHandler(event:MouseEvent):void {
        app.stage.nativeWindow.close();
    }

    private function minHandler(event:MouseEvent):void {
        app.stage.nativeWindow.minimize();
    }

    protected function addButtons():void {
        addChild(shape = new Shape());
//        addChild(languageButton = new IconButton(app.setLanguagePressed, 'languageButton'));
//        languageButton.isMomentary = true;
        addTextButtons();
        addToolButtons();
    }

    public static function strings():Array {
        if (Scratch.app) {
            Scratch.app.showFileMenu(Menu.dummyButton());
            Scratch.app.showEditMenu(Menu.dummyButton());
        }
        return ['File', 'Edit', 'Tips', 'Duplicate', 'Delete', 'Grow', 'Shrink', 'Block help', 'Offline Editor'];
    }

    protected function removeTextButtons():void {
        if (fileMenu.parent) {
            removeChild(fileMenu);
//            removeChild(editMenu);
        }
    }

    public function updateTranslation():void {
        removeTextButtons();
        addTextButtons();
        if (offlineNotice) offlineNotice.text = Translator.map('Offline Editor');
        refresh();
    }

    public function setWidthHeight(w:int, h:int):void {
        this.w = w;
        this.h = h;
        var g:Graphics = shape.graphics;
        g.clear();
        g.beginFill(0x5196FD);
        g.drawRect(0, 0, w, h);
        g.endFill();
        fixLayout();
    }

    protected function fixLogoLayout():int {
        var nextX:int = 9;
        if (logoDisplay) {
            logoDisplay.x = nextX;
            logoDisplay.y = (h - logoDisplay.height) / 2
            nextX += logoDisplay.width + buttonSpace;
        }
        return nextX;
    }

    protected const buttonSpace:int = 12;
    protected function fixLayout():void {
//        trace("TopBarPart执行fixLayout");
        const buttonY:int = 17;

        var nextX:int = fixLogoLayout();
//        languageButton.x = nextX;
//        languageButton.y = buttonY - 1;
//        nextX += languageButton.width + buttonSpace;

        // new/more/tips buttons
        fileMenu.x = nextX;
        fileMenu.y = 11;
        nextX += fileMenu.width + buttonSpace;

//        editMenu.x = nextX;
//        editMenu.y = buttonY;
//        nextX += editMenu.width + buttonSpace;

        // cursor tool buttons
        var space:int = 3;
//        copyTool.x = app.isOffline ? 493 : 427;
        copyTool.x = app.stage.stageWidth/2-50;
        cutTool.x = copyTool.right() + space;
        growTool.x = cutTool.right() + space;
        shrinkTool.x = growTool.right() + space;
        helpTool.x = shrinkTool.right() + space;
        copyTool.y = cutTool.y = shrinkTool.y = growTool.y = helpTool.y = buttonY - 3;

        if (offlineNotice) {
            offlineNotice.x = w - offlineNotice.width - 5;
            offlineNotice.y = 5;
        }

        // From here down, nextX is the next item's right edge and decreases after each item
        nextX = w - 5;

        if (loadExperimentalButton) {
            loadExperimentalButton.x = nextX - loadExperimentalButton.width;
            loadExperimentalButton.y = h + 5;
            // Don't upload nextX: we overlap with other items. At most one set should show at a time.
        }

        if (exportButton) {
            exportButton.x = nextX - exportButton.width;
            exportButton.y = h + 5;
            nextX = exportButton.x - 5;
        }

        if (extensionLabel) {
            extensionLabel.x = nextX - extensionLabel.width;
            extensionLabel.y = h + 5;
            nextX = extensionLabel.x - 5;
        }

        if(closeWindowIcon&&maxOrResWindowIcon&&minWindowIcon){
            closeWindowIcon.x = w-closeWindowIcon.width-11;
            minWindowIcon.x = closeWindowIcon.x-minWindowIcon.width;
            maxOrResWindowIcon.x = minWindowIcon.x-minWindowIcon.width;

            minWindowIcon.y = maxOrResWindowIcon.y = closeWindowIcon.y = (h-maxOrResWindowIcon.height)/2;
        }
    }

    public function refresh():void {
        if (app.isOffline) {
//            helpTool.visible = app.isOffline;
        }

        if (Scratch.app.isExtensionDevMode) {
            var hasExperimental:Boolean = app.extensionManager.hasExperimentalExtensions();
            exportButton.visible = hasExperimental;
            extensionLabel.visible = hasExperimental;
            loadExperimentalButton.visible = !hasExperimental;

            var extensionDevManager:ExtensionDevManager = app.extensionManager as ExtensionDevManager;
            if (extensionDevManager) {
                extensionLabel.text = extensionDevManager.getExperimentalExtensionNames().join(', ');
            }
        }
        fixLayout();
    }

    protected function addTextButtons():void {
        addChild(fileMenu = makeMenuButton('File', app.showFileMenu, true));
//        addChild(editMenu = makeMenuButton('Edit', app.showEditMenu, true));
    }

    private function addToolButtons():void {
        function selectTool(b:IconButton):void {
            var newTool:String = '';
            if (b == copyTool) newTool = 'copy';
            if (b == cutTool) newTool = 'cut';
            if (b == growTool) newTool = 'grow';
            if (b == shrinkTool) newTool = 'shrink';
            if (b == helpTool) newTool = 'help';
            if (newTool == toolOnMouseDown) {
                clearToolButtons();
                CursorTool.setTool(null);
            } else {
                clearToolButtonsExcept(b);
                CursorTool.setTool(newTool);
            }
        }

        toolButtons.push(copyTool = makeToolButton('copyTool', selectTool));
        toolButtons.push(cutTool = makeToolButton('cutTool', selectTool));
        toolButtons.push(growTool = makeToolButton('growTool', selectTool));
        toolButtons.push(shrinkTool = makeToolButton('shrinkTool', selectTool));
        toolButtons.push(helpTool = makeToolButton('helpTool', selectTool));
        copyTool.visible = cutTool.visible = growTool.visible = shrinkTool.visible = helpTool.visible = false
        if(!app.isMicroworld){
            for each (var b:IconButton in toolButtons) {
                addChild(b);
            }
        }
        SimpleTooltips.add(copyTool, {text: 'Duplicate', direction: 'top'});
        SimpleTooltips.add(cutTool, {text: 'Delete', direction: 'bottom'});
        SimpleTooltips.add(growTool, {text: 'Grow', direction: 'bottom'});
        SimpleTooltips.add(shrinkTool, {text: 'Shrink', direction: 'bottom'});
        SimpleTooltips.add(helpTool, {text: 'Block help', direction: 'bottom'});
    }

    public function clearToolButtons():void {
        clearToolButtonsExcept(null)
    }

    private function clearToolButtonsExcept(activeButton:IconButton):void {
        for each (var b:IconButton in toolButtons) {
            if (b != activeButton) b.turnOff();
        }
    }

    private function makeToolButton(iconName:String, fcn:Function):IconButton {
        function mouseDown(evt:MouseEvent):void {
            toolOnMouseDown = CursorTool.tool
        }

        var onImage:Sprite = toolButtonImage(iconName, CSS.overColor, 1);
        var offImage:Sprite = toolButtonImage(iconName, 0, 0);
        var b:IconButton = new IconButton(fcn, onImage, offImage);
        b.actOnMouseUp();
        b.addEventListener(MouseEvent.MOUSE_DOWN, mouseDown); // capture tool on mouse down to support deselecting
        return b;
    }

    private function toolButtonImage(iconName:String, color:int, alpha:Number):Sprite {
        const w:int = 23;
        const h:int = 24;
        var img:Bitmap;
        var result:Sprite = new Sprite();
        var g:Graphics = result.graphics;
        g.clear();
        g.beginFill(color, alpha);
        g.drawRoundRect(0, 0, w, h, 8, 8);
        g.endFill();
        result.addChild(img = Resources.createBmp(iconName));
        img.x = Math.floor((w - img.width) / 2);
        img.y = Math.floor((h - img.height) / 2);
        return result;
    }

    protected function makeButtonImg(s:String, c:int, isOn:Boolean):Sprite {
        var result:Sprite = new Sprite();

        var label:TextField = makeLabel(Translator.map(s), CSS.topBarButtonFormat, 2, 2);
        label.textColor = CSS.white;
        label.x = 6;
        result.addChild(label); // label disabled for now

        var w:int = label.textWidth + 16;
        var h:int = 22;
        var g:Graphics = result.graphics;
        g.clear();
        g.beginFill(c);
        g.drawRoundRect(0, 0, w, h, 8, 8);
        g.endFill();

        return result;
    }
}
}
