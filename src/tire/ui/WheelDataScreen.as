/**
 * User: booster
 * Date: 05/03/15
 * Time: 16:38
 */
package tire.ui {
import feathers.controls.Button;
import feathers.controls.Header;
import feathers.controls.List;
import feathers.controls.PanelScreen;
import feathers.controls.Slider;
import feathers.controls.ToggleSwitch;
import feathers.controls.renderers.DefaultListItemRenderer;
import feathers.controls.renderers.IListItemRenderer;
import feathers.data.ListCollection;
import feathers.layout.AnchorLayout;
import feathers.layout.AnchorLayoutData;

import starling.display.DisplayObject;
import starling.events.Event;

import tire.TirePhysics;

public class WheelDataScreen extends PanelScreen {
    private var _wheelMassSlider:Slider;
    private var _wheelRadiusSlider:Slider;
    private var _wheelInertiaLocked:ToggleSwitch;
    private var _wheelInertiaSlider:Slider;
    private var _loadMassSlider:Slider;
    private var _frontalAreaSlider:Slider;
    private var _maxAccTorqueSlider:Slider;
    private var _maxBrakingTorqueSlider:Slider;

    private var _list:List;

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

        _wheelInertiaSlider = new SecretSlider();
        _wheelInertiaSlider.minimum = 0.1;
        _wheelInertiaSlider.maximum = 50;
        _wheelInertiaSlider.step = 0.1;
        _wheelInertiaSlider.value = tirePhysics.wheelInertia;
        _wheelInertiaSlider.isEnabled = _tirePhysics.wheelInertiaLocked;
        _wheelInertiaSlider.addEventListener(Event.CHANGE, function (e:Event):void {
            _tirePhysics.wheelInertia = _wheelInertiaSlider.value;
        });
        UiHelper.setupSlider(_wheelInertiaSlider);

        _wheelInertiaLocked = new ToggleSwitch();
        _wheelInertiaLocked.onText = "Yes";
        _wheelInertiaLocked.offText = "No";
        _wheelInertiaLocked.isSelected = _tirePhysics.wheelInertiaLocked;
        _wheelInertiaLocked.addEventListener(Event.CHANGE, function (e:Event):void {
            var sliderItem:Object = null, sliderIndex:int = -1;

            var count:int = _list.dataProvider.length;
            for(var i:int = 0; i < count; ++i) {
                var item:Object = _list.dataProvider.getItemAt(i);

                if(item.accessory != _wheelInertiaSlider)
                    continue;

                sliderItem = item;
                sliderIndex = i;
                break;
            }

            _tirePhysics.wheelInertiaLocked = _wheelInertiaLocked.isSelected;

            if(! _tirePhysics.wheelInertiaLocked) {
                sliderItem.enabled = false;
                _tirePhysics.validateInertia();
            }
            else {
                sliderItem.enabled = true;
                _tirePhysics.wheelInertia = _wheelInertiaSlider.value;
            }

            _list.dataProvider.updateItemAt(sliderIndex);
        });

        _loadMassSlider = new Slider();
        _loadMassSlider.minimum = 10;
        _loadMassSlider.maximum = 1000;
        _loadMassSlider.step = 10;
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

        _list = new List();
        _list.isSelectable = false;
        _list.dataProvider = new ListCollection([
            { label : "Wheel mass", accessory : _wheelMassSlider },
            { label : "Wheel radius", accessory : _wheelRadiusSlider },
            { label : "Wheel inertia locked", accessory : _wheelInertiaLocked},
            { label : "Wheel inertia", accessory : _wheelInertiaSlider, enabled : _tirePhysics.wheelInertiaLocked},
            { label : "Load mass", accessory : _loadMassSlider},
            { label : "Frontal area", accessory : _frontalAreaSlider},
            { label : "Acc. torque", accessory : _maxAccTorqueSlider},
            { label : "Braking torque", accessory : _maxBrakingTorqueSlider},
        ]);
        _list.layoutData = new AnchorLayoutData(0, 0, 0, 0);
        _list.clipContent = false;
        _list.autoHideBackground = true;
        _list.itemRendererFactory = function():IListItemRenderer {
            var renderer:DefaultListItemRenderer = new DefaultListItemRenderer();
            renderer.itemHasEnabled = true;

            return renderer;
        };
//        list.addEventListener(FeathersEventType.CREATION_COMPLETE, function(e:Event):void {
//            _wheelInertiaSlider.isEnabled = _tirePhysics.wheelInertiaLocked;
//        });
        addChild(_list);

        headerFactory = customHeaderFactory;

        backButtonHandler = function ():void {
            _tirePhysics.save();
            dispatchEventWith(Event.COMPLETE);
        };
    }

    private function customHeaderFactory():Header {
        var header:Header = new Header();
        var backButton:Button = new Button();
        backButton.styleNameList.add(Button.ALTERNATE_NAME_BACK_BUTTON);
        backButton.label = "Back";
        backButton.addEventListener(Event.TRIGGERED, function(e:Event):void {
            _tirePhysics.save();
            dispatchEventWith(Event.COMPLETE);
        });
        header.leftItems = new <DisplayObject>[backButton];
        return header;
    }
}
}

import feathers.controls.Slider;

class SecretSlider extends Slider {

    override public function set isEnabled(value:Boolean):void {
        super.isEnabled = value;
    }

    override public function get isEnabled():Boolean {
        return super.isEnabled;
    }
}