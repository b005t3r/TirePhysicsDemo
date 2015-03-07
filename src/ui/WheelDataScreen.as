/**
 * User: booster
 * Date: 05/03/15
 * Time: 16:38
 */
package ui {
import feathers.controls.Button;
import feathers.controls.Header;
import feathers.controls.List;
import feathers.controls.PanelScreen;
import feathers.controls.Slider;
import feathers.controls.ToggleSwitch;
import feathers.data.ListCollection;
import feathers.layout.AnchorLayout;
import feathers.layout.AnchorLayoutData;

import starling.display.DisplayObject;
import starling.events.Event;

public class WheelDataScreen extends PanelScreen {
    private var _wheelMassSlider:Slider;
    private var _wheelRadiusSlider:Slider;
    private var _wheelInertiaLocked:ToggleSwitch;
    private var _wheelInertiaSlider:Slider;
    private var _loadMassSlider:Slider;
    private var _frontalAreaSlider:Slider;
    private var _maxAccTorqueSlider:Slider;
    private var _maxBrakingTorqueSlider:Slider;

    private var _tirePhysics:TirePhysics;

    public function get tirePhysics():TirePhysics { return _tirePhysics; }
    public function set tirePhysics(value:TirePhysics):void { _tirePhysics = value; }

    override protected function initialize():void {
        super.initialize();

        layout = new AnchorLayout();

        title = "Wheel settings";

        _wheelMassSlider = new Slider();
        _wheelMassSlider.minimum = 5;
        _wheelMassSlider.maximum = 30;
        _wheelMassSlider.step = 0.1;
        _wheelMassSlider.value = _tirePhysics.wheelMass;
        _wheelMassSlider.addEventListener(Event.CHANGE, function (e:Event):void {
            _tirePhysics.wheelMass = _wheelMassSlider.value;

            if(_wheelInertiaLocked.isSelected)
                _tirePhysics.validateInertia();
        });
        UiHelper.setupSlider(_wheelMassSlider);

        _wheelRadiusSlider = new Slider();
        _wheelRadiusSlider.minimum = 0.1;
        _wheelRadiusSlider.maximum = 5;
        _wheelRadiusSlider.step = 0.1;
        _wheelRadiusSlider.value = tirePhysics.wheelRadius;
        _wheelRadiusSlider.addEventListener(Event.CHANGE, function (e:Event):void {
            _tirePhysics.wheelRadius = _wheelRadiusSlider.value;

            if(_wheelInertiaLocked.isSelected)
                _tirePhysics.validateInertia();
        });
        UiHelper.setupSlider(_wheelRadiusSlider);

        _wheelInertiaSlider = new Slider();
        _wheelInertiaSlider.minimum = 0.1;
        _wheelInertiaSlider.maximum = 50;
        _wheelInertiaSlider.step = 0.1;
        _wheelInertiaSlider.value = 20;
        _wheelInertiaSlider.isEnabled = false;
        _wheelInertiaSlider.addEventListener(Event.CHANGE, function (e:Event):void {
            _tirePhysics.wheelInertia = _wheelInertiaSlider.value;
        });
        UiHelper.setupSlider(_wheelInertiaSlider);

        _wheelInertiaLocked = new ToggleSwitch();
        _wheelInertiaLocked.onText = "Yes";
        _wheelInertiaLocked.offText = "No";
        _wheelInertiaLocked.isSelected = true;
        _wheelInertiaLocked.addEventListener(Event.CHANGE, function (e:Event):void {
            if(_wheelInertiaLocked.isSelected) {
                _tirePhysics.validateInertia();
                _wheelInertiaSlider.isEnabled = false;
            }
            else {
                _tirePhysics.wheelInertia = _wheelInertiaSlider.value;
                _wheelInertiaSlider.isEnabled = true;
            }
        });

        _loadMassSlider = new Slider();
        _loadMassSlider.minimum = 5;
        _loadMassSlider.maximum = 500;
        _loadMassSlider.step = 1;
        _loadMassSlider.value = _tirePhysics.carMass;
        _loadMassSlider.addEventListener(Event.CHANGE, function (e:Event):void {
            _tirePhysics.carMass = _loadMassSlider.value;
        });
        UiHelper.setupSlider(_loadMassSlider);

        _frontalAreaSlider = new Slider();
        _frontalAreaSlider.minimum = 0.5;
        _frontalAreaSlider.maximum = 5;
        _frontalAreaSlider.step = 0.1;
        _frontalAreaSlider.value = _tirePhysics.frontalArea;
        _frontalAreaSlider.addEventListener(Event.CHANGE, function (e:Event):void {
            _tirePhysics.frontalArea = _frontalAreaSlider.value;
        });
        UiHelper.setupSlider(_frontalAreaSlider);

        _maxAccTorqueSlider = new Slider();
        _maxAccTorqueSlider.minimum = 100;
        _maxAccTorqueSlider.maximum = 2000;
        _maxAccTorqueSlider.step = 50;
        _maxAccTorqueSlider.value = _tirePhysics.wheelTorque;
        _maxAccTorqueSlider.addEventListener(Event.CHANGE, function (e:Event):void {
            _tirePhysics.wheelTorque = _maxAccTorqueSlider.value;
        });
        UiHelper.setupSlider(_maxAccTorqueSlider);

        _maxBrakingTorqueSlider = new Slider();
        _maxBrakingTorqueSlider.minimum = 300;
        _maxBrakingTorqueSlider.maximum = 6000;
        _maxBrakingTorqueSlider.step = 50;
        _maxBrakingTorqueSlider.value = _tirePhysics.brakeTorque;
        _maxBrakingTorqueSlider.addEventListener(Event.CHANGE, function (e:Event):void {
            _tirePhysics.brakeTorque = _maxBrakingTorqueSlider.value;
        });
        UiHelper.setupSlider(_maxBrakingTorqueSlider);

        var list:List = new List();
        list.isSelectable = false;
        list.dataProvider = new ListCollection([
            { label : "Wheel mass", accessory : _wheelMassSlider },
            { label : "Wheel radius", accessory : _wheelRadiusSlider },
            { label : "Wheel inertia locked", accessory : _wheelInertiaLocked},
            { label : "Wheel inertia", accessory : _wheelInertiaSlider},
            { label : "Load mass", accessory : _loadMassSlider},
            { label : "Frontal area", accessory : _frontalAreaSlider},
            { label : "Acc. torque", accessory : _maxAccTorqueSlider},
            { label : "Braking torque", accessory : _maxBrakingTorqueSlider},
        ]);
        list.layoutData = new AnchorLayoutData(0, 0, 0, 0);
        list.clipContent = false;
        list.autoHideBackground = true;
        addChild(list);

        headerFactory = customHeaderFactory;

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
