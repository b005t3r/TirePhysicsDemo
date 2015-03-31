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

public class ValueForwarder extends AbstractProcessor {
    private var _angularVelocityInput:NumberInput;
    private var _gearRatioInput:NumberInput;

    private var _angularVelocityOutput:NumberOutput;

    private var _divideByGearRatio:Boolean;

    public function ValueForwarder(name:String = null) {
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
            return calculateTotalAngularVelocity();

        return super.requestPullData(outputConnection);
    }

    private function pullGearRatio(connIndex:int):Number {
        // if no gear ratios are connected, assume all are 1
        if(_gearRatioInput.connections.size() == 0)
            return 1;

        if(connIndex >= _gearRatioInput.connections.size())
            throw new ArgumentError("no connection for index: " + connIndex);

        return _gearRatioInput.connections.get(connIndex).pullData();
    }

    private function pullAngularVelocity(connIndex:int):Number {
        if(connIndex >= _angularVelocityInput.connections.size())
            throw new ArgumentError("no connection for index: " + connIndex);

        return _angularVelocityInput.connections.get(connIndex).pullData();
    }

    private function calculateTotalAngularVelocity():Number {
        var totalVel:Number = 0;

        var count:int = _angularVelocityInput.connections.size();
        for(var i:int = 0; i < count; ++i) {
            totalVel += _divideByGearRatio
                ? pullAngularVelocity(i) / pullGearRatio(i)
                : pullAngularVelocity(i) * pullGearRatio(i)
            ;
        }

        return totalVel;
    }
}
}
