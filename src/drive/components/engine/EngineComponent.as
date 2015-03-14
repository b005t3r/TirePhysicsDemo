/**
 * User: booster
 * Date: 11/03/15
 * Time: 13:43
 */
package drive.components.engine {
import drive.components.*;

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
        var torque:Number       = pullTotalTorque();
        var inertia:Number      = pullEffectiveInertia();
        var angularAcc:Number   = torque / inertia;
        var dAngVel:Number      = angularAcc * dt;
        _rpm                   += dAngVel * 60 / (2 * Math.PI);
    }
}
}
