/**
 * User: booster
 * Date: 06/03/15
 * Time: 11:04
 */
package ui {
import feathers.controls.Button;
import feathers.controls.Header;
import feathers.controls.List;
import feathers.controls.PanelScreen;
import feathers.controls.Slider;
import feathers.data.ListCollection;
import feathers.layout.AnchorLayout;
import feathers.layout.AnchorLayoutData;

import starling.display.DisplayObject;
import starling.events.Event;

public class WorldDataScreen extends PanelScreen {
    private var _staticFrictionCoefSlider:Slider;
    private var _kineticFrictionCoefSlider:Slider;
    private var _airDragCoefSlider:Slider;
    private var _rollingDragCoefSlider:Slider;
    private var _subStepCountSlider:Slider;

    private var _tirePhysics:TirePhysics;
    private var _rootDisplay:RootDisplay;

    public function get tirePhysics():TirePhysics { return _tirePhysics; }
    public function set tirePhysics(value:TirePhysics):void { _tirePhysics = value; }

    public function get rootDisplay():RootDisplay { return _rootDisplay; }
    public function set rootDisplay(value:RootDisplay):void { _rootDisplay = value; }

    override protected function initialize():void {
        super.initialize();

        layout = new AnchorLayout();

        title = "World settings";

        headerFactory = customHeaderFactory;

        _staticFrictionCoefSlider = new Slider();
        _staticFrictionCoefSlider.minimum = 0;
        _staticFrictionCoefSlider.maximum = 1.0;
        _staticFrictionCoefSlider.step = 0.1;
        _staticFrictionCoefSlider.value = _tirePhysics.coefSF;
        _staticFrictionCoefSlider.addEventListener(Event.CHANGE, function (e:Event):void {
            _tirePhysics.coefSF = _staticFrictionCoefSlider.value;
        });
        UiHelper.setupSlider(_staticFrictionCoefSlider);
        
        _kineticFrictionCoefSlider = new Slider();
        _kineticFrictionCoefSlider.minimum = 0.0;
        _kineticFrictionCoefSlider.maximum = 1.0;
        _kineticFrictionCoefSlider.step = 0.1;
        _kineticFrictionCoefSlider.value = _tirePhysics.coefKf;
        _kineticFrictionCoefSlider.addEventListener(Event.CHANGE, function (e:Event):void {
            _tirePhysics.coefKf = _kineticFrictionCoefSlider.value;
        });
        UiHelper.setupSlider(_kineticFrictionCoefSlider);
        
        _airDragCoefSlider = new Slider();
        _airDragCoefSlider.minimum = 0.1;
        _airDragCoefSlider.maximum = 2;
        _airDragCoefSlider.step = 0.1;
        _airDragCoefSlider.value = _tirePhysics.coefDrag;
        _airDragCoefSlider.addEventListener(Event.CHANGE, function (e:Event):void {
            _tirePhysics.coefDrag = _airDragCoefSlider.value;
        });
        UiHelper.setupSlider(_airDragCoefSlider);
        
        _rollingDragCoefSlider = new Slider();
        _rollingDragCoefSlider.minimum = 1;
        _rollingDragCoefSlider.maximum = 25;
        _rollingDragCoefSlider.step = 1;
        _rollingDragCoefSlider.value = _tirePhysics.coefRollingDrag * 1000;
        _rollingDragCoefSlider.addEventListener(Event.CHANGE, function (e:Event):void {
            _tirePhysics.coefRollingDrag = _rollingDragCoefSlider.value / 1000.0;
        });
        UiHelper.setupSlider(_rollingDragCoefSlider);

        _subStepCountSlider = new Slider();
        _subStepCountSlider.minimum = 1;
        _subStepCountSlider.maximum = 100;
        _subStepCountSlider.step = 1;
        _subStepCountSlider.value = _rootDisplay.subStepCount;
        _subStepCountSlider.addEventListener(Event.CHANGE, function (e:Event):void {
            _rootDisplay.subStepCount = _subStepCountSlider.value;
        });
        UiHelper.setupSlider(_subStepCountSlider);

        var list:List = new List();
        list.isSelectable = false;
        list.dataProvider = new ListCollection([
            { label : "Static frict. coef.", accessory : _staticFrictionCoefSlider },
            { label : "Kinetic frict. coef.", accessory : _kineticFrictionCoefSlider},
            { label : "Air drag coef.", accessory : _airDragCoefSlider},
            { label : "Rolling drag coef.", accessory : _rollingDragCoefSlider},
            { label : "Simulation sub-steps", accessory : _subStepCountSlider},
        ]);
        list.layoutData = new AnchorLayoutData(0, 0, 0, 0);
        list.clipContent = false;
        list.autoHideBackground = true;
        addChild(list);

        backButtonHandler = function ():void {
            dispatchEventWith(Event.COMPLETE);
        };
    }

    private function customHeaderFactory():Header {
        var header:Header = new Header();
        var backButton:Button = new Button();
        backButton.styleNameList.add(Button.ALTERNATE_NAME_BACK_BUTTON);
        backButton.label = "Back";
        backButton.addEventListener(Event.TRIGGERED, function(e:Event):void {
            dispatchEventWith(Event.COMPLETE);
        });
        header.leftItems = new <DisplayObject>[backButton];
        return header;
    }
}
}
