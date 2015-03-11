/**
 * User: booster
 * Date: 06/03/15
 * Time: 15:36
 */
package tire.ui {
import feathers.controls.Button;
import feathers.controls.Header;
import feathers.controls.Label;
import feathers.controls.List;
import feathers.controls.PanelScreen;
import feathers.controls.Slider;
import feathers.controls.ToggleSwitch;
import feathers.data.ListCollection;
import feathers.layout.VerticalLayout;
import feathers.layout.VerticalLayoutData;

import starling.display.DisplayObject;
import starling.events.EnterFrameEvent;
import starling.events.Event;

import tire.RootDisplay;
import tire.TirePhysics;

public class ControlsScreen extends PanelScreen {
    private var _throttleSlider:Slider;
    private var _brakeSlider:Slider;
    private var _throttleBrakeSwitch:ToggleSwitch;
    private var _reverseSwitch:ToggleSwitch;

    private var _simulationFreq:Label;
    private var _velocityLabel:Label;
    private var _angVelocityLabel:Label;
    private var _accelerationLabel:Label;
    private var _angAccelerationLabel:Label;
    private var _slipRatioLabel:Label;
    private var _forceRatioLabel:Label;
    private var _frictionLabel:Label;
    private var _accTorque:Label;
    private var _brakeTorque:Label;
    private var _responseTorque:Label;
    private var _airDragTorque:Label;
    private var _rollingDragTorque:Label;
    private var _totalDragTorque:Label;

    private var _tirePhysics:TirePhysics;
    private var _rootDisplay:RootDisplay;

    public function ControlsScreen() {
        addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
        addEventListener(Event.REMOVED_FROM_STAGE, onRemovedFromStage);
    }

    public function get tirePhysics():TirePhysics { return _tirePhysics; }
    public function set tirePhysics(value:TirePhysics):void { _tirePhysics = value; }

    public function get rootDisplay():RootDisplay { return _rootDisplay; }
    public function set rootDisplay(value:RootDisplay):void { _rootDisplay = value; }

    override protected function initialize():void {
        super.initialize();

        layout = new VerticalLayout();

        title = "Controls";

        headerFactory = customHeaderFactory;

        _throttleSlider = new Slider();
        _throttleSlider.minimum = 0;
        _throttleSlider.maximum = 100;
        _throttleSlider.step = 1;
        _throttleSlider.value = int(_tirePhysics.throttle * 100);
        _throttleSlider.addEventListener(Event.CHANGE, function (e:Event):void {
            if(_throttleBrakeSwitch.isSelected && _throttleSlider.value > 0)
                _brakeSlider.value = _brakeSlider.minimum;

            _tirePhysics.throttle = _throttleSlider.value / 100.0;
        });
        UiHelper.setupSlider(_throttleSlider);

        _brakeSlider = new Slider();
        _brakeSlider.minimum = 0;
        _brakeSlider.maximum = 100;
        _brakeSlider.step = 1;
        _brakeSlider.value = int(_tirePhysics.brakes * 100);
        _brakeSlider.addEventListener(Event.CHANGE, function (e:Event):void {
            if(_throttleBrakeSwitch.isSelected && _brakeSlider.value > 0)
                _throttleSlider.value = _throttleSlider.minimum;

            _tirePhysics.brakes = _brakeSlider.value / 100.0;
        });
        UiHelper.setupSlider(_brakeSlider);

        _reverseSwitch = new ToggleSwitch();
        _reverseSwitch.onText = "Fwd";
        _reverseSwitch.offText = "Rev";
        _reverseSwitch.isSelected = _tirePhysics.direction > 0;
        _reverseSwitch.addEventListener(Event.CHANGE, function(e:Event):void {
            _tirePhysics.direction = _reverseSwitch.isSelected ? 1 : -1;
        });

        _throttleBrakeSwitch = new ToggleSwitch();
        _throttleBrakeSwitch.onText = "Yes";
        _throttleBrakeSwitch.offText = "No";
        _throttleBrakeSwitch.isSelected = true;

        var ctrlList:List = new List();
        ctrlList.isSelectable = false;
        ctrlList.dataProvider = new ListCollection([
            { label : "Throttle", accessory : _throttleSlider },
            { label : "Brake", accessory : _brakeSlider},
            { label : "Reverse", accessory : _reverseSwitch },
            { label : "Exclusive throttle/brake", accessory : _throttleBrakeSwitch },
        ]);
        ctrlList.layoutData = new VerticalLayoutData(100);
        ctrlList.clipContent = false;
        ctrlList.autoHideBackground = true;
        addChild(ctrlList);

        _simulationFreq = new Label();
        _simulationFreq.text = int(Math.round(1 / _rootDisplay.stepDt) * _rootDisplay.subStepCount) + " [Hz]";

        _velocityLabel = new Label();
        _velocityLabel.text = int(_tirePhysics.wheelPosVel * 100 * 3.6) / 100 + " [km/h]";

        _angVelocityLabel = new Label();
        _angVelocityLabel.text = int(_tirePhysics.wheelAngVel * _tirePhysics.wheelRadius * 100 * 3.6) / 100 + " [km/h]";

        _accelerationLabel = new Label();
        _accelerationLabel .text = int(_tirePhysics.acceleration * 100 * 0.36) / 100 + " [km/h^2]";

        _angAccelerationLabel = new Label();
        _angAccelerationLabel.text = int(_tirePhysics.angAcceleration * _tirePhysics.wheelRadius * 100 * 0.36) / 100 + " [km/h^2]";

        _frictionLabel = new Label();
        _frictionLabel.text = _tirePhysics.wasStaticFriction ? "Static" : "Kinetic";

        _slipRatioLabel = new Label();
        _slipRatioLabel.text = _tirePhysics.wasStaticFriction ? "-" : int(_tirePhysics.slipRatio * 100) + "%";

        _forceRatioLabel = new Label();
        _forceRatioLabel.text = _tirePhysics.wasStaticFriction ? "100%" : int(_tirePhysics.forceRatio * 100) + "%";

        _accTorque = new Label();
        _accTorque.text = int(_tirePhysics.wheelTorque * _tirePhysics.throttle * _tirePhysics.direction * 100) / 100 + " [Nm]";

        _brakeTorque = new Label();
        _brakeTorque.text = int(_tirePhysics.brakeTorque * _tirePhysics.brakes * _tirePhysics.direction * 100) / 100 + " [Nm]";

        _responseTorque = new Label();
        _responseTorque.text = int(_tirePhysics.responseTorque * 100) / 100 + " [Nm]";

        _airDragTorque = new Label();
        _airDragTorque.text = int(_tirePhysics.airDragTorque * 100) / 100 + " [Nm]";

        _rollingDragTorque = new Label();
        _rollingDragTorque.text = int(_tirePhysics.rollingDragTorque * 100) / 100 + " [Nm]";

        _totalDragTorque = new Label();
        _totalDragTorque.text = int(_tirePhysics.totalDragTorque * 100) / 100 + " [Nm]";

        var header:Header = new Header();
        header.title = "Values";
        header.layoutData = new VerticalLayoutData(100);
        addChild(header);

        var valList:List = new List();
        valList.isSelectable = false;
        valList.dataProvider = new ListCollection([
            { label : "Simulation frequency", accessory : _simulationFreq },
            { label : "Velocity", accessory : _velocityLabel },
            { label : "Angular velocity", accessory : _angVelocityLabel},
            { label : "Acceleration", accessory : _accelerationLabel},
            { label : "Angular acceleration", accessory : _angAccelerationLabel},
            { label : "Friction mode", accessory : _frictionLabel},
            { label : "Slip ratio", accessory : _slipRatioLabel },
            { label : "Max. force ratio", accessory : _forceRatioLabel },
            { label : "Acceleration torque", accessory : _accTorque },
            { label : "Brake torque", accessory : _brakeTorque },
            { label : "Surface response torque", accessory : _responseTorque },
            { label : "Air drag torque", accessory : _airDragTorque },
            { label : "Rolling drag torque", accessory : _rollingDragTorque },
            { label : "Total drag torque", accessory : _totalDragTorque },
        ]);
        valList.layoutData = new VerticalLayoutData(100, 100);
        valList.clipContent = false;
        valList.autoHideBackground = true;
        addChild(valList);

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

    private function onAddedToStage(event:Event):void {
        stage.addEventListener(EnterFrameEvent.ENTER_FRAME, onFrame);
    }

    private function onRemovedFromStage(event:Event):void {
        stage.removeEventListener(EnterFrameEvent.ENTER_FRAME, onFrame);
    }

    private function onFrame(event:EnterFrameEvent):void {
        _simulationFreq.text        = int(Math.round(1 / _rootDisplay.stepDt) * _rootDisplay.subStepCount) + " [Hz]";
        _velocityLabel.text         = int(_tirePhysics.wheelPosVel * 100 * 3.6) / 100 + " [km/h]";
        _angVelocityLabel.text      = int(_tirePhysics.wheelAngVel * _tirePhysics.wheelRadius * 100 * 3.6) / 100 + " [km/h]";
        _accelerationLabel .text    = int(_tirePhysics.acceleration * 100 * 0.36) / 100 + " [km/h^2]";
        _angAccelerationLabel.text  = int(_tirePhysics.angAcceleration * _tirePhysics.wheelRadius * 100 * 0.36) / 100 + " [km/h^2]";
        _frictionLabel.text         = _tirePhysics.wasStaticFriction ? "Static" : "Kinetic";
        _slipRatioLabel.text        = _tirePhysics.wasStaticFriction ? "-" : int(_tirePhysics.slipRatio * 100) + "%";
        _forceRatioLabel.text       = _tirePhysics.wasStaticFriction ? "100%" : int(_tirePhysics.forceRatio * 100) + "%";
        _accTorque.text             = int(_tirePhysics.wheelTorque * _tirePhysics.throttle * _tirePhysics.direction * 100) / 100 + " [Nm]";
        _brakeTorque.text           = int(_tirePhysics.brakeTorque * _tirePhysics.brakes * _tirePhysics.direction * 100) / 100 + " [Nm]";
        _responseTorque.text        = int(_tirePhysics.responseTorque * 100) / 100 + " [Nm]";
        _airDragTorque.text         = int(_tirePhysics.airDragTorque * 100) / 100 + " [Nm]";
        _rollingDragTorque.text     = int(_tirePhysics.rollingDragTorque * 100) / 100 + " [Nm]";
        _totalDragTorque.text       = int(_tirePhysics.totalDragTorque * 100) / 100 + " [Nm]";
    }
}
}
