/**
 * User: booster
 * Date: 11/03/15
 * Time: 13:43
 */
package drive.components.engine {
import drive.components.*;
import drive.components.util.ISteppable;

import plugs.Connection;

import plugs.inputs.NumberInput;

import plugs.outputs.NumberOutput;

public class EngineComponent extends DrivetrainComponent implements ISteppable {
    private var _rpmOutput:NumberOutput;
    private var _rpm:Number;

    private var _timeStepInput:NumberInput;

    public function EngineComponent(name:String = null) {
        super(name);

        _maxPreviousComponents = 0;

        _rpmOutput = new NumberOutput("RPM");
        addOutput(_rpmOutput);

        _timeStepInput = new NumberInput("dt");
        addInput(_timeStepInput);
    }

    public function get rpmOutput():NumberOutput { return _rpmOutput; }
    public function get timeStepInput():NumberInput { return _timeStepInput; }

    public function connectTorqueCurve(curve:ITorqueCurve):void {
        if(_torqueInput.connections.size() > 0)
            throw new Error("torque input already connected");

        Connection.connect(curve.torqueOutput, _torqueInput);
        Connection.connect(_rpmOutput, curve.rpmInput);
    }

    public function disconnectTorqueCurve():void {
        var count:int = _torqueInput.connections.size();
        for(var i:int = 0; i < count; ++i) {
            var conn:Connection     = _torqueInput.connections.get(i);
            var curve:ITorqueCurve  = conn.output.provider as ITorqueCurve;

            if(curve == null)
                continue;

            conn.disconnect();
            curve.rpmInput.connections.get(0).disconnect();
        }
    }

    override public function receivePushData(data:*, inputConnection:Connection):void {
        if(inputConnection.input == _timeStepInput)
            step(data as Number);

        return super.receivePushData(data, inputConnection);
    }

    override public function requestPullData(outputConnection:Connection):* {
        if(outputConnection.output == _rpmOutput)
            return _rpm;

        return super.requestPullData(outputConnection);
    }

    private function step(dt:Number):void {
        var torque:Number       = calculateTotalTorque();
        var inertia:Number      = calculateEffectiveInertia();
        var angularAcc:Number   = torque / inertia;
        var dAngVel:Number      = angularAcc * dt;
        _rpm                   += dAngVel * 60 / (2 * Math.PI);
    }
}
}
