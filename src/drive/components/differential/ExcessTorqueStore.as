/**
 * User: booster
 * Date: 13/03/15
 * Time: 16:05
 */
package drive.components.differential {
import plugs.Connection;
import plugs.inputs.NumberInput;
import plugs.outputs.NumberOutput;
import plugs.processors.AbstractProcessor;

public class ExcessTorqueStore extends AbstractProcessor implements IExcessTorqueStore {
    private var _torqueInput:NumberInput;
    private var _torqueOutput:NumberOutput;

    private var _timeStepInput:NumberInput;

    private var _torque:Number = 0;

    public function ExcessTorqueStore(name:String = null) {
        super(name);

        _torqueInput    = new NumberInput("ExcessTorque");
        _torqueOutput   = new NumberOutput("ExcessTorque");

        addInput(_torqueInput);
        addOutput(_torqueOutput);

        _timeStepInput  = new NumberInput("dt");

        addInput(_timeStepInput);
    }

    public function get torqueInput():NumberInput { return _torqueInput; }
    public function get torqueOutput():NumberOutput { return _torqueOutput; }

    public function get timeStepInput():NumberInput { return _timeStepInput; }

    public function get torque():Number { return _torque; }
    public function set torque(value:Number):void { _torque = value; }

    override public function receivePushData(data:*, inputConnection:Connection):void {
        if(inputConnection.input == _timeStepInput)
            pullTorque();
        else
            super.receivePushData(data, inputConnection);
    }

    override public function requestPullData(outputConnection:Connection):* {
        if(outputConnection.output == _torqueOutput)
            return _torque;

        throw new ArgumentError("invalid connection");
    }

    private function pullTorque():void {
        _torque = _torqueInput.connections.get(0).pullData();
    }
}
}
