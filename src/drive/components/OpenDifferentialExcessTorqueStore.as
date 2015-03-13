/**
 * User: booster
 * Date: 13/03/15
 * Time: 16:05
 */
package drive.components {
import plugs.Connection;
import plugs.inputs.NumberInput;
import plugs.outputs.NumberOutput;
import plugs.processors.AbstractProcessor;

public class OpenDifferentialExcessTorqueStore extends AbstractProcessor implements IDifferentialExcessTorqueStore {
    private var _torqueInput:NumberInput;
    private var _torqueOutput:NumberOutput;

    private var _torque:Number = 0;

    public function OpenDifferentialExcessTorqueStore(name:String = null) {
        super(name);

        _torqueInput    = new NumberInput("ExcessTorque");
        _torqueOutput   = new NumberOutput("ExcessTorque");

        addInput(_torqueInput);
        addOutput(_torqueOutput);
    }

    public function get torqueInput():NumberInput { return _torqueInput; }
    public function get torqueOutput():NumberOutput { return _torqueOutput; }

    public function get torque():Number { return _torque; }
    public function set torque(value:Number):void { _torque = value; }

    public function pullTorque():void {
        _torque = _torqueInput.connections.get(0).pullData();
    }

    override public function requestPullData(outputConnection:Connection):* {
        if(outputConnection.output == _torqueOutput)
            return _torque;

        throw new ArgumentError("invalid connection");
    }
}
}
