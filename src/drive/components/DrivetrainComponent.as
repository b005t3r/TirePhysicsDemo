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

public class DrivetrainComponent extends AbstractProcessor {
    protected var _torqueInput:NumberInput;
    protected var _inertiaInput:NumberInput;
    protected var _gearRatioInput:NumberInput;

    protected var _totalTorqueOutput:NumberOutput;
    protected var _angularAccelerationOutput:NumberOutput;
    protected var _effectiveInertiaOutput:NumberOutput;

    protected var _previousComponentInput:DrivetrainComponentInput;
    protected var _previousComponentOutput:DrivetrainComponentOutput;

    protected var _nextComponentInput:DrivetrainComponentInput;
    protected var _nextComponentOutput:DrivetrainComponentOutput;

    protected var _maxPreviousComponents:int    = 1;
    protected var _maxNextComponents:int        = 1;

    protected var _componentData:DrivetrainComponentData;

    public function DrivetrainComponent(name:String = null) {
        super(name);

        _torqueInput                = new NumberInput("Torque");
        _inertiaInput               = new NumberInput("Inertia");
        _gearRatioInput             = new NumberInput("GearRatio");
        _totalTorqueOutput          = new NumberOutput("TotalTorque");
        _angularAccelerationOutput  = new NumberOutput("AngularAcceleration");
        _effectiveInertiaOutput     = new NumberOutput("EffectiveInertia");

        _previousComponentInput     = new DrivetrainComponentInput("PreviousComponent");
        _previousComponentOutput    = new DrivetrainComponentOutput("PreviousComponent");
        _nextComponentInput         = new DrivetrainComponentInput("NextComponent");
        _nextComponentOutput        = new DrivetrainComponentOutput("NextComponent");

        addInput(_torqueInput);
        addInput(_inertiaInput);
        addInput(_gearRatioInput);
        addOutput(_totalTorqueOutput);
        addOutput(_angularAccelerationOutput);
        addOutput(_effectiveInertiaOutput);
        addInput(_previousComponentInput);
        addOutput(_previousComponentOutput);
        addInput(_nextComponentInput);
        addOutput(_nextComponentOutput);

        _componentData = new DrivetrainComponentData();
    }

    public function get torqueInput():NumberInput { return _torqueInput; }
    public function get inertiaInput():NumberInput { return _inertiaInput; }
    public function get gearRatioInput():NumberInput { return _gearRatioInput; }

    public function get totalTorqueOutput():NumberOutput { return _totalTorqueOutput; }
    public function get angularAccelerationOutput():NumberOutput { return _angularAccelerationOutput; }
    public function get effectiveInertiaOutput():NumberOutput { return _effectiveInertiaOutput; }

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
            return pullTotalTorque();
        else if(outputConnection.output == _effectiveInertiaOutput)
            return pullEffectiveInertia();
        else
            throw new ArgumentError("invalid connection");
    }

    protected function getInputGearRatio():Number {
        return _gearRatioInput.connections.size() > 0
            ? _gearRatioInput.connections.get(0).pullData()
            : 1
        ;
    }

    protected function getInputTorque():Number {
        return _torqueInput.connections.size() > 0
            ? _torqueInput.connections.get(0).pullData()
            : 0
        ;
    }

    protected function getInputInertia():Number {
        return _inertiaInput.connections.size() > 0
            ? _inertiaInput.connections.get(0).pullData()
            : 0
        ;
    }

    protected function pullNextComponentData(outputConnection:Connection):DrivetrainComponentData {
        if(_nextComponentInput.connections.size() > 0) {
            var nextData:DrivetrainComponentData    = _nextComponentInput.connections.get(0).pullData();

            _componentData.combinedTorque           = nextData.combinedTorque / nextData.gearRatio + getInputTorque();
            _componentData.combinedEffectiveInertia = nextData.combinedEffectiveInertia / (nextData.gearRatio * nextData.gearRatio) + getInputInertia();
            _componentData.gearRatio                = getInputGearRatio();
        }
        else {
            _componentData.gearRatio                = getInputGearRatio();
            _componentData.combinedTorque           = getInputTorque();
            _componentData.combinedEffectiveInertia = getInputInertia();
        }

        return _componentData;
    }

    protected function pullPreviousComponentData(outputConnection:Connection):DrivetrainComponentData {
        if(_previousComponentInput.connections.size() > 0) {
            var prevData:DrivetrainComponentData    = _previousComponentInput.connections.get(0).pullData();

            _componentData.gearRatio                = getInputGearRatio();
            _componentData.combinedTorque           = prevData.combinedTorque * _componentData.gearRatio + getInputTorque();
            _componentData.combinedEffectiveInertia = prevData.combinedEffectiveInertia * (_componentData.gearRatio * _componentData.gearRatio) + getInputInertia();
        }
        else {
            _componentData.combinedTorque           = getInputTorque();
            _componentData.combinedEffectiveInertia = getInputInertia();
            _componentData.gearRatio                = getInputGearRatio();
        }

        return _componentData;
    }

    protected function pullTotalTorque():Number {
        var prevData:DrivetrainComponentData        = _previousComponentInput.connections.size() > 0 ? _previousComponentInput.connections.get(0).pullData() : null;
        var nextAndThisData:DrivetrainComponentData = pullNextComponentData(_nextComponentInput.connections.size() > 0 ? _nextComponentInput.connections.get(0) : null);
        var totalTorque:Number                      = nextAndThisData.combinedTorque;

        if(prevData != null)
            totalTorque += prevData.combinedTorque * nextAndThisData.gearRatio;

        return totalTorque;
    }

    protected function pullEffectiveInertia():Number {
        var prevData:DrivetrainComponentData        = _previousComponentInput.connections.size() > 0 ? _previousComponentInput.connections.get(0).pullData() : null;
        var nextAndThisData:DrivetrainComponentData = pullNextComponentData(_nextComponentInput.connections.size() > 0 ? _nextComponentInput.connections.get(0) : null);
        var effectiveInertia:Number                 = nextAndThisData.combinedEffectiveInertia;

        if(prevData != null)
            effectiveInertia += prevData.combinedEffectiveInertia * (nextAndThisData.gearRatio * nextAndThisData.gearRatio);

        return effectiveInertia;
    }
}
}
