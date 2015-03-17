/**
 * User: booster
 * Date: 17/03/15
 * Time: 15:53
 */
package drive.components.util {
import plugs.Connection;
import plugs.inputs.NumberInput;
import plugs.outputs.NumberOutput;
import plugs.processors.AbstractProcessor;

public class AngularVelocityForwarder extends AbstractProcessor {
    private var _angularVelocityInput:NumberInput;
    private var _gearRatioInput:NumberInput;

    private var _angularVelocityOutput:NumberOutput;

    private var _divideByGearRatio:Boolean;

    public function AngularVelocityForwarder(name:String = null) {
        super(name);

        _angularVelocityInput   = new NumberInput("AngularVelocity");
        _gearRatioInput         = new NumberInput("GearRatio");
        _angularVelocityOutput  = new NumberOutput("AngularVelocity");

        addInput(_angularVelocityInput);
        addInput(_gearRatioInput);
        addOutput(_angularVelocityOutput);
    }

    public function get angularVelocityInput():NumberInput { return _angularVelocityInput; }
    public function get gearRatioInput():NumberInput { return _gearRatioInput; }
    public function get angularVelocityOutput():NumberOutput { return _angularVelocityOutput; }

    public function get divideByGearRatio():Boolean { return _divideByGearRatio; }
    public function set divideByGearRatio(value:Boolean):void { _divideByGearRatio = value; }

    override public function requestPullData(outputConnection:Connection):* {
        if(outputConnection.output == _angularVelocityOutput)
            return _divideByGearRatio ? pullAngularVelocity() / pullGearRatio() : pullAngularVelocity() * pullGearRatio();

        return super.requestPullData(outputConnection);
    }

    private function pullGearRatio():Number {
        return _gearRatioInput.connections.size() > 0
            ? _gearRatioInput.connections.get(0).pullData()
            : 1
        ;
    }

    private function pullAngularVelocity():Number {
        return _angularVelocityInput.connections.get(0).pullData();
    }
}
}
