/**
 * User: booster
 * Date: 18/03/15
 * Time: 13:50
 */
package drive.components.clutch {
import drive.components.DrivetrainComponent;
import drive.components.DrivetrainComponentData;
import drive.components.drivetrain_internal;
import drive.components.util.ISteppable;

import flash.errors.IllegalOperationError;

import plugs.Connection;

import plugs.inputs.NumberInput;

use namespace drivetrain_internal;

public class ClutchComponent extends DrivetrainComponent implements ISteppable {
    private var _clutchRatioInput:NumberInput;
    private var _previousAngularVelocityInput:NumberInput;
    private var _nextAngularVelocityInput:NumberInput;

    private var _timeStepInput:NumberInput;

    private var _prevAngVelDiff:Number = 0;
    private var _nextAngVelDiff:Number = 0;

    public function ClutchComponent(name:String = null) {
        super(name);

        _clutchRatioInput               = new NumberInput("ClutchRatio");
        _previousAngularVelocityInput   = new NumberInput("PreviousAngularVelocity");
        _nextAngularVelocityInput       = new NumberInput("NextAngularVelocity");

        addInput(_clutchRatioInput);
        addInput(_previousAngularVelocityInput);
        addInput(_nextAngularVelocityInput);

        _timeStepInput                  = new NumberInput("dt");

        addInput(_timeStepInput);
    }

    public function get clutchRatioInput():NumberInput { return _clutchRatioInput; }
    public function get previousAngularVelocityInput():NumberInput { return _previousAngularVelocityInput; }
    public function get nextAngularVelocityInput():NumberInput { return _nextAngularVelocityInput; }

    public function get timeStepInput():NumberInput { return _timeStepInput; }

    protected function pullClutchRatio():Number {
        return _clutchRatioInput.connections.get(0).pullData();
    }

    override public function receivePushData(data:*, inputConnection:Connection):void {
        if(inputConnection.input == _timeStepInput) {
            step(data);
            return;
        }

        super.receivePushData(data, inputConnection);
    }

    override protected function pullGearRatio():Number { return 1; }
    override protected function pullTorque():Number { return 0; }
    override protected function pullInertia():Number { return 0; }
    override protected function pullStepDuration():Number { throw new IllegalOperationError("clutch does not use step duration pulling"); }
    override protected function calculateNewAngularVelocity():Number { throw new IllegalOperationError("clutch does not integrate velocity over time"); }

    override protected function pullNextComponentData(outputConnection:Connection):DrivetrainComponentData {
        if(_nextComponentInput.connections.size() > 0) {
            // TODO: cache nextData
            var nextData:DrivetrainComponentData            = _nextComponentInput.connections.get(0).pullData();
            var clutchRatio:Number                          = pullClutchRatio();

            _nextComponentData.combinedTorque               = clutchRatio * nextData.combinedTorque / nextData.gearRatio;
            _nextComponentData.combinedEffectiveInertia     = clutchRatio * nextData.combinedEffectiveInertia / (nextData.gearRatio * nextData.gearRatio);
            _nextComponentData.combinedAngularVelocityDiff  = clutchRatio * nextData.combinedAngularVelocityDiff * nextData.gearRatio;
        }
        else {
            _nextComponentData.gearRatio                    = 1;
            _nextComponentData.combinedTorque               = 0;
            _nextComponentData.combinedEffectiveInertia     = 0;
            _nextComponentData.combinedAngularVelocityDiff  = 0;
        }

        _nextComponentData.gearRatio                    = pullGearRatio();
        _nextComponentData.combinedTorque              += pullTorque();
        _nextComponentData.combinedEffectiveInertia    += pullInertia();
        _nextComponentData.combinedAngularVelocityDiff += calculateNextAngularVelocityDiff();

        return _nextComponentData;
    }

    override protected function pullPreviousComponentData(outputConnection:Connection):DrivetrainComponentData {
        if(_previousComponentInput.connections.size() > 0) {
            // TODO: cache prevData
            var prevData:DrivetrainComponentData            = _previousComponentInput.connections.get(0).pullData();
            var gearRatio:Number                            = pullGearRatio();
            var clutchRatio:Number                          = pullClutchRatio();

            _prevComponentData.combinedTorque               = clutchRatio * prevData.combinedTorque * gearRatio;
            _prevComponentData.combinedEffectiveInertia     = clutchRatio * prevData.combinedEffectiveInertia * (gearRatio * gearRatio);
            _prevComponentData.combinedAngularVelocityDiff  = clutchRatio * prevData.combinedAngularVelocityDiff / gearRatio;
        }
        else {
            _prevComponentData.gearRatio                    = 1;
            _prevComponentData.combinedTorque               = 0;
            _prevComponentData.combinedEffectiveInertia     = 0;
            _prevComponentData.combinedAngularVelocityDiff  = 0;
        }

        _prevComponentData.gearRatio                    = pullGearRatio();
        _prevComponentData.combinedTorque              += pullTorque();
        _prevComponentData.combinedEffectiveInertia    += pullInertia();
        _prevComponentData.combinedAngularVelocityDiff += calculatePreviousAngularVelocityDiff();

        return _prevComponentData;
    }


    override protected function calculatePreviousAngularVelocityDiff():Number {
        return _prevAngVelDiff;
    }

    override protected function calculateNextAngularVelocityDiff():Number {
        return _nextAngVelDiff;
    }

    private function step(dt:Number):void {
        _prevAngVelDiff = calcAngVelDiffForPrev();
        _nextAngVelDiff = calcAngVelDiffForNext();
    }

    private function calcAngVelDiffForNext():Number {
        var prevData:DrivetrainComponentData = drivetrain_internal::_previousComponentInput.connections.get(0).pullData();

        // no need to use gear ratio for previous component's values, it's always 1 for clutch
        var prevInertia:Number      = prevData.combinedEffectiveInertia;
        var prevAngVel:Number       = _previousAngularVelocityInput.connections.get(0).pullData();
        var prevAngMomentum:Number  = prevInertia * prevAngVel;

        var nextData:DrivetrainComponentData = drivetrain_internal::_nextComponentInput.connections.get(0).pullData();

        var nextInertia:Number      = nextData.combinedEffectiveInertia / (nextData.gearRatio * nextData.gearRatio);
        var nextAngVel:Number       = _nextAngularVelocityInput.connections.get(0).pullData() * nextData.gearRatio;
        var nextAngMomentum:Number  = nextInertia * nextAngVel;

        var clutchRatio:Number = pullClutchRatio();

        var newPrevAngVel:Number = (prevAngMomentum + clutchRatio * nextAngMomentum) / (prevInertia + clutchRatio * nextInertia);

        return newPrevAngVel - prevAngVel;
    }

    private function calcAngVelDiffForPrev():Number {
        var prevData:DrivetrainComponentData = drivetrain_internal::_previousComponentInput.connections.get(0).pullData();

        // no need to use gear ratio for previous component's values, it's always 1 for clutch
        var prevInertia:Number      = prevData.combinedEffectiveInertia;
        var prevAngVel:Number       = _previousAngularVelocityInput.connections.get(0).pullData();
        var prevAngMomentum:Number  = prevInertia * prevAngVel;

        var nextData:DrivetrainComponentData = drivetrain_internal::_nextComponentInput.connections.get(0).pullData();

        var nextInertia:Number      = nextData.combinedEffectiveInertia / (nextData.gearRatio * nextData.gearRatio);
        var nextAngVel:Number       = _nextAngularVelocityInput.connections.get(0).pullData() * nextData.gearRatio;
        var nextAngMomentum:Number  = nextInertia * nextAngVel;

        var clutchRatio:Number = pullClutchRatio();

        var newNextAngVel:Number = (nextAngMomentum + clutchRatio * prevAngMomentum) / (nextInertia + clutchRatio * prevInertia);

        return newNextAngVel - nextAngVel;
    }
}
}
