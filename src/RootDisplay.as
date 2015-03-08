/**
 * User: booster
 * Date: 05/03/15
 * Time: 10:40
 */
package {
import feathers.controls.LayoutGroup;
import feathers.controls.StackScreenNavigator;
import feathers.controls.StackScreenNavigatorItem;
import feathers.layout.AnchorLayout;
import feathers.layout.AnchorLayoutData;
import feathers.motion.Slide;
import feathers.themes.MinimalDesktopTheme;

import flash.ui.GameInput;
import flash.utils.getTimer;

import starling.events.Event;

import ui.AnimationScreen;

import ui.ControlsScreen;
import ui.SettingsMainScreen;
import ui.WheelDataScreen;
import ui.WorldDataScreen;

public class RootDisplay extends LayoutGroup {
    private static const SETTINGS_MAIN_ID:String            = "settingsMain";
    private static const SETTINGS_WHEEL_DATA_ID:String      = "wheelData";
    private static const SETTINGS_WORLD_DATA_ID:String      = "worldData";
    private static const SETTINGS_CONTROLS_ID:String        = "controls";

    private var _gameInput:GameInput;

    private var _tirePhysics:TirePhysics;
    private var _stepDt:Number                              = 0.01;
    private var _subStepCount:int                           = 10;

    private var _settings:StackScreenNavigator;
    private var _content:AnimationScreen;

    private var _prevTime:int                               = -1;
    private var _excessDt:Number                            = 0;

    public function RootDisplay() {
        addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);

        autoSizeMode = LayoutGroup.AUTO_SIZE_MODE_STAGE;

        _tirePhysics = new TirePhysics();
    }

    public function get stepDt():Number { return _stepDt; }
    public function set stepDt(value:Number):void { _stepDt = value; }

    public function get subStepCount():int { return _subStepCount; }
    public function set subStepCount(value:int):void { _subStepCount = value; }

    private function onAddedToStage(event:Event):void {
        _gameInput = new GameInput();
//        _gameInput.addEventListener(GameInputEvent.DEVICE_ADDED, onDeviceAdded);
//        _gameInput.addEventListener(GameInputEvent.DEVICE_REMOVED, onDeviceRemoved);
//        _gameInput.addEventListener(GameInputEvent.DEVICE_UNUSABLE, onDeviceUnusable);

//        _tirePhysics.throttle = 1;
//        brakes = 1;

//        while(Math.abs(wheelTorque) - Math.abs(totalDragTorque) > 0.01) {
//            doPhysics(0.01);
//
//            if(-sign(throttle) * wheelPosVel > 2)
//                throttle *= -1;
//        }

        //throttle = 0;

        stage.addEventListener(Event.ENTER_FRAME, onFrame);
    }

    private function onFrame(event:Event):void {
        if(_prevTime == -1) {
            _prevTime = getTimer();
        }
        else {
            var currTime:int    = getTimer();
            var dt:Number       = _excessDt + (currTime - _prevTime) / 1000.0;
            var cycleCount:int  = int(dt / _stepDt);

            _excessDt           = dt - _stepDt * cycleCount;
            _prevTime = currTime;

            _tirePhysics.step(_stepDt, _subStepCount);
        }

//        if(-TirePhysics.sign(_tirePhysics.throttle) * _tirePhysics.wheelPosVel > 15) {
//            _tirePhysics.throttle = 0;
//            _tirePhysics.brakes = 1;
//        }

//        trace(_tirePhysics);
    }

    override protected function initialize():void {
        super.initialize();

        //new MetalWorksDesktopTheme();
        new MinimalDesktopTheme();

        layout = new AnchorLayout();

        _settings               = new StackScreenNavigator();
        _settings.autoSizeMode  = StackScreenNavigator.AUTO_SIZE_MODE_CONTENT;
        _settings.width         = stage.stageWidth / 3;
        _settings.layoutData    = new AnchorLayoutData(0, NaN, 0, 0);
        _settings.clipContent   = true;
        addChild(_settings);

        var mainItem:StackScreenNavigatorItem = new StackScreenNavigatorItem(SettingsMainScreen);
        mainItem.setScreenIDForPushEvent(SettingsMainScreen.WHEEL_SCREEN_ID, SETTINGS_WHEEL_DATA_ID);
        mainItem.setScreenIDForPushEvent(SettingsMainScreen.WORLD_SCREEN_ID, SETTINGS_WORLD_DATA_ID);
        mainItem.setScreenIDForPushEvent(SettingsMainScreen.CONTROLS_SCREEN_ID, SETTINGS_CONTROLS_ID);
        _settings.addScreen(SETTINGS_MAIN_ID, mainItem);

        var wheelItem:StackScreenNavigatorItem = new StackScreenNavigatorItem(WheelDataScreen);
        wheelItem.addPopEvent(Event.COMPLETE);
        wheelItem.properties.tirePhysics = _tirePhysics;
        _settings.addScreen(SETTINGS_WHEEL_DATA_ID, wheelItem);

        var worldItem:StackScreenNavigatorItem = new StackScreenNavigatorItem(WorldDataScreen);
        worldItem.addPopEvent(Event.COMPLETE);
        worldItem.properties.tirePhysics = _tirePhysics;
        worldItem.properties.rootDisplay = this;
        _settings.addScreen(SETTINGS_WORLD_DATA_ID, worldItem);

        var controlsItem:StackScreenNavigatorItem = new StackScreenNavigatorItem(ControlsScreen);
        controlsItem.addPopEvent(Event.COMPLETE);
        controlsItem.properties.tirePhysics = _tirePhysics;
        controlsItem.properties.rootDisplay = this;
        _settings.addScreen(SETTINGS_CONTROLS_ID, controlsItem);

        _settings.pushScreen(SETTINGS_MAIN_ID);

        _settings.pushTransition    = Slide.createSlideLeftTransition();
        _settings.popTransition     = Slide.createSlideRightTransition();

        _content                    = new AnimationScreen();
        _content.layoutData         = new AnchorLayoutData(0, 0, 0, _settings.width);
        _content.clipContent        = true;
        _content.tirePhysics        = _tirePhysics;
        addChild(_content);
    }
}
}
