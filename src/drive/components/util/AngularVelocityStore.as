/**
 * User: booster
 * Date: 16/03/15
 * Time: 11:09
 */
package drive.components.util {
import plugs.Connection;
import plugs.inputs.NumberInput;
import plugs.outputs.NumberOutput;
import plugs.processors.AbstractProcessor;

public class AngularVelocityStore extends AbstractProcessor implements ISteppable {
    protected var _angularVelocityInput:NumberInput;
    protected var _angularVelocityOutput:NumberOutput;
    protected var _stepDurationOutput:NumberOutput;

    protected var _timeStepInput:NumberInput;

    private var _dt:Number;
    private var _angularVelocity:Number = 0;

    public function AngularVelocityStore(name:String = null) {
        super(name);

        _angularVelocityInput   = new NumberInput("AngularVelocity");
        _angularVelocityOutput  = new NumberOutput("AngularVelocity");
        _stepDurationOutput         = new NumberOutput("dt");

        addInput(_angularVelocityInput);
        addOutput(_angularVelocityOutput);
        addOutput(_stepDurationOutput);

        _timeStepInput = new NumberInput("dt");

        addInput(_timeStepInput);
    }

    public function get angularVelocityInput():NumberInput { return _angularVelocityInput; }
    public function get angularVelocityOutput():NumberOutput { return _angularVelocityOutput; }
    public function get stepDurationOutput():NumberOutput { return _stepDurationOutput; }

    public function get timeStepInput():NumberInput { return _timeStepInput; }

    public function get angularVelocity():Number { return _angularVelocity; }
    public function set angularVelocity(value:Number):void { _angularVelocity = value; }

    override public function receivePushData(data:*, inputConnection:Connection):void {
        if(inputConnection.input == _timeStepInput) {
            step(data);
            return;
        }

        super.receivePushData(data, inputConnection);
    }

    override public function requestPullData(outputConnection:Connection):* {
        if(outputConnection.output == _stepDurationOutput)
            return _dt;
        else if(outputConnection.output == _angularVelocityOutput)
            return _angularVelocity;

        return super.requestPullData(outputConnection);
    }

    protected function step(dt:Number):void {
        _dt = dt;

        // this call will probably in turn request angular velocity and time step!
        _angularVelocity = pullAngularVelocity();
    }

    protected function pullAngularVelocity():Number {
        var angVel:Number = _angularVelocityInput.connections.get(0).pullData();

        return angVel;
    }
}
}
