/**
 * User: booster
 * Date: 11/03/15
 * Time: 12:42
 */
package drive.components.differential {
import drive.components.*;

import plugs.Connection;
import plugs.inputs.NumberInput;
import plugs.outputs.NumberOutput;

public class DifferentialComponent extends DrivetrainComponent {
    protected var _shareRatio:Number;

    protected var _excessTorqueInput:NumberInput;
    protected var _excessTorqueOutput:NumberOutput;

    public function DifferentialComponent(shareRatio:Number = 0.5, name:String = null) {
        super(name);

        _maxPreviousComponents  = 1;
        _maxNextComponents      = 2;
        _shareRatio             = shareRatio;

        _excessTorqueInput      = new NumberInput("ExcessTorque");
        _excessTorqueOutput     = new NumberOutput("ExcessTorque");

        addInput(_excessTorqueInput);
        addOutput(_excessTorqueOutput);
    }

    public function get shareRatio():Number { return _shareRatio; }

    public function connectExcessTorqueStore(store:IDifferentialExcessTorqueStore):void {
        if(_excessTorqueInput.connections.size() > 0 || _excessTorqueOutput.connections.size() > 0)
            throw new Error("only one excess torque store is allowed");

        Connection.connect(store.torqueOutput, _excessTorqueInput);
        Connection.connect(_excessTorqueOutput, store.torqueInput);
    }

    public function disconnectExcessTorqueStore():void {
        if(_excessTorqueInput.connections.size() == 0 && _excessTorqueOutput.connections.size() == 0)
            return;

        _excessTorqueInput.connections.get(0).disconnect();
        _excessTorqueOutput.connections.get(0).disconnect();
    }

    override public function requestPullData(outputConnection:Connection):* {
        if(outputConnection.output == _excessTorqueOutput)
            return pullExcessTorque();

        return super.requestPullData(outputConnection);
    }

    protected function getInputExcessTorque():Number {
        if(_excessTorqueInput.connections.size() != 1)
            throw new UninitializedError("excess torque input has to be exactly 1 connected to exactly one output");

        return _excessTorqueInput.connections.get(0).pullData();
    }

    protected function pullExcessTorque():Number {
        if(drivetrain_internal::_nextComponentInput.connections.size() < 2)
            throw new UninitializedError("two next components have to be connected to a differential");

        var nextDataA:DrivetrainComponentData   = drivetrain_internal::_nextComponentInput.connections.get(0).pullData();
        var nextDataB:DrivetrainComponentData   = drivetrain_internal::_nextComponentInput.connections.get(1).pullData();

        var torqueA:Number  = nextDataA.combinedTorque / nextDataA.gearRatio;
        var torqueB:Number  = nextDataB.combinedTorque / nextDataB.gearRatio;
        var excess:Number   = torqueA - torqueB;

        return excess;
    }

    override protected function pullNextComponentData(outputConnection:Connection):DrivetrainComponentData {
        if(drivetrain_internal::_nextComponentInput.connections.size() < 2)
            throw new UninitializedError("two next components have to be connected to a differential");

        var nextDataA:DrivetrainComponentData   = drivetrain_internal::_nextComponentInput.connections.get(0).pullData();
        var nextDataB:DrivetrainComponentData   = drivetrain_internal::_nextComponentInput.connections.get(1).pullData();

        var torqueA:Number  = nextDataA.combinedTorque / nextDataA.gearRatio;
        var torqueB:Number  = nextDataB.combinedTorque / nextDataB.gearRatio;

        _nextComponentData.combinedTorque               = torqueA + torqueB;
        _nextComponentData.combinedTorque              += _nextComponentData.combinedTorque > 0 ? -Math.abs(getInputExcessTorque()) : -Math.abs(getInputExcessTorque());
        _nextComponentData.combinedEffectiveInertia     = nextDataA.combinedEffectiveInertia / (nextDataA.gearRatio * nextDataA.gearRatio)
                                                        + nextDataB.combinedEffectiveInertia / (nextDataB.gearRatio * nextDataB.gearRatio);
        _nextComponentData.combinedAngularVelocityDiff  = nextDataA.combinedAngularVelocityDiff * nextDataA.gearRatio
                                                        + nextDataB.combinedAngularVelocityDiff * nextDataB.gearRatio;

        _nextComponentData.gearRatio                    = pullGearRatio();
        _nextComponentData.combinedTorque              += pullTorque();
        _nextComponentData.combinedEffectiveInertia    += pullInertia();

        return _nextComponentData;
    }

    override protected function pullPreviousComponentData(outputConnection:Connection):DrivetrainComponentData {
        var prevAndThisData:DrivetrainComponentData = super.pullPreviousComponentData(outputConnection);
        prevAndThisData.copyTo(_prevComponentData);

        // one of the next components has to be added, we need to check which one
        var nextCompOutput:DrivetrainComponentOutput = null;

        var count:int = drivetrain_internal::_nextComponentOutput.connections.size();
        for(var i:int = 0; i < count; ++i) {
            var conn:Connection = drivetrain_internal::_nextComponentOutput.connections.get(i);

            // skip the one which is asking for for data
            if(conn == outputConnection)
                continue;

            var nextComponent:DrivetrainComponent = conn.input.consumer as DrivetrainComponent;

            // only one next components is connected
            if(nextComponent == null)
                throw new UninitializedError("two next components have to be connected to a differential");

            nextCompOutput                          = nextComponent.drivetrain_internal::_previousComponentOutput;
            var nextData:DrivetrainComponentData    = nextCompOutput.connections.get(0).pullData();

            // don't pull torque from the other next component
            // just add excess torque
            // and share the torque pulled from prev components according to share ratio
            if(i == 0)
                _prevComponentData.combinedTorque = _prevComponentData.combinedTorque * (1 - _shareRatio) - getInputExcessTorque();
            else
                _prevComponentData.combinedTorque = _prevComponentData.combinedTorque * _shareRatio + getInputExcessTorque();

            _prevComponentData.combinedEffectiveInertia    += nextData.combinedEffectiveInertia / (nextData.gearRatio * nextData.gearRatio);
            _prevComponentData.combinedAngularVelocityDiff += nextData.combinedAngularVelocityDiff * nextData.gearRatio;

            return _prevComponentData;
        }

        throw new Error("no output connections, so who's requesting it then?");
    }
}
}
