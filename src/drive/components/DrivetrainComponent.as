/**
 * User: booster
 * Date: 11/03/15
 * Time: 9:24
 */
package drive.components {
import plugs.Connection;
import plugs.inputs.NumberInput;
import plugs.outputs.NumberOutput;
import plugs.processors.AbstractProcessor;

use namespace drivetrain_internal;

public class DrivetrainComponent extends AbstractProcessor {
    protected var _torqueInput:NumberInput;
    protected var _inertiaInput:NumberInput;
    protected var _gearRatioInput:NumberInput;

    protected var _totalTorqueOutput:NumberOutput;
    protected var _effectiveInertiaOutput:NumberOutput;

    protected var _angularVelocityInput:NumberInput;
    protected var _angularVelocityOutput:NumberOutput;

    protected var _stepDurationInput:NumberInput;
    protected var _newAngularVelocityOutput:NumberOutput;

    drivetrain_internal var _previousComponentInput:DrivetrainComponentInput;
    drivetrain_internal var _previousComponentOutput:DrivetrainComponentOutput;

    drivetrain_internal var _nextComponentInput:DrivetrainComponentInput;
    drivetrain_internal var _nextComponentOutput:DrivetrainComponentOutput;

    protected var _maxPreviousComponents:int    = 1;
    protected var _maxNextComponents:int        = 1;

    protected var _prevComponentData:DrivetrainComponentData;
    protected var _nextComponentData:DrivetrainComponentData;

    public function DrivetrainComponent(name:String = null) {
        super(name);

        _torqueInput                = new NumberInput("Torque");
        _inertiaInput               = new NumberInput("Inertia");
        _gearRatioInput             = new NumberInput("GearRatio");
        _totalTorqueOutput          = new NumberOutput("TotalTorque");
        _effectiveInertiaOutput     = new NumberOutput("EffectiveInertia");

        addInput(_torqueInput);
        addInput(_inertiaInput);
        addInput(_gearRatioInput);
        addOutput(_totalTorqueOutput);
        addOutput(_effectiveInertiaOutput);

        _previousComponentInput     = new DrivetrainComponentInput("PreviousComponent");
        _previousComponentOutput    = new DrivetrainComponentOutput("PreviousComponent");
        _nextComponentInput         = new DrivetrainComponentInput("NextComponent");
        _nextComponentOutput        = new DrivetrainComponentOutput("NextComponent");

        addInput(_previousComponentInput);
        addOutput(_previousComponentOutput);
        addInput(_nextComponentInput);
        addOutput(_nextComponentOutput);

        _angularVelocityInput       = new NumberInput("AngularVelocity");
        _angularVelocityOutput      = new NumberOutput("AngularVelocity");

        _stepDurationInput          = new NumberInput("StepDuration");
        _newAngularVelocityOutput   = new NumberOutput("NewAngularVelocity");

        addInput(_angularVelocityInput);
        addOutput(_angularVelocityOutput);
        addInput(_stepDurationInput);
        addOutput(_newAngularVelocityOutput);

        _prevComponentData = new DrivetrainComponentData();
        _nextComponentData = new DrivetrainComponentData();
    }

    public function get torqueInput():NumberInput { return _torqueInput; }
    public function get inertiaInput():NumberInput { return _inertiaInput; }
    public function get gearRatioInput():NumberInput { return _gearRatioInput; }

    public function get totalTorqueOutput():NumberOutput { return _totalTorqueOutput; }
    public function get effectiveInertiaOutput():NumberOutput { return _effectiveInertiaOutput; }

    public function get angularVelocityInput():NumberInput { return _angularVelocityInput; }
    public function get angularVelocityOutput():NumberOutput { return _angularVelocityOutput; }

    public function get stepDurationInput():NumberInput { return _stepDurationInput; }
    public function get newAngularVelocityOutput():NumberOutput { return _newAngularVelocityOutput; }

    public function connectPreviousComponent(component:DrivetrainComponent):void {
        if(_previousComponentInput.connections.size() == _maxPreviousComponents)
            throw new Error("maximum number of precious components connected is " + _maxPreviousComponents);

        Connection.connect(_previousComponentOutput, component._nextComponentInput);
        Connection.connect(component._nextComponentOutput, _previousComponentInput);
    }

    public function disconnectPreviousComponent(component:DrivetrainComponent = null):void {
        var i:int, count:int, connection:Connection;

        if(component == null) {
            while(_previousComponentInput.connections.size() > 0) {
                connection = _previousComponentInput.connections.get(0);
                connection.disconnect();
            }

            while(_previousComponentOutput.connections.size() > 0) {
                connection = _previousComponentOutput.connections.get(0);
                connection.disconnect();
            }
        }
        else {
            count = _previousComponentInput.connections.size();
            for(i = 0; i < count; ++i) {
                connection = _previousComponentInput.connections.get(i);

                if(connection.output != component._nextComponentOutput)
                    continue;

                connection.disconnect();
                --count;
                --i;
            }

            count = _previousComponentOutput.connections.size();
            for(i = 0; i < count; ++i) {
                connection = _previousComponentOutput.connections.get(i);

                if(connection.output != component._nextComponentInput)
                    continue;

                connection.disconnect();
                --count;
                --i;
            }
        }
    }

    public function connectNextComponent(component:DrivetrainComponent):void {
        if(_nextComponentInput.connections.size() == _maxNextComponents)
            throw new Error("maximum number of next components connected is " + _maxNextComponents);

        Connection.connect(_nextComponentOutput, component._previousComponentInput);
        Connection.connect(component._previousComponentOutput, _nextComponentInput);
    }

    public function disconnectNextComponent(component:DrivetrainComponent = null):void {
        var i:int, count:int, connection:Connection;

        if(component == null) {
            while(_nextComponentInput.connections.size() > 0) {
                connection = _nextComponentInput.connections.get(0);
                connection.disconnect();
            }

            while(_nextComponentOutput.connections.size() > 0) {
                connection = _nextComponentOutput.connections.get(0);
                connection.disconnect();
            }
        }
        else {
            count = _nextComponentInput.connections.size();
            for(i = 0; i < count; ++i) {
                connection = _nextComponentInput.connections.get(i);

                if(connection.output != component._previousComponentOutput)
                    continue;

                connection.disconnect();
                --count;
                --i;
            }

            count = _nextComponentOutput.connections.size();
            for(i = 0; i < count; ++i) {
                connection = _nextComponentOutput.connections.get(i);

                if(connection.output != component._previousComponentInput)
                    continue;

                connection.disconnect();
                --count;
                --i;
            }
        }
    }

    override public function requestPullData(outputConnection:Connection):* {
        if(outputConnection.output == _previousComponentOutput)
            return pullNextComponentData(outputConnection);
        else if(outputConnection.output == _nextComponentOutput)
            return pullPreviousComponentData(outputConnection);

        else if(outputConnection.output == _totalTorqueOutput)
            return calculateTotalTorque();
        else if(outputConnection.output == _effectiveInertiaOutput)
            return calculateEffectiveInertia();
        else if(outputConnection.output == _angularVelocityOutput)
            return pullAngularVelocity();
        else if(outputConnection.output == _newAngularVelocityOutput)
            return calculateNewAngularVelocity();

        return super.requestPullData(outputConnection);
    }

    protected function pullGearRatio():Number {
        return _gearRatioInput.connections.size() > 0
            ? _gearRatioInput.connections.get(0).pullData()
            : 1
        ;
    }

    protected function pullTorque():Number {
        return _torqueInput.connections.size() > 0
            ? _torqueInput.connections.get(0).pullData()
            : 0
        ;
    }

    protected function pullInertia():Number {
        return _inertiaInput.connections.size() > 0
            ? _inertiaInput.connections.get(0).pullData()
            : 0
        ;
    }

    protected function pullAngularVelocity():Number {
        if(_angularVelocityInput.connections.size() != 1)
            throw new UninitializedError("there has to be exactly one output connected to angularVelocityInput");

        return _angularVelocityInput.connections.get(0).pullData();
    }

    protected function pullStepDuration():Number {
        if(_stepDurationInput.connections.size() != 1)
            throw new UninitializedError("there has to be exactly one output connected to timeStepInput");

        return _stepDurationInput.connections.get(0).pullData();
    }

    protected function pullNextComponentData(outputConnection:Connection):DrivetrainComponentData {
        if(_nextComponentInput.connections.size() > 0) {
            // TODO: cache nextData
            var nextData:DrivetrainComponentData            = _nextComponentInput.connections.get(0).pullData();

            _nextComponentData.combinedTorque               = nextData.combinedTorque / nextData.gearRatio;
            _nextComponentData.combinedEffectiveInertia     = nextData.combinedEffectiveInertia / (nextData.gearRatio * nextData.gearRatio);
            _nextComponentData.combinedAngularVelocityDiff  = nextData.combinedAngularVelocityDiff * nextData.gearRatio;
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

    protected function pullPreviousComponentData(outputConnection:Connection):DrivetrainComponentData {
        if(_previousComponentInput.connections.size() > 0) {
            // TODO: cache prevData
            var prevData:DrivetrainComponentData            = _previousComponentInput.connections.get(0).pullData();
            var gearRatio:Number                            = pullGearRatio();

            _prevComponentData.combinedTorque               = prevData.combinedTorque * gearRatio;
            _prevComponentData.combinedEffectiveInertia     = prevData.combinedEffectiveInertia * (gearRatio * gearRatio);
            _prevComponentData.combinedAngularVelocityDiff  = prevData.combinedAngularVelocityDiff / gearRatio;
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

    protected function calculateTotalTorque():Number {
        var prevData:DrivetrainComponentData        = _previousComponentInput.connections.size() > 0 ? _previousComponentInput.connections.get(0).pullData() : null;
        var nextAndThisData:DrivetrainComponentData = pullNextComponentData(_nextComponentInput.connections.size() > 0 ? _nextComponentInput.connections.get(0) : null);
        var totalTorque:Number                      = nextAndThisData.combinedTorque;

        if(prevData != null)
            totalTorque += prevData.combinedTorque * nextAndThisData.gearRatio;

        return totalTorque;
    }

    protected function calculateEffectiveInertia():Number {
        var prevData:DrivetrainComponentData        = _previousComponentInput.connections.size() > 0 ? _previousComponentInput.connections.get(0).pullData() : null;
        var nextAndThisData:DrivetrainComponentData = pullNextComponentData(_nextComponentInput.connections.size() > 0 ? _nextComponentInput.connections.get(0) : null);
        var effectiveInertia:Number                 = nextAndThisData.combinedEffectiveInertia;

        if(prevData != null)
            effectiveInertia += prevData.combinedEffectiveInertia * (nextAndThisData.gearRatio * nextAndThisData.gearRatio);

        return effectiveInertia;
    }

    protected function calculateNewAngularVelocity():Number {
        var vel:Number                              = pullAngularVelocity();
        var dt:Number                               = pullStepDuration();
        var torque:Number                           = calculateTotalTorque();
        var inertia:Number                          = calculateEffectiveInertia();
        var acc:Number                              = torque / inertia;
        var newVel:Number                           = vel + acc * dt;
        var prevData:DrivetrainComponentData        = _previousComponentInput.connections.size() > 0 ? _previousComponentInput.connections.get(0).pullData() : null;
        var nextAndThisData:DrivetrainComponentData = pullNextComponentData(_nextComponentInput.connections.size() > 0 ? _nextComponentInput.connections.get(0) : null);

        if(prevData != null)
            newVel += prevData.combinedAngularVelocityDiff / nextAndThisData.gearRatio;

        newVel += nextAndThisData.combinedAngularVelocityDiff;

        return newVel;
    }

    protected function calculatePreviousAngularVelocityDiff():Number {
        return 0; // by default components don't create any angular velocity modifiers
    }

    protected function calculateNextAngularVelocityDiff():Number {
        return 0; // by default components don't create any angular velocity modifiers
    }
}
}
