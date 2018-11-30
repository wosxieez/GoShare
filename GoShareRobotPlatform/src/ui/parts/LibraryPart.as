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

// LibraryPart.as
// John Maloney, November 2011
//
// This part holds the Sprite Library and the UI elements around it.

package ui.parts {
import com.goshare.event.EventExchangeEvent;
import com.goshare.manager.AppManager;

import flash.display.*;
import flash.text.*;

import scratch.*;

import translation.Translator;

import ui.SpriteThumbnail;
import ui.media.*;

import uiwidgets.*;

import util.CachedTimer;

public class LibraryPart extends UIPart {

    private const smallTextFormat:TextFormat = new TextFormat(CSS.font, 10, CSS.textColor);

    private const bgColor:int = 0xFFFFFF;
    private const stageAreaWidth:int = 77;///舞台区域宽度 77 添加舞台背景条的区域宽度（目前位于左侧）
    private const updateInterval:int = 200; // msecs between thumbnail updates  缩略图更新间隔200ms

    private var lastUpdate:uint; // time of last thumbnail update

    private var shape:Shape;

    private var stageThumbnail:SpriteThumbnail; ///舞台缩略图，右边可选中的舞台元素.这个SpriteThumbnail类也包含了人物元素的缩略图《对应界面上可选中，变蓝》
    private var spritesFrame:ScrollFrame; ///人物元素展示区域（可滚动框架）
    protected var spritesPane:ScrollFrameContents;///人物元素展示区域的内容
    private var spriteDetails:SpriteInfoPart;///人物元素的细节信息

    private var spritesTitle:TextField;///人物元素标题
    private var newSpriteLabel:TextField;///新的人物元素标题,文本标题
    private var paintButton:IconButton;///绘画按钮
    private var libraryButton:IconButton;///人物元素文件库按钮
    private var importButton:IconButton;///人物元素导入本地文件按钮
    private var photoButton:IconButton;///拍照按钮--作为人物

    private var backdropTitle:TextField;///舞台元素固定标题
    private var newBackdropLabel:TextField;///新的背景幕布标题，文本标题
    private var backdropLibraryButton:IconButton;///背景幕布文件库按钮
    private var backdropPaintButton:IconButton;///背景幕布绘画按钮
    private var backdropImportButton:IconButton;///背景幕布导入本地文件按钮
    private var backdropCameraButton:IconButton;///拍照按钮--作为背景

    private var videoLabel:TextField;///视频标题
    private var videoButton:IconButton;///视频按钮

    /**
     * 构造函数--人物展示区域部分（主页面的右下部分）
     * @param app
     */
    public function LibraryPart(app:Scratch) {
        this.app = app;
        shape = new Shape();
        addChild(shape);

        spritesTitle = makeLabel(Translator.map('Sprites'), CSS.titleFormat, app.isMicroworld ? 10: stageAreaWidth + 10, 5);
        addChild(spritesTitle);
        spritesTitle.visible = false;

        backdropTitle = makeLabel(Translator.map('Backdrop'), CSS.titleFormat, 371+20+10,5);
        addChild(backdropTitle);

        addChild(newSpriteLabel = makeLabel(Translator.map('New sprite:'), CSS.titleFormat, 10, 5));
        newSpriteLabel.visible = false;

        addChild(libraryButton = makeButton(spriteFromLibrary, 'library'));
        addChild(paintButton = makeButton(paintSprite, 'paintbrush'));
        addChild(importButton = makeButton(spriteFromComputer, 'import'));
        addChild(photoButton = makeButton(spriteFromCamera, 'camera'));
        libraryButton.visible = paintButton.visible = importButton.visible = photoButton.visible = false;

        if (!app.isMicroworld) {
            addStageArea();
            addNewBackdropButtons();
            addVideoControl();
        }
        addSpritesArea();

        spriteDetails = new SpriteInfoPart(app);
        addChild(spriteDetails);
        spriteDetails.visible = true;
        updateTranslation();
        addMyEventListener()
    }

    private function addMyEventListener():void {
        AppManager.ApiEvtRegister(this,"myEventTest",spriteFromLibraryHandler)
    }

    private function spriteFromLibraryHandler(evt:EventExchangeEvent):void {
        switch(evt.exchangeData){
            case "spriteFromLibrary":
                trace("监听到点击了元素库按钮");
                importSprite(false)
                break
            case "paintSprite":
                trace("监听到点击了绘画按钮");
                paintSpriteHandler();
                break
            case "spriteFromComputer":
                trace("监听到点击了本地文件库按钮");
                importSprite(true)
                break
            case "spriteFromCamera":
                spriteFromCameraHandler();
                trace("监听到点击了拍摄按钮");
                break
            default :
        }
    }

    public static function strings():Array {
        return [
            'size:','Sprites', 'New sprite:', 'New backdrop:', 'Video on:', 'backdrop1', 'costume1', 'photo1', 'pop',
            'Choose sprite from library', 'Paint new sprite', 'Upload sprite from file', 'New sprite from camera',
            'Choose backdrop from library', 'Paint new backdrop', 'Upload backdrop from file', 'New backdrop from camera',
        ];
    }

    /**
     * 设置按钮的tip(操作人物和背景的按钮)
     */
    public function updateTranslation():void {
        spritesTitle.text = Translator.map('Sprites');
        backdropTitle.text = Translator.map('Backdrop');
        newSpriteLabel.text = Translator.map('New sprite:');
        if (newBackdropLabel) newBackdropLabel.text = Translator.map('New backdrop:');
        if (videoLabel) videoLabel.text = Translator.map('Video on:');
        if (stageThumbnail)
            stageThumbnail.updateThumbnail(true);
        spriteDetails.updateTranslation();

        SimpleTooltips.add(libraryButton, {text: 'Choose sprite from library', direction: 'bottom'});
        SimpleTooltips.add(paintButton, {text: 'Paint new sprite', direction: 'bottom'});
        SimpleTooltips.add(importButton, {text: 'Upload sprite from file', direction: 'bottom'});
        SimpleTooltips.add(photoButton, {text: 'New sprite from camera', direction: 'bottom'});

        SimpleTooltips.add(backdropLibraryButton, {text: 'Choose backdrop from library', direction: 'bottom'});
        SimpleTooltips.add(backdropPaintButton, {text: 'Paint new backdrop', direction: 'bottom'});
        SimpleTooltips.add(backdropImportButton, {text: 'Upload backdrop from file', direction: 'bottom'});
        SimpleTooltips.add(backdropCameraButton, {text: 'New backdrop from camera', direction: 'bottom'});

        fixLayout();
    }

    /**
     * 设置宽高
     * @param w
     * @param h
     */
    public function setWidthHeight(w:int, h:int):void {
        this.w = w;
        this.h = h;
        var g:Graphics = shape.graphics;
        g.clear();
        /// 哥学定制 透明头部
//		drawTopBar(g, [0xFFffff, 0xFFffff], getTopBarPath(w,CSS.titleBarH), w, CSS.titleBarH);
//		g.lineStyle(1, CSS.borderColor, 1, true);
//		g.drawRect(0, CSS.titleBarH, w, h - CSS.titleBarH);
//		g.lineStyle(1, CSS.borderColor);

        if (!app.isMicroworld) {
//			g.moveTo(stageAreaWidth, 0);
//			g.lineTo(stageAreaWidth, h);
//			g.lineStyle();
//			g.beginFill(CSS.tabColor, 0);

            g.lineStyle(1,CSS.borderColor)
            g.drawRect(0,0,w,h);
            g.endFill();

            g.moveTo(w-85,0);
            g.lineTo(w-85,h);
        }
        fixLayout();
        if (app.viewedObj()) refresh(); // refresh, but not during initialization
    }

    /**
     * 修正布局
     */
    private function fixLayout():void {
        var buttonY:int = 4;
        if (!app.isMicroworld) {
            if (app.stageIsContracted){
                spritesFrame.x = 2;
            }
        }
        else {
            libraryButton.visible = false;
            paintButton.visible = false;
            importButton.visible = false;
            photoButton.visible = false;
            newSpriteLabel.visible = false;
//            spritesFrame.setWidthHeight(150,h - spritesFrame.y)
        }

        spritesFrame.x = 1;
        spritesFrame.allowHorizontalScrollbar = false;
        spritesFrame.y = 1+77;
        spriteDetails.x = 1;
        spriteDetails.y = 1;
        stageThumbnail.y = 30 + 2;

        spritesFrame.setWidthHeight(w-88, h - spritesFrame.y-2);

        spriteDetails.setWidthHeight(w-88, 77);
        stageThumbnail.x = spritesFrame.x+spritesFrame.width+(88-stageThumbnail.width)/2+2;///舞台缩略图元素

        var bottomY : int = this.h-30;
        backdropLibraryButton.x = stageThumbnail.x;
        backdropLibraryButton.y = bottomY + 3;
        backdropPaintButton.x = backdropLibraryButton.right() + 8;
        backdropPaintButton.y = bottomY + 1;
        backdropImportButton.x = backdropPaintButton.right() + 8;
        backdropImportButton.y = bottomY + 0;
        backdropCameraButton.x = backdropImportButton.right() + 8;
        backdropCameraButton.y = bottomY + 3;
        backdropTitle.x = spritesFrame.x+spritesFrame.width+(w-(spritesFrame.x+spritesFrame.width)-backdropTitle.textWidth)/2;
    }

    /**
     * 元素缩略图选中高亮
     * @param highlightList
     */
    public function highlight(highlightList:Array):void {
        // Highlight each ScratchObject in the given list to show,
        // for example, broadcast senders or receivers. Passing an
        // empty list to this function clears all highlights.
        for each (var tn:SpriteThumbnail in allThumbnails()) {
            tn.showHighlight(highlightList.indexOf(tn.targetObj) >= 0);
        }
    }

    /**
     * 刷新，
     * 每次刷新，都是往spritesPane里添加缩略图元素，重新排序，计算spritesPane的尺寸
     */
    public function refresh():void {
        // Create thumbnails for all sprites. This function is called
        // after loading project, or adding or deleting a sprite.
        /*
        * 为所有精灵创建缩略图。这个函数在
        * 加载项目后，或添加或删除精灵后被调用
        * */
//		newSpriteLabel.visible = !app.stageIsContracted && !app.isMicroworld;
//		spritesTitle.visible = !app.stageIsContracted;///右上角的舞台不是收缩模式
//		spritesTitle.text = "测试";
//		if (app.viewedObj().isStage) showSpriteDetails(false);
        if (app.viewedObj().isStage) showSpriteDetails(true);///如果当前元素选中的是舞台,细节面板依旧展示
        if (spriteDetails.visible) spriteDetails.refresh();
        if (stageThumbnail) stageThumbnail.setTarget(app.stageObj());///将该元素设置为舞台的缩略图
        spritesPane.clear(false);
        var sortedSprites:Array = app.stageObj().sprites();///// Return an array of all sprites in this project.
        sortedSprites.sort(
                function(spr1:ScratchSprite, spr2:ScratchSprite):int {
                    return spr1.indexInLibrary - spr2.indexInLibrary
                });
//        const inset:int = 15;
//        var rightEdge:int = w - spritesFrame.x;
        var rightEdge:int = spritesFrame.width;
        var nextX:int = 15;
        var nextY:int = 6;
        var index:int = 1;
        for each (var spr:ScratchSprite in sortedSprites) {
            spr.indexInLibrary = index++; // renumber to ensure unique indices
            var tn:SpriteThumbnail = new SpriteThumbnail(spr, app);
            tn.x = nextX;
            tn.y = nextY;
            spritesPane.addChild(tn);
            nextX += tn.width+6;
            if ((nextX + tn.width) > rightEdge) { // start new line
                nextX = 15;
                nextY += tn.height+6;
            }
        }
        spritesPane.updateSize();///添加完元素后，元素板要更新尺寸
        scrollToSelectedSprite();///滚动到选中的元素
        step();
    }

    private function scrollToSelectedSprite():void {
        var viewedObj:ScratchObj = app.viewedObj();
        var sel:SpriteThumbnail;
        for (var i:int = 0; i < spritesPane.numChildren; i++) {
            var tn:SpriteThumbnail = spritesPane.getChildAt(i) as SpriteThumbnail;
            if (tn && (tn.targetObj == viewedObj)) sel = tn;
        }
        if (sel) {
            var selTop:int = sel.y + spritesPane.y - 1;
            var selBottom:int = selTop + sel.height;
            spritesPane.y -= Math.max(0, selBottom - spritesFrame.visibleH());
            spritesPane.y -= Math.min(0, selTop);
            spritesFrame.updateScrollbars();
        }
    }

    /**
     * 是否展示人物元素细节信息
     * @param flag
     */
    public function showSpriteDetails(flag:Boolean):void {
        spriteDetails.visible = flag;
        if (spriteDetails.visible) spriteDetails.refresh();
    }

    public function step():void {
        // Update thumbnails and sprite details.
        var viewedObj:ScratchObj = app.viewedObj();
        var updateThumbnails:Boolean = ((CachedTimer.getCachedTimer() - lastUpdate) > updateInterval);
        for each (var tn:SpriteThumbnail in allThumbnails()) {
            if (updateThumbnails) tn.updateThumbnail();
            tn.select(tn.targetObj == viewedObj);
        }
        if (updateThumbnails) lastUpdate = CachedTimer.getCachedTimer();
        if (spriteDetails.visible) spriteDetails.step();
        if (videoButton && videoButton.visible) updateVideoButton();
    }

    private function addStageArea():void {
        stageThumbnail = new SpriteThumbnail(app.stagePane, app);
        addChild(stageThumbnail);
    }

    /**
     * 添加操作背景的系列按钮,
     * 从库中添加，绘画，导入本地文件，打开摄像头拍摄
     */
    private function addNewBackdropButtons():void {
        addChild(newBackdropLabel = makeLabel(
                Translator.map('New backdrop:'), smallTextFormat, 3, 126));
        newBackdropLabel.visible = false;
        // new backdrop buttons
        addChild(backdropLibraryButton = makeButton(backdropFromLibrary, 'landscapeSmall'));
        addChild(backdropPaintButton = makeButton(paintBackdrop, 'paintbrushSmall'));
        addChild(backdropImportButton = makeButton(backdropFromComputer, 'importSmall'));
        addChild(backdropCameraButton = makeButton(backdropFromCamera, 'cameraSmall'));

//		var buttonY:int = 145;
//		var bottomY : int = app.stage.stageHeight-50;
//		trace("bottomY:",bottomY);
//		backdropLibraryButton.x = 371+30;
//		backdropLibraryButton.y = bottomY + 3;
//		backdropPaintButton.x = backdropLibraryButton.right() + 8;
//		backdropPaintButton.y = bottomY + 1;
//		backdropImportButton.x = backdropPaintButton.right() + 8;
//		backdropImportButton.y = bottomY + 0;
//		backdropCameraButton.x = backdropImportButton.right() + 8;
//		backdropCameraButton.y = bottomY + 3;
    }

    /**
     * 添加人物的展示候选区
     */
    private function addSpritesArea():void {
        ///组件嵌套结构
        /*
        * spritesFrame(滚动框架)中嵌套spritesPane(元素嵌板)，
        * 在spritesPane(元素嵌板)中addChild(SpriteThumbnail<人物元素的缩略图>)
        * */
        spritesPane = new ScrollFrameContents();
        spritesPane.backgroundColor = bgColor;///人物元素展示区的背景颜色
        spritesPane.backgroundAlpha = 1
        spritesPane.hExtra = spritesPane.vExtra = 0;
        spritesFrame = new ScrollFrame();///人物元素展示区，可滚动
        spritesFrame.setContents(spritesPane);
        addChild(spritesFrame);
//		spritesPane.visible = false;
    }

    /**
     * 创建按钮函数
     * @param fcn 对应点击函数
     * @param iconName 对应展示的icon资源名称
     * @return 返回一个iconButton实例
     */
    private function makeButton(fcn:Function, iconName:String):IconButton {
        var b:IconButton = new IconButton(fcn, iconName);
        b.isMomentary = true;
        return b;
    }

    // -----------------------------
    // Video Button
    //------------------------------

    /**
     * 显示视频按钮
     */
    public	function showVideoButton():void {
        // Show the video button. Turn on the camera the first time this is called.
        if (videoButton.visible) return; // already showing
        videoButton.visible = true;
        videoLabel.visible = true;
        if (!app.stagePane.isVideoOn()) {
            app.stagePane.setVideoState('on');
        }
    }

    private function updateVideoButton():void {
        var isOn:Boolean = app.stagePane.isVideoOn();
        if (videoButton.isOn() != isOn) videoButton.setOn(isOn);
    }

    private function addVideoControl():void {
        function turnVideoOn(b:IconButton):void {
            app.stagePane.setVideoState(b.isOn() ? 'on' : 'off');
            app.setSaveNeeded();
        }
        addChild(videoLabel = makeLabel(
                Translator.map('Video on:'), smallTextFormat,
                1, backdropLibraryButton.y + 22));

        videoButton = makeButton(turnVideoOn, 'checkbox');
        videoButton.x = videoLabel.x + videoLabel.width + 1;
        videoButton.y = videoLabel.y + 3;
        videoButton.disableMouseover();
        videoButton.isMomentary = false;
        addChild(videoButton);

        videoLabel.visible = videoButton.visible = false; // hidden until video turned on
    }

    // -----------------------------
    // New Sprite Operations,新人物元素的相关操作
    //------------------------------


    /**
     *绘画（作为人物元素）按钮点击后执行
     * @param b
     */
    private function paintSprite(b:IconButton):void {
        paintSpriteHandler();
    }

    private function paintSpriteHandler():void {
        var spr:ScratchSprite = new ScratchSprite();
        spr.setInitialCostume(ScratchCostume.emptyBitmapCostume(Translator.map('costume1'), false));
        app.addNewSprite(spr, true);
    }

    /**
     *拍摄照片（作为人物元素）按钮点击后执行
     * @param b
     */
    protected function spriteFromCamera(b:IconButton):void {
        spriteFromCameraHandler();
    }

    private function spriteFromCameraHandler():void {
        function savePhoto(photo:BitmapData):void {
            var s:ScratchSprite = new ScratchSprite();
            s.setInitialCostume(new ScratchCostume(Translator.map('photo1'), photo));
            app.addNewSprite(s);
            app.closeCameraDialog();
        }
        app.openCameraDialog(savePhoto);
    }

    private function spriteFromComputer(b:IconButton):void { importSprite(true) }
    private function spriteFromLibrary(b:IconButton):void { importSprite(false) }

    /**
     * 导入文件作为元素
     * @param fromComputer true从电脑中导入，还是false从项目自身的资源库中导入
     */
    private function importSprite(fromComputer:Boolean):void {
        function addSprite(costumeOrSprite:*):void {
            var spr:ScratchSprite;
            var c:ScratchCostume = costumeOrSprite as ScratchCostume;
            if (c) {
                spr = new ScratchSprite(c.costumeName);
                spr.setInitialCostume(c);
                app.addNewSprite(spr);
                return;
            }
            spr = costumeOrSprite as ScratchSprite;
            if (spr) {
                app.addNewSprite(spr);
                return;
            }
            var list:Array = costumeOrSprite as Array;
            if (list) {
                var sprName:String = list[0].costumeName;
                if (sprName.length > 3) sprName = sprName.slice(0, sprName.length - 2);
                spr = new ScratchSprite(sprName);
                for each (c in list) spr.costumes.push(c);
                if (spr.costumes.length > 1) spr.costumes.shift(); // remove default costume
                spr.showCostumeNamed(list[0].costumeName);
                app.addNewSprite(spr);
            }
        }
        var lib:MediaLibrary = app.getMediaLibrary('sprite', addSprite);
        if (fromComputer) lib.importFromDisk();
        else lib.open();
    }

    // -----------------------------
    // New Backdrop Operations,新背景元素的相关操作
    //------------------------------

    protected function backdropFromCamera(b:IconButton):void {
        function savePhoto(photo:BitmapData):void {
            addBackdrop(new ScratchCostume(Translator.map('photo1'), photo));
            app.closeCameraDialog();
        }
        app.openCameraDialog(savePhoto);
    }

    private function backdropFromComputer(b:IconButton):void {
        var lib:MediaLibrary = app.getMediaLibrary('backdrop', addBackdrop);
        lib.importFromDisk();
    }

    private function backdropFromLibrary(b:IconButton):void {
        var lib:MediaLibrary = app.getMediaLibrary('backdrop', addBackdrop);
        lib.open();///打开媒体库
    }

    private function paintBackdrop(b:IconButton):void {
        addBackdrop(ScratchCostume.emptyBitmapCostume(Translator.map('backdrop1'), true));
    }

    protected function addBackdrop(costumeOrList:*):void {
        var c:ScratchCostume = costumeOrList as ScratchCostume;
        if (c) {
            if (!c.baseLayerData) c.prepareToSave();
            if (!app.okayToAdd(c.baseLayerData.length)) return; // not enough room
            c.costumeName = app.stagePane.unusedCostumeName(c.costumeName);
            app.stagePane.costumes.push(c);
            app.stagePane.showCostumeNamed(c.costumeName);
        }
        var list:Array = costumeOrList as Array;
        if (list) {
            for each (c in list) {
                if (!c.baseLayerData) c.prepareToSave();
                if (!app.okayToAdd(c.baseLayerData.length)) return; // not enough room
                app.stagePane.costumes.push(c);
            }
            app.stagePane.showCostumeNamed(list[0].costumeName);
        }
        app.setTab('images');
        app.selectSprite(app.stagePane);
        app.setSaveNeeded(true);
    }

    // -----------------------------
    // Dropping
    //------------------------------

    public function handleDrop(obj:*):Boolean {
        return false;
    }

    protected function changeThumbnailOrder(dropped:ScratchSprite, dropX:int, dropY:int):void {
        // Update the order of library items based on the drop point. Update the
        // indexInLibrary field of all sprites, then refresh the library.
        dropped.indexInLibrary = -1;
        var inserted:Boolean = false;
        var nextIndex:int = 1;
        for (var i:int = 0; i < spritesPane.numChildren; i++) {
            var th:SpriteThumbnail = spritesPane.getChildAt(i) as SpriteThumbnail;
            var spr:ScratchSprite = th.targetObj as ScratchSprite;
            if (!inserted) {
                if (dropY < (th.y - (th.height / 2))) { // insert before this row
                    dropped.indexInLibrary = nextIndex++;
                    inserted = true;
                } else if (dropY < (th.y + (th.height / 2))) {
                    if (dropX < th.x) { // insert before the current thumbnail
                        dropped.indexInLibrary = nextIndex++;
                        inserted = true;
                    }
                }
            }
            if (spr != dropped) spr.indexInLibrary = nextIndex++;
        }
        if (dropped.indexInLibrary < 0) dropped.indexInLibrary = nextIndex++;
        refresh();
    }

    // -----------------------------
    // Misc
    //------------------------------

    /**
     * 获取包含所有的缩略图元素对象的数组
     * @return
     */
    private function allThumbnails():Array {
        // Return a list containing all thumbnails.
        var result:Array = stageThumbnail ? [stageThumbnail] : [];
        for (var i:int = 0; i < spritesPane.numChildren; i++) {
            result.push(spritesPane.getChildAt(i));
        }
        return result;
    }

}}
